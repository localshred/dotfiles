(ns mx.prs-watch
  "Background PR watching for `mx prs watch`.

  Maintains a watchlist of GitHub PRs and a per-PR state snapshot under
  `$XDG_CACHE_HOME/mx/prs-watch/`. A launchd agent periodically invokes
  `mx prs watch tick`, which fetches each watched PR via `gh`, diffs the
  fresh snapshot against the stored one, and fires a macOS notification
  (via `terminal-notifier`, click-to-open) when comments, CI status,
  mergeability, or the review decision change. Merged/closed PRs get a
  final notification and are dropped from the watchlist.

  Loaded via `load-file` by `commands/prs.clj`; `main` is the entry
  point for the `watch` subcommand."
  (:require [babashka.fs :as fs]
            [babashka.process :as p]
            [cheshire.core :as json]
            [clojure.string :as str])
  (:import [java.time Duration Instant]))

(load-file (str (or (System/getenv "MX_ROOT")
                    (str (System/getProperty "user.home") "/code/src/utils/dotfiles/lib/mx"))
                "/lib/ui.clj"))
(require '[mx.ui :as ui])

;;
;; Static defs
;;

(def agent-label "com.localshred.mx-prs-watch")

(def gh-json-fields
  "PR fields fetched from `gh pr view --json`."
  "number,title,url,state,mergeable,reviewDecision,comments,reviews,statusCheckRollup")

(def home (System/getProperty "user.home"))

(def mx-root
  (or (System/getenv "MX_ROOT")
      (str home "/code/src/utils/dotfiles/lib/mx")))

(def cache-dir
  (str (or (System/getenv "XDG_CACHE_HOME") (str home "/.cache")) "/mx/prs-watch"))

(def state-file (str cache-dir "/state.json"))

(def watchlist-file (str cache-dir "/watchlist.json"))

(def ^:private conclusion->kind
  "CheckRun conclusion → simplified kind."
  {"ACTION_REQUIRED" :fail
   "CANCELLED"       :fail
   "FAILURE"         :fail
   "NEUTRAL"         :ok
   "SKIPPED"         :ok
   "STALE"           :fail
   "STARTUP_FAILURE" :fail
   "SUCCESS"         :ok
   "TIMED_OUT"       :fail})

(def ^:private context-state->kind
  "StatusContext state → simplified kind."
  {"ERROR"    :fail
   "EXPECTED" :ok
   "FAILURE"  :fail
   "PENDING"  :pending
   "SUCCESS"  :ok})

(def ^:private mergeable-label
  "Readable label for a `mergeable` value."
  {"CONFLICTING" "conflicting"
   "MERGEABLE"   "mergeable"
   "UNKNOWN"     "unknown"})

(def ^:private pr-short-re #"^([^/\s]+)/([^/\s#]+)#(\d+)$")

(def ^:private pr-url-re #"github\.com[:/]([^/\s]+)/([^/\s]+)/pull/(\d+)")

(def ^:private review-label
  "Readable label for a `reviewDecision` value."
  {""                  "none"
   "APPROVED"          "approved"
   "CHANGES_REQUESTED" "changes requested"
   "REVIEW_REQUIRED"   "review required"})

(declare agent-loaded? check-kind check-pr cmd-add cmd-detail cmd-list cmd-pick cmd-rm cmd-tick
         ensure-agent! fetch-pr format-comment log-error log-info notify-pr! now-iso parse-pr-ref
         pr-key read-json read-state read-watchlist require-gh! save-state! save-watchlist!
         status-label truncate usage write-json!)

;;
;; Public functions
;;

(defn checks-summary
  "Reduce a `statusCheckRollup` array to one of \"passing\", \"failing\",
  \"running\", or \"none\"."
  [rollup]
  (let [kinds (map check-kind rollup)]
    (cond
      (empty? kinds)           "none"
      (some #{:fail} kinds)    "failing"
      (some #{:pending} kinds) "running"
      :else                    "passing")))

(defn compute-changes
  "Human-readable change lines between an old and new PR snapshot. Empty
  when nothing notable changed."
  [old new]
  (let [new-comments (- (:comments new) (:comments old))
        new-reviews  (- (:reviews new) (:reviews old))
        decision-changed? (not= (:review-decision old) (:review-decision new))
        checks-changed?   (not= (:checks old) (:checks new))
        mergeable-changed? (not= (:mergeable old) (:mergeable new))]
    (cond-> []
      (and (= "OPEN" (:state old)) (= "MERGED" (:state new)))
      (conj "🎉 Merged")

      (and (= "OPEN" (:state old)) (= "CLOSED" (:state new)))
      (conj "🚫 Closed")

      (pos? new-comments)
      (conj (format "💬 %d new comment%s" new-comments (if (= 1 new-comments) "" "s")))

      (and decision-changed? (= "APPROVED" (:review-decision new)))
      (conj "✅ Approved")

      (and decision-changed? (= "CHANGES_REQUESTED" (:review-decision new)))
      (conj "🔴 Changes requested")

      (and (not decision-changed?) (pos? new-reviews))
      (conj (format "👀 %d new review%s" new-reviews (if (= 1 new-reviews) "" "s")))

      (and checks-changed? (= "failing" (:checks new)))
      (conj "❌ CI failing")

      (and checks-changed? (= "passing" (:checks new)))
      (conj "✅ CI passing")

      (and checks-changed? (= "running" (:checks new)))
      (conj "🔄 CI running")

      (and mergeable-changed? (= "CONFLICTING" (:mergeable new)))
      (conj "⚠️ Merge conflicts")

      (and mergeable-changed? (= "CONFLICTING" (:mergeable old)) (= "MERGEABLE" (:mergeable new)))
      (conj "✅ Conflicts resolved"))))

(defn field-transitions
  "Human-readable `X → Y` lines for each field that differs between an
  old and new snapshot (checks, review decision, mergeability, state).
  Used by the interactive detail view."
  [old new]
  (->> [(when (not= (:checks old) (:checks new))
          (format "🔧 CI: %s → %s" (:checks old) (:checks new)))
        (when (not= (:review-decision old) (:review-decision new))
          (format "👀 Review: %s → %s"
                  (get review-label (:review-decision old) (:review-decision old))
                  (get review-label (:review-decision new) (:review-decision new))))
        (when (not= (:mergeable old) (:mergeable new))
          (format "🔀 Merge: %s → %s"
                  (get mergeable-label (:mergeable old) (:mergeable old))
                  (get mergeable-label (:mergeable new) (:mergeable new))))
        (when (not= (:state old) (:state new))
          (format "📦 State: %s → %s"
                  (str/lower-case (:state old)) (str/lower-case (:state new))))]
       (remove nil?)
       vec))

(defn main
  "Entry point for `mx prs watch <subcommand>`."
  [args]
  (let [[sub & more] args]
    (cond
      (nil? sub)     (cmd-pick)
      (= "list" sub) (cmd-list)
      (= "rm" sub)   (if-let [r (first more)] (cmd-rm r) (usage))
      (= "tick" sub) (cmd-tick)
      (parse-pr-ref sub) (cmd-add sub)
      :else          (usage))))

(defn parse-pr-ref
  "Parse a PR reference — a github.com PR URL or `owner/repo#number` —
  into `{:owner :repo :number :url}`, or nil when unrecognized."
  [s]
  (when (string? s)
    (when-let [[_ owner repo number] (or (re-find pr-url-re s)
                                         (re-matches pr-short-re s))]
      {:owner  owner
       :repo   repo
       :number (parse-long number)
       :url    (format "https://github.com/%s/%s/pull/%s" owner repo number)})))

(defn pr->snapshot
  "Reduce a `gh pr view` JSON map to the fields we diff and display."
  [pr]
  {:checks          (checks-summary (:statusCheckRollup pr))
   :comments        (count (:comments pr))
   :mergeable       (:mergeable pr)
   :review-decision (or (:reviewDecision pr) "")
   :reviews         (count (:reviews pr))
   :state           (:state pr)
   :title           (:title pr)
   :url             (:url pr)})

;;
;; Private functions
;;

(defn- agent-loaded?
  "True when the launchd agent is currently loaded."
  []
  (zero? (:exit @(p/process "launchctl" "list" agent-label))))

(defn- check-kind
  "Simplified kind (:ok/:fail/:pending) for one statusCheckRollup entry."
  [check]
  (cond
    (:state check)             (get context-state->kind (:state check) :pending)
    (= "COMPLETED" (:status check)) (get conclusion->kind (:conclusion check) :fail)
    :else                      :pending))

(defn- check-pr
  "Fetch and diff a single watched PR. Returns `{:key :snapshot :remove?}`
  on success or `{:key :error}` on fetch failure. Notifies as a side
  effect when there are changes."
  [old-state entry]
  (let [k (pr-key entry)]
    (try
      (let [pr       (fetch-pr (:url entry))
            new-snap (assoc (pr->snapshot pr) :checked-at (now-iso))
            old-snap (get old-state k)
            changes  (if old-snap (compute-changes old-snap new-snap) [])
            closed?  (contains? #{"MERGED" "CLOSED"} (:state new-snap))]
        (when (seq changes)
          (notify-pr! entry pr changes)
          (log-info (format "%s: %s" k (str/join ", " changes))))
        {:key k :snapshot new-snap :remove? closed?})
      (catch Exception ex
        (log-error (format "Failed to check %s: %s" k (.getMessage ex)))
        {:key k :error true}))))

(defn- cmd-add
  "Add a PR to the watchlist, seeding its snapshot without notifying."
  [ref-str]
  (if-let [ref (parse-pr-ref ref-str)]
    (let [k  (pr-key ref)
          wl (read-watchlist)]
      (if (some #(= k (pr-key %)) wl)
        (println (format "Already watching %s" k))
        (let [_  (require-gh!)
              pr (fetch-pr (:url ref))]
          (if (contains? #{"MERGED" "CLOSED"} (:state pr))
            (println (format "⚠️  %s is already %s — not adding it to the watchlist."
                             k (str/lower-case (:state pr))))
            (let [snap (assoc (pr->snapshot pr) :checked-at (now-iso))]
              (save-watchlist! (conj wl (assoc ref :added-at (now-iso))))
              (save-state! (assoc (read-state) k snap))
              (ensure-agent!)
              (log-info (format "Watching %s" k))
              (println (format "👀 Now watching %s — %s" k (:title pr))))))))
    (do (usage) nil)))

(defn- cmd-detail
  "Fetch a watched PR fresh, print what changed since the last stored
  snapshot (field transitions and newest comments), then persist the
  fresh snapshot so the change is acknowledged."
  [entry]
  (require-gh!)
  (let [k        (pr-key entry)
        old-snap (get (read-state) k)
        pr       (fetch-pr (:url entry))
        new-snap (assoc (pr->snapshot pr) :checked-at (now-iso))
        transitions  (if old-snap (field-transitions old-snap new-snap) [])
        new-comments (if old-snap (max 0 (- (:comments new-snap) (:comments old-snap))) 0)
        since    (if-let [ca (:checked-at old-snap)]
                   (str (ui/humanize (Duration/between (Instant/parse ca) (Instant/now))) " ago")
                   "first check")]
    (println)
    (println (format "🔀 %s" (ui/hyperlink (:url pr) (format "%s — %s" k (:title pr)))))
    (println (format "   %s" (ui/dim (:url pr))))
    (println)
    (if (and old-snap (or (seq transitions) (pos? new-comments)))
      (do
        (println (format "Changes since last check (%s):" since))
        (doseq [t transitions] (println (format "  %s" t)))
        (when (pos? new-comments)
          (println (format "  💬 %d new comment%s:" new-comments (if (= 1 new-comments) "" "s")))
          (doseq [c (take-last new-comments (:comments pr))]
            (println (format-comment c)))))
      (println (format "No changes since last check (%s)." since)))
    (println)
    (println (format "Current: %s" (status-label new-snap)))
    (save-state! (assoc (read-state) k new-snap))))

(defn- cmd-list
  "Print the watchlist with each PR's last-known status and check age."
  []
  (let [wl    (read-watchlist)
        state (read-state)]
    (if (empty? wl)
      (println "📭 Not watching any PRs. Add one with: mx prs watch <pr-url>")
      (do
        (println (format "👀 Watching %d PR(s):" (count wl)))
        (ui/print-table
          (for [entry (sort-by pr-key wl)
                :let  [k    (pr-key entry)
                       snap (get state k)]]
            [(ui/hyperlink (:url entry) (ui/cyan k))
             (if-let [ca (:checked-at snap)]
               (ui/age-cell (Duration/between (Instant/parse ca) (Instant/now)))
               (ui/dim "—"))
             (status-label snap)
             (ui/green (or (:title snap) ""))]))))))

(defn- cmd-pick
  "Interactive entry for `mx prs watch` with no arguments: number the
  watchlist, prompt for a selection, and show that PR's latest state.
  Auto-selects when only one PR is watched."
  []
  (let [wl (read-watchlist)]
    (cond
      (empty? wl)
      (println "📭 Not watching any PRs. Add one with: mx prs watch <pr-url>")

      (= 1 (count wl))
      (cmd-detail (first wl))

      :else
      (let [sorted (vec (sort-by pr-key wl))
            state  (read-state)]
        (println "👀 Watched PRs:")
        (doseq [[i entry] (map-indexed vector sorted)
                :let [snap (get state (pr-key entry))]]
          (println (format "  %d) %s  %s  %s"
                           (inc i)
                           (ui/cyan (pr-key entry))
                           (status-label snap)
                           (ui/green (or (:title snap) "")))))
        (print (format "Select a PR [1-%d] (q to cancel): " (count sorted)))
        (flush)
        (let [in (str/trim (or (read-line) ""))]
          (cond
            (contains? #{"" "q" "quit"} in) (println "Cancelled.")
            (nil? (parse-long in))          (println "❌ Not a number.")
            (not (<= 1 (parse-long in) (count sorted))) (println "❌ Out of range.")
            :else (cmd-detail (nth sorted (dec (parse-long in))))))))))

(defn- cmd-rm
  "Remove a PR from the watchlist and drop its stored snapshot."
  [ref-str]
  (if-let [ref (parse-pr-ref ref-str)]
    (let [k   (pr-key ref)
          wl  (read-watchlist)
          wl' (vec (remove #(= k (pr-key %)) wl))]
      (if (= (count wl) (count wl'))
        (println (format "Not watching %s" k))
        (do
          (save-watchlist! wl')
          (save-state! (dissoc (read-state) k))
          (println (format "🗑️  Stopped watching %s" k)))))
    (usage)))

(defn- cmd-tick
  "Check every watched PR once: notify on changes, persist fresh
  snapshots, and drop merged/closed PRs. A no-op when nothing is
  watched. Invoked by the launchd agent."
  []
  (let [wl (read-watchlist)]
    (when (seq wl)
      (require-gh!)
      (log-info (format "Checking %d watched PR(s)" (count wl)))
      (let [old-state (read-state)
            outcomes  (doall (map #(check-pr old-state %) wl))
            removed   (set (keep #(when (:remove? %) (:key %)) outcomes))
            new-state (reduce (fn [m {:keys [key snapshot error remove?]}]
                                (cond
                                  error   m
                                  remove? (dissoc m key)
                                  :else   (assoc m key snapshot)))
                              old-state outcomes)
            new-wl    (filterv #(not (contains? removed (pr-key %))) wl)]
        (save-state! new-state)
        (save-watchlist! new-wl)
        (log-info "Tick complete")))))

(defn- ensure-agent!
  "Install (from the repo template) and load the launchd agent if it is
  not already present and running. Idempotent."
  []
  (let [dest (str home "/Library/LaunchAgents/" agent-label ".plist")]
    (when-not (fs/exists? dest)
      (let [template (str (fs/parent (fs/parent mx-root)) "/launchd/" agent-label ".plist")]
        (fs/create-dirs (fs/parent dest))
        (spit dest (str/replace (slurp template) "__HOME__" home))
        (log-info "Installed launchd agent")))
    (when-not (agent-loaded?)
      (p/shell "launchctl" "load" (str dest))
      (log-info "Loaded launchd agent"))))

(defn- fetch-pr
  "Fetch a PR's JSON via `gh pr view`."
  [url]
  (-> (p/process "gh" "pr" "view" url "--json" gh-json-fields)
      p/check
      :out
      slurp
      (json/parse-string true)))

(defn- format-comment
  "One-line rendering of a PR comment: author, relative time, snippet."
  [c]
  (let [login (get-in c [:author :login] "?")
        when* (if-let [ca (:createdAt c)]
                (str (ui/humanize (Duration/between (Instant/parse ca) (Instant/now))) " ago")
                "")
        body  (-> (or (:body c) "") (str/replace #"\s+" " ") str/trim (truncate 100))]
    (format "     %s %s: %s" (ui/cyan (str "@" login)) (ui/dim (str "(" when* ")")) body)))

(defn- log-error
  [msg]
  (binding [*out* *err*] (println (format "[mx prs watch] ERROR %s" msg))))

(defn- log-info
  [msg]
  (binding [*out* *err*] (println (format "[mx prs watch] %s" msg))))

(defn- notify-pr!
  "Fire a macOS notification for a PR's changes, click-to-open the PR."
  [entry pr changes]
  (let [k (pr-key entry)]
    (-> (p/process "terminal-notifier"
                   "-title" (truncate (:title pr) 50)
                   "-subtitle" k
                   "-message" (str/join " · " changes)
                   "-open" (:url pr)
                   "-sound" "default"
                   "-group" (str "mx-prs-" (str/replace k #"[/#]" "-")))
        p/check)))

(defn- now-iso [] (str (Instant/now)))

(defn- pr-key
  "Stable `owner/repo#number` key for a watchlist entry."
  [{:keys [owner repo number]}]
  (format "%s/%s#%d" owner repo number))

(defn- read-json
  ([path default] (read-json path default true))
  ([path default keywordize?]
   (if (fs/exists? path)
     (json/parse-string (slurp path) keywordize?)
     default)))

(defn- read-state
  "State keyed by the `owner/repo#number` string, with each snapshot's
  inner keys parsed as keywords."
  []
  (update-vals (read-json state-file {} false)
               #(reduce-kv (fn [m k v] (assoc m (keyword k) v)) {} %)))

(defn- read-watchlist [] (vec (read-json watchlist-file [])))

(defn- require-gh!
  "Abort with an error unless the `gh` CLI is on PATH."
  []
  (when-not (fs/which "gh")
    (log-error "the GitHub CLI (`gh`) was not found on PATH — install it and authenticate with `gh auth login`")
    (System/exit 1)))

(defn- save-state! [data] (write-json! state-file data))

(defn- save-watchlist! [data] (write-json! watchlist-file data))

(defn- status-label
  "Compact status glyphs for a snapshot, for `list`."
  [snap]
  (->> [(when (= "MERGED" (:state snap)) "merged")
        (when (= "CLOSED" (:state snap)) "closed")
        (get {"passing" "✅" "failing" "❌" "running" "🔄"} (:checks snap))
        (when (= "CONFLICTING" (:mergeable snap)) "⚠️")
        (get {"APPROVED" "approved" "CHANGES_REQUESTED" "changes-req"} (:review-decision snap))]
       (remove nil?)
       (str/join " ")))

(defn- truncate
  [s n]
  (if (> (count s) n) (str (subs s 0 (dec n)) "…") s))

(defn- usage
  []
  (println "Usage: mx prs watch                Pick a watched PR and show its latest state")
  (println "       mx prs watch <pr-url>       Watch a PR for updates")
  (println "       mx prs watch list           List watched PRs")
  (println "       mx prs watch rm <pr-url>    Stop watching a PR")
  (println "       mx prs watch tick           Check now (run by launchd)"))

(defn- write-json!
  [path data]
  (fs/create-dirs (fs/parent path))
  (spit path (json/generate-string data {:pretty true})))

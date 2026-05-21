#!/usr/bin/env bb

(ns mx.commands.focus
  (:require [babashka.process :as p]
            [cheshire.core :as json]
            [clojure.string :as str]
            [clojure.tools.cli :as cli])
  (:import [java.time LocalDate LocalDateTime]
           [java.time.format DateTimeFormatter]
           [java.time.temporal ChronoUnit]))

;; ---------------------------------------------------------------------------
;; CLI
;; ---------------------------------------------------------------------------

(def cli-opts
  [["-h" "--help" "Print this help text"]])

(def subcommands
  {"fetch-latest" {:desc "Fetch from all sources and update the focus dashboard"}
   "next"         {:desc "Show prioritized next actions from the dashboard"}
   "tui"          {:desc "Interactive dashboard TUI (runs in alt-screen)"}})

;; ---------------------------------------------------------------------------
;; Config
;; ---------------------------------------------------------------------------

(def org-root (str (System/getProperty "user.home") "/org/logseq"))
(def dashboard-path (str org-root "/pages/Focus Dashboard.md"))
(def journal-dir (str org-root "/journals"))

(def slack-op-ref "op://Private/Slack Focus Dashboard Token/credential")

(def github-orgs
  "GitHub orgs to search for PRs"
  ["spiff-emu"])

;; ---------------------------------------------------------------------------
;; Helpers
;; ---------------------------------------------------------------------------

(declare fetch-latest next-actions show-help)

(defn today-str []
  (.format (LocalDate/now) (DateTimeFormatter/ofPattern "yyyy-MM-dd")))

(defn journal-filename []
  (.format (LocalDate/now) (DateTimeFormatter/ofPattern "yyyy_MM_dd")))

(defn now-timestamp []
  (.format (LocalDateTime/now) (DateTimeFormatter/ofPattern "HH:mm")))

(defn days-ago [iso-str]
  (when iso-str
    (let [created (.parse DateTimeFormatter/ISO_DATE_TIME iso-str)
          date (LocalDate/from created)]
      (.between ChronoUnit/DAYS date (LocalDate/now)))))

(defn run-gh [& args]
  (let [result (apply p/process {:out :string :err :string} "gh" args)
        checked (p/check result)]
    (json/parse-string (str/trim (:out checked)) true)))

(defn run-gh-raw [& args]
  (let [result (apply p/process {:out :string :err :string} "gh" args)]
    (str/trim (:out (p/check result)))))

;; ---------------------------------------------------------------------------
;; GitHub Fetchers
;; ---------------------------------------------------------------------------

(defn fetch-authored-prs []
  (let [prs (run-gh "search" "prs" "--author=@me" "--state=open"
                    "--json" "number,title,repository,url,createdAt,isDraft"
                    "--limit" "50")]
    (mapv (fn [pr]
            (let [repo (get-in pr [:repository :nameWithOwner])
                  num (:number pr)]
              (try
                (let [detail (run-gh "pr" "view" (str num) "--repo" repo
                                     "--json" "reviewDecision,statusCheckRollup")
                      rollup (or (:statusCheckRollup detail) [])]
                  (assoc pr
                         :reviewDecision (:reviewDecision detail)
                         :statusCheckRollup rollup))
                (catch Exception _
                  (assoc pr :reviewDecision nil :statusCheckRollup [])))))
          prs)))

(defn fetch-review-requests []
  (run-gh "search" "prs" "--review-requested=@me" "--state=open"
          "--json" "number,title,author,repository,url,createdAt"
          "--limit" "50"))

(defn pr-age-label [created-at]
  (let [age (days-ago created-at)]
    (cond
      (nil? age) ""
      (< age 1) "today"
      (= age 1) "1d"
      :else (str age "d"))))

(defn review-status-label [decision]
  (case decision
    "APPROVED" "approved"
    "CHANGES_REQUESTED" "changes-requested"
    "REVIEW_REQUIRED" "needs-review"
    "pending"))

(defn ci-status-label [rollup]
  (let [states (map :state (or rollup []))]
    (cond
      (empty? states) "no-ci"
      (some #{"ERROR" "FAILURE"} states) "failing"
      (some #{"PENDING" "IN_PROGRESS" "QUEUED"} states) "running"
      (every? #{"SUCCESS"} states) "passing"
      :else "mixed")))

(defn format-authored-pr [pr]
  (let [{:keys [number title repository url createdAt reviewDecision statusCheckRollup isDraft]} pr
        repo (:nameWithOwner repository)
        age (pr-age-label createdAt)
        review (review-status-label reviewDecision)
        ci (ci-status-label statusCheckRollup)
        draft (if isDraft " DRAFT" "")]
    (format "  - [%s#%d](%s) — %s `%s` `%s` `%s`%s"
            repo number url title age review ci draft)))

(defn format-review-request [pr]
  (let [{:keys [number title author repository url createdAt]} pr
        repo (:nameWithOwner repository)
        age (pr-age-label createdAt)
        author-name (:login author)]
    (format "  - [%s#%d](%s) — %s (by @%s, %s old)"
            repo number url title author-name age)))

;; ---------------------------------------------------------------------------
;; Slack Fetcher
;; ---------------------------------------------------------------------------

(defn slack-token []
  (try
    (let [result (p/process {:out :string :err :string} "op" "read" slack-op-ref)
          out (str/trim (:out (p/check result)))]
      (when (not (str/blank? out)) out))
    (catch Exception _ nil)))

(defn slack-api [method params]
  (when-let [token (slack-token)]
    (let [url (str "https://slack.com/api/" method)
          query-str (->> params
                         (map (fn [[k v]] (str (name k) "=" (java.net.URLEncoder/encode (str v) "UTF-8"))))
                         (str/join "&"))
          full-url (str url "?" query-str)
          result (p/process {:out :string :err :string}
                            "curl" "-s" "-H" (str "Authorization: Bearer " token) full-url)
          body (json/parse-string (str/trim (:out (p/check result))) true)]
      (when (:ok body)
        body))))

(defn fetch-slack-unreads []
  (when (slack-token)
    (let [resp (slack-api "conversations.list"
                          {:types "im,mpim"
                           :exclude_archived true
                           :limit 50})]
      (->> (:channels resp)
           (filter :is_im)
           (filter #(pos? (or (:unread_count_display %) 0)))
           (map (fn [ch]
                  (let [msgs (slack-api "conversations.history"
                                        {:channel (:id ch) :limit 3})
                        latest (first (:messages msgs))
                        user-resp (slack-api "users.info" {:user (:user ch)})
                        username (get-in user-resp [:user :real_name] (:user ch))]
                    {:channel (:id ch)
                     :from username
                     :text (str/replace (or (:text latest) "") #"\n" " ")
                     :unread (:unread_count_display ch)})))
           (remove #(str/blank? (:text %)))))))

(defn fetch-slack-mentions []
  (when (slack-token)
    (let [resp (slack-api "search.messages"
                          {:query "to:me"
                           :sort "timestamp"
                           :sort_dir "desc"
                           :count 10})]
      (->> (get-in resp [:messages :matches])
           (take 5)
           (map (fn [msg]
                  {:channel (get-in msg [:channel :name])
                   :from (get-in msg [:username])
                   :text (str/replace (or (:text msg) "") #"\n" " ")
                   :permalink (:permalink msg)}))))))

(defn format-slack-dm [{:keys [from text unread]}]
  (let [preview (if (> (count text) 80)
                  (str (subs text 0 77) "...")
                  text)]
    (format "  - **%s** (%d unread) — %s" from unread preview)))

(defn format-slack-mention [{:keys [channel from text permalink]}]
  (let [preview (if (> (count text) 80)
                  (str (subs text 0 77) "...")
                  text)]
    (format "  - [#%s](%s) @%s — %s" channel (or permalink "") from preview)))

;; ---------------------------------------------------------------------------
;; Dashboard Writer
;; ---------------------------------------------------------------------------

(defn build-dashboard []
  (let [authored (fetch-authored-prs)
        reviews (fetch-review-requests)
        unreads (fetch-slack-unreads)
        mentions (fetch-slack-mentions)
        sections [(str "# Focus Dashboard\n")
                  (str "Last updated: " (today-str) " " (now-timestamp) "\n")
                  ;; PRs needing action
                  (str "## Review Requests\n")
                  (if (seq reviews)
                    (str/join "\n" (map format-review-request reviews))
                    "  - None")
                  ;; My authored PRs
                  (str "\n\n## My Open PRs\n")
                  (if (seq authored)
                    (str/join "\n" (map format-authored-pr authored))
                    "  - None")
                  ;; Slack
                  (when (seq unreads)
                    (str "\n\n## Slack — Unread DMs\n"
                         (str/join "\n" (map format-slack-dm unreads))))
                  (when (seq mentions)
                    (str "\n\n## Slack — Recent Mentions\n"
                         (str/join "\n" (map format-slack-mention mentions))))]]
    (str/join "\n" (remove nil? sections))))

(defn write-dashboard! [content]
  (spit dashboard-path content)
  (println (format "Updated %s" dashboard-path)))

(defn append-journal! [content]
  (let [path (str journal-dir "/" (journal-filename) ".md")
        timestamp (now-timestamp)
        block (str "\n- " timestamp " [[Focus Dashboard]] sync\n"
                   "\t- " (count (re-seq #"\[.*#\d+\]" content)) " open PRs tracked\n")
        existing (if (.exists (java.io.File. path))
                   (slurp path)
                   "")]
    (spit path (str existing block))
    (println (format "Appended to %s" path))))

;; ---------------------------------------------------------------------------
;; Subcommand: fetch-latest
;; ---------------------------------------------------------------------------

(defn fetch-latest [_opts]
  (println (str "Fetching focus data (" (today-str) " " (now-timestamp) ")..."))
  (let [content (build-dashboard)]
    (write-dashboard! content)
    (append-journal! content)
    (println "Done.")))

;; ---------------------------------------------------------------------------
;; Subcommand: next
;; ---------------------------------------------------------------------------

(def ansi-reset "\033[0m")
(def ansi-bold "\033[1m")
(def ansi-red "\033[31m")
(def ansi-yellow "\033[33m")
(def ansi-green "\033[32m")
(def ansi-cyan "\033[36m")
(def ansi-dim "\033[2m")

(defn bold [s] (str ansi-bold s ansi-reset))
(defn red [s] (str ansi-red s ansi-reset))
(defn yellow [s] (str ansi-yellow s ansi-reset))
(defn green [s] (str ansi-green s ansi-reset))
(defn cyan [s] (str ansi-cyan s ansi-reset))
(defn dim [s] (str ansi-dim s ansi-reset))

(defn parse-dashboard []
  (when (.exists (java.io.File. dashboard-path))
    (let [content (slurp dashboard-path)
          sections (str/split content #"\n## ")
          parse-section (fn [s]
                          (let [lines (str/split-lines s)
                                title (first lines)
                                items (->> (rest lines)
                                           (filter #(str/starts-with? (str/trim %) "- "))
                                           (map #(str/replace % #"^\s*- " "")))]
                            {:title title :items items}))]
      {:raw content
       :sections (map parse-section sections)})))

(defn strip-md-links [s]
  (str/replace s #"\[([^\]]+)\]\([^\)]+\)" "$1"))

(defn prioritize-items [dashboard]
  (let [sections (:sections dashboard)
        find-section (fn [pattern]
                       (->> sections
                            (filter #(re-find pattern (:title %)))
                            first
                            :items
                            (remove #(= "None" %))))
        review-reqs (find-section #"Review Requests")
        my-prs (find-section #"My Open PRs")
        unreads (find-section #"Unread DMs")
        mentions (find-section #"Mentions")
        recent-reviews (->> review-reqs
                            (filter #(re-find #"today|1d|2d|3d" (or % ""))))
        stale-reviews (->> review-reqs
                           (remove #(re-find #"today|1d|2d|3d" (or % ""))))]
    {:act-now (concat
               (map #(hash-map :type "review" :text (strip-md-links %)) recent-reviews)
               (when (seq unreads)
                 (map #(hash-map :type "slack-dm" :text (strip-md-links %)) unreads))
               (when (seq mentions)
                 (map #(hash-map :type "slack-mention" :text (strip-md-links %)) mentions))
               (->> my-prs
                    (filter #(re-find #"`changes-requested`" (or % "")))
                    (map #(hash-map :type "pr-fix" :text (strip-md-links %))))
               (->> my-prs
                    (filter #(and (re-find #"`failing`" (or % ""))
                                  (not (re-find #"DRAFT" (or % "")))))
                    (map #(hash-map :type "pr-fix" :text (strip-md-links %)))))
     :backlog (when (seq stale-reviews)
                (map #(hash-map :type "review-stale" :text (strip-md-links %)) stale-reviews))
     :monitor (->> my-prs
                   (filter #(or (re-find #"`running`|`pending`" (or % ""))
                                (and (re-find #"`needs-review`" (or % ""))
                                     (re-find #"`passing`" (or % "")))))
                   (map #(hash-map :type "pr-waiting" :text (strip-md-links %))))
     :healthy (->> my-prs
                   (filter #(re-find #"`approved`.*`passing`" (or % "")))
                   (map #(hash-map :type "pr-ready" :text (strip-md-links %))))
     :drafts (->> my-prs
                  (filter #(re-find #"DRAFT" (or % "")))
                  (map #(hash-map :type "pr-draft" :text (strip-md-links %))))}))

(defn print-category [label color items]
  (when (seq items)
    (println)
    (println (color (bold label)))
    (doseq [item items]
      (let [prefix (case (:type item)
                     "review" "👀"
                     "review-stale" "👀"
                     "slack-dm" "💬"
                     "slack-mention" "📣"
                     "pr-fix" "🔧"
                     "pr-waiting" "⏳"
                     "pr-ready" "🚀"
                     "pr-draft" "📝"
                     "•")]
        (println (str "  " prefix " " (:text item)))))))

(defn next-actions [_opts]
  (if-let [dashboard (parse-dashboard)]
    (let [{:keys [act-now backlog monitor healthy drafts]} (prioritize-items dashboard)
          updated (second (re-find #"Last updated: (.+)" (:raw dashboard)))]
      (println (bold "Focus Dashboard"))
      (println (dim (str "Last sync: " (or updated "unknown"))))
      (print-category "ACT NOW" red act-now)
      (print-category "WAITING ON OTHERS" yellow monitor)
      (print-category "READY TO MERGE" green healthy)
      (print-category "STALE REVIEWS (>3d)" yellow backlog)
      (print-category "MY DRAFTS" cyan drafts)
      (when (and (empty? act-now) (empty? monitor) (empty? healthy))
        (println)
        (println (green "All clear — nothing urgent."))))
    (do
      (println (red "No dashboard found. Run `mx focus fetch-latest` first."))
      (System/exit 1))))

;; ---------------------------------------------------------------------------
;; Main
;; ---------------------------------------------------------------------------

(defn show-help []
  (println "mx focus — Attention management dashboard")
  (println)
  (println "Usage: mx focus <subcommand>")
  (println)
  (println "Subcommands:")
  (doseq [[cmd {:keys [desc]}] (sort subcommands)]
    (println (format "  %-15s %s" cmd desc)))
  (println)
  (println "Options:")
  (println "  -h, --help    Show this help text"))

(def mx-root (str (System/getProperty "user.home") "/code/src/utils/dotfiles/lib/mx"))

(defn launch-tui [_opts]
  (let [result (p/process {:inherit true :dir mx-root}
                          "bb" (str mx-root "/commands/focus_tui.clj"))]
    (-> result p/check :exit)))

(defn main [& args]
  (let [{:keys [options arguments]} (cli/parse-opts args cli-opts)
        subcmd (first arguments)]
    (cond
      (:help options) (show-help)
      (= subcmd "fetch-latest") (fetch-latest options)
      (= subcmd "next") (next-actions options)
      (= subcmd "tui") (launch-tui options)
      :else (show-help))))

(apply main *command-line-args*)

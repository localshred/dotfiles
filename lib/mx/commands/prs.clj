#!/usr/bin/env bb

(ns mx.commands.prs
  (:require [babashka.process :as p]
            [cheshire.core :as json]
            [clojure.string :as str]
            [clojure.tools.cli :as cli])
  (:import [java.time Duration Instant]))

(load-file (str (or (System/getenv "MX_ROOT")
                    (str (System/getProperty "user.home") "/code/src/utils/dotfiles/lib/mx"))
                "/lib/ui.clj"))
(require '[mx.ui :as ui])

;; CLI options
(def cli-opts
  [["-r" "--reviews" "Show PRs requesting your review instead of your authored PRs"]
   ["-v" "--verbose" "Show detailed check status for PRs"]
   ["-h" "--help" "Print this help text"]])

;; Regex pattern for checks to ignore
(def ignored-checks-pattern #"(?i)snyk")

;; Status priority for sorting (lower number = higher priority)
(def status-priority
  "Priority mapping for check status sorting"
  {"PENDING" 1
   "IN_PROGRESS" 1
   "QUEUED" 1
   "ERROR" 2
   "FAILURE" 2
   "SUCCESS" 3
   "SKIPPED" 4
   "CANCELLED" 4})

(def status-symbol
  "Visual symbols for GitHub Actions states"
  {"SUCCESS" "✅"
   "ERROR" "❌"
   "FAILURE" "❌"
   "CANCELLED" "🚫"
   "SKIPPED" "⏭️"
   "PENDING" "🔄"
   "IN_PROGRESS" "🔄"
   "QUEUED" "⏳"})

(declare age-cell format-pr-compact format-pr-verbose format-review-request get-authenticated-user
         get-checks-status get-pr-checks get-review-requests parse-args run-gh sort-checks task)

(defn age-cell
  "Colored age label for a PR's open time, from a gh ISO-8601 timestamp."
  [iso]
  (ui/age-cell (Duration/between (Instant/parse iso) (Instant/now))))

(defn format-check
  "Format a single check result"
  [check]
  (let [{:keys [name state workflow]} check
        symbol (get status-symbol state "❓")
        workflow-text (if (and workflow (not (str/blank? workflow)))
                        (format " (%s)" workflow)
                        "")]
    (format "  %s %s%s" symbol name workflow-text)))

(defn get-checks-status
  "Get overall status symbol for PR checks"
  [checks]
  (let [states (map :state checks)]
    (cond
      (empty? states) ""
      (some #{"ERROR" "FAILURE"} states) "❌"
      (some #{"PENDING" "IN_PROGRESS" "QUEUED"} states) "🔄"
      (every? #{"SUCCESS"} states) "✅"
      :else "")))

(defn format-pr-compact
  "Build a compact table row: repo#num (linked), age, check status, title."
  [pr]
  (let [{:keys [number title repository url createdAt]} pr
        repo-name (:nameWithOwner repository)
        checks (->> (get-pr-checks repo-name number)
                    (remove #(re-find ignored-checks-pattern (:name %))))
        status (get-checks-status checks)
        repo-id (format "%s#%d" repo-name number)]
    [(ui/hyperlink url (ui/cyan repo-id)) (age-cell createdAt) status (ui/green title)]))

(defn format-pr-verbose
  "Format a PR with detailed checks"
  [pr]
  (let [{:keys [number title author repository url createdAt]} pr
        repo-name (:nameWithOwner repository)
        checks (->> (get-pr-checks repo-name number)
                    (remove #(re-find ignored-checks-pattern (:name %)))
                    (sort-checks))
        grouped-checks (group-by :state checks)]
    (println (format "\n🔀 %s" (ui/hyperlink url (format "PR #%d: %s" number title))))
    (println (format "   📦 %s" repo-name))
    (println (format "   👤 %s" (:login author)))
    (println (format "   🕐 opened %s ago" (age-cell createdAt)))
    (println (format "   🔗 %s" (ui/hyperlink url url)))

    (if (empty? checks)
      (println "   ℹ️  No checks found")
      (do
        (println "   📊 Checks:")

        ;; Show pending/in-progress first
        (doseq [state ["PENDING" "IN_PROGRESS" "QUEUED"]]
          (when-let [state-checks (get grouped-checks state)]
            (doseq [check state-checks]
              (println (format-check check)))))

        ;; Show errors/failures next
        (doseq [state ["ERROR" "FAILURE"]]
          (when-let [state-checks (get grouped-checks state)]
            (doseq [check state-checks]
              (println (format-check check)))))

        ;; Collapse successful checks into one line
        (when-let [success-checks (get grouped-checks "SUCCESS")]
          (let [count (count success-checks)]
            (println (format "  ✅ %d Actions Succeeded" count))))

        ;; Show skipped/cancelled last
        (doseq [state ["SKIPPED" "CANCELLED"]]
          (when-let [state-checks (get grouped-checks state)]
            (doseq [check state-checks]
              (println (format-check check)))))))))

(defn format-review-request
  "Build a review-request table row: repo#num (linked), age, author, title."
  [pr]
  (let [{:keys [number title author repository url createdAt]} pr
        repo-name (:nameWithOwner repository)
        repo-id (format "%s#%d" repo-name number)
        author-name (format "@%s" (:login author))]
    [(ui/hyperlink url (ui/cyan repo-id)) (age-cell createdAt) (ui/yellow author-name) (ui/green title)]))

(defn get-authenticated-user
  "Get the currently authenticated GitHub user"
  []
  (-> (p/process "gh" "api" "user" "--jq" ".login")
      (p/check)
      :out
      slurp))

(defn get-open-prs
  "Get all open PRs authored by me across all repositories"
  []
  (run-gh "search" "prs" "--author=@me" "--state=open"
          "--json" "number,title,author,repository,url,createdAt" "--limit" "50"))

(defn get-review-requests
  "Get all open PRs requesting my review across all repositories"
  []
  (run-gh "search" "prs" "--review-requested=@me" "--state=open"
          "--json" "number,title,author,repository,url,createdAt" "--limit" "50"))

(defn get-pr-checks
  "Get GitHub Actions status for a specific PR in a repository"
  [repo-name pr-number]
  (try
    (run-gh "pr" "checks" (str pr-number) "--repo" repo-name
            "--json" "name,state,link,workflow")
    (catch Exception _
      [])))

(defn parse-args
  "Parse CLI arguments and return task key and options"
  [args]
  (let [{:keys [options]} (cli/parse-opts args cli-opts)
        task-key (cond
                   (:reviews options) :show-review-requests
                   :else              :show-authored-prs)]
    {:task task-key :options options}))

(defmulti task :task)

(defmethod task :show-authored-prs
  [{:keys [options]}]
  (let [username (str/trim (get-authenticated-user))
        verbose? (:verbose options)]
    (println (format "🔍 Fetching open PRs for %s...\n" (ui/cyan (str "@" username))))
    (let [prs (get-open-prs)
          sorted-prs (sort-by :createdAt prs)]
      (if (empty? sorted-prs)
        (println "📭 No open PRs found authored by you.")
        (do
          (println (format "📋 Found %d open PR(s):" (count sorted-prs)))
          (if verbose?
            (doseq [pr sorted-prs] (format-pr-verbose pr))
            (ui/print-table (map format-pr-compact sorted-prs)))
          (println))))))

(defmethod task :show-review-requests
  [_]
  (let [username (str/trim (get-authenticated-user))]
    (println (format "👀 Fetching review requests for %s...\n" (ui/cyan (str "@" username))))
    (let [prs (get-review-requests)
          sorted-prs (sort-by :createdAt prs)]
      (if (empty? sorted-prs)
        (println "📭 No review requests found.")
        (do
          (println (format "📋 Found %d review request(s):" (count sorted-prs)))
          (ui/print-table (map format-review-request sorted-prs))
          (println))))))

(defn main
  "Main function to display PR statuses"
  [& args]
  (task (parse-args args)))

(defn run-gh
  "Run gh CLI command and return parsed JSON output"
  [& args]
  (-> (apply p/process "gh" args)
      (p/check)
      :out
      slurp
      (json/parse-string true)))

(defn sort-checks
  "Sort checks by status priority, then alphabetically by name"
  [checks]
  (sort-by (juxt #(get status-priority (:state %) 5) #(str/lower-case (:name %))) checks))

;; Run the script
(apply main *command-line-args*)

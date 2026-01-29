#!/usr/bin/env bb

(ns mx.commands.prs
  (:require [babashka.process :as p]
            [cheshire.core :as json]
            [clojure.string :as str]
            [clojure.tools.cli :as cli]))

;; CLI options
(def cli-opts
  [["-r" "--reviews" "Show PRs requesting your review instead of your authored PRs"]
   ["-h" "--help" "Print this help text"]])

;; ANSI color codes
(def ansi-reset "\033[0m")
(def ansi-cyan "\033[36m")
(def ansi-yellow "\033[33m")
(def ansi-green "\033[32m")
(def ansi-blue "\033[34m")

;; Color helper functions
(defn blue [s] (str ansi-blue s ansi-reset))
(defn cyan [s] (str ansi-cyan s ansi-reset))
(defn green [s] (str ansi-green s ansi-reset))
(defn yellow [s] (str ansi-yellow s ansi-reset))

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

(declare format-review-request get-authenticated-user get-pr-checks get-review-requests parse-args run-gh sort-checks task)

(defn format-check
  "Format a single check result"
  [check]
  (let [{:keys [name state workflow]} check
        symbol (get status-symbol state "❓")
        workflow-text (if (and workflow (not (str/blank? workflow)))
                        (format " (%s)" workflow)
                        "")]
    (format "  %s %s%s" symbol name workflow-text)))

(defn format-pr
  "Format a PR with its checks"
  [pr]
  (let [{:keys [number title author repository url]} pr
        repo-name (:nameWithOwner repository)
        checks (->> (get-pr-checks repo-name number)
                    (remove #(re-find ignored-checks-pattern (:name %)))
                    (sort-checks))
        grouped-checks (group-by :state checks)]
    (println (format "\n🔀 PR #%d: %s" number title))
    (println (format "   📦 %s" repo-name))
    (println (format "   👤 %s" (:login author)))
    (println (format "   🔗 %s" url))

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
  "Format a PR review request"
  [pr]
  (let [{:keys [number title author repository url]} pr
        repo-name (:nameWithOwner repository)
        repo-id (format "%s#%d" repo-name number)
        author-name (format "@%s" (:login author))]
    (println (str/join "\t" [(cyan repo-id)
                             (yellow author-name)
                             (green title)
                             (blue url)]))))

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
          "--json" "number,title,author,repository,url" "--limit" "50"))

(defn get-review-requests
  "Get all open PRs requesting my review across all repositories"
  []
  (run-gh "search" "prs" "--review-requested=@me" "--state=open"
          "--json" "number,title,author,repository,url" "--limit" "50"))

(defn get-pr-checks
  "Get GitHub Actions status for a specific PR in a repository"
  [repo-name pr-number]
  (try
    (run-gh "pr" "checks" (str pr-number) "--repo" repo-name
            "--json" "name,state,link,workflow")
    (catch Exception _
      [])))

(defn parse-args
  "Parse CLI arguments and return task key"
  [args]
  (let [{:keys [options]} (cli/parse-opts args cli-opts)]
    (cond
      (:reviews options) :show-review-requests
      :else              :show-authored-prs)))

(defmulti task identity)

(defmethod task :show-authored-prs
  [_]
  (let [username (str/trim (get-authenticated-user))]
    (println (format "🔍 Fetching open PRs for %s...\n" (cyan (str "@" username))))
    (let [prs (get-open-prs)]
      (if (empty? prs)
        (println "📭 No open PRs found authored by you.")
        (do
          (println (format "📋 Found %d open PR(s):" (count prs)))
          (doseq [pr prs]
            (format-pr pr))
          (println))))))

(defmethod task :show-review-requests
  [_]
  (let [username (str/trim (get-authenticated-user))]
    (println (format "👀 Fetching review requests for %s...\n" (cyan (str "@" username))))
    (let [prs (get-review-requests)
          sorted-prs (sort-by (juxt #(str/lower-case (get-in % [:repository :nameWithOwner]))
                                :number)
                       prs)]
      (if (empty? sorted-prs)
        (println "📭 No review requests found.")
        (do
          (println (format "📋 Found %d review request(s):" (count sorted-prs)))
          (doseq [pr sorted-prs]
            (format-review-request pr))
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

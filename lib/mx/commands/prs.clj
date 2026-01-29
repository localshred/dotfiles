#!/usr/bin/env bb

(ns mx.commands.prs
  (:require [babashka.process :as p]
            [cheshire.core :as json]
            [clojure.string :as str]))

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

(declare get-authenticated-user get-pr-checks run-gh sort-checks)

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

(defn get-pr-checks
  "Get GitHub Actions status for a specific PR in a repository"
  [repo-name pr-number]
  (try
    (run-gh "pr" "checks" (str pr-number) "--repo" repo-name
            "--json" "name,state,link,workflow")
    (catch Exception _
      [])))

(defn main
  "Main function to display PR statuses"
  []
  (let [username (str/trim (get-authenticated-user))]
    (println (format "🔍 Fetching open PRs for @%s...\n" username))

    (let [prs (get-open-prs)]
      (if (empty? prs)
        (println "📭 No open PRs found authored by you.")
        (do
          (println (format "📋 Found %d open PR(s):" (count prs)))
          (doseq [pr prs]
            (format-pr pr))
          (println))))))

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
(main)

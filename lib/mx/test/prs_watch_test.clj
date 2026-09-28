#!/usr/bin/env bb

;; Tests for the pure functions in lib/prs_watch.clj.
;; Run: bb test/prs_watch_test.clj  (from lib/mx)

(require '[babashka.fs :as fs])

(load-file (str (fs/parent (fs/parent (fs/absolutize *file*))) "/lib/prs_watch.clj"))
(require '[mx.prs-watch :as w])

(def failures (atom 0))

(defn check [desc actual expected]
  (if (= actual expected)
    (println "  ✓" desc)
    (do
      (swap! failures inc)
      (println "  ✗" desc)
      (println "      expected:" (pr-str expected))
      (println "      actual:  " (pr-str actual)))))

(defn snapshot [& {:as overrides}]
  (merge {:state "OPEN" :comments 0 :reviews 0 :mergeable "MERGEABLE"
          :review-decision "" :checks "passing"}
         overrides))

(println "parse-pr-ref")
(check "full URL"
       (w/parse-pr-ref "https://github.com/octo/repo/pull/42")
       {:owner "octo" :repo "repo" :number 42 :url "https://github.com/octo/repo/pull/42"})
(check "URL with trailing path"
       (select-keys (w/parse-pr-ref "https://github.com/octo/repo/pull/42/files") [:owner :repo :number])
       {:owner "octo" :repo "repo" :number 42})
(check "short form"
       (w/parse-pr-ref "octo/repo#42")
       {:owner "octo" :repo "repo" :number 42 :url "https://github.com/octo/repo/pull/42"})
(check "garbage → nil" (w/parse-pr-ref "not-a-pr") nil)
(check "nil → nil" (w/parse-pr-ref nil) nil)

(println "checks-summary")
(check "empty → none" (w/checks-summary []) "none")
(check "all success → passing"
       (w/checks-summary [{:status "COMPLETED" :conclusion "SUCCESS"}
                          {:state "SUCCESS"}]) "passing")
(check "any failure → failing"
       (w/checks-summary [{:status "COMPLETED" :conclusion "SUCCESS"}
                          {:status "COMPLETED" :conclusion "FAILURE"}]) "failing")
(check "in-progress → running"
       (w/checks-summary [{:status "IN_PROGRESS"}
                          {:status "COMPLETED" :conclusion "SUCCESS"}]) "running")

(println "compute-changes")
(check "no change → []" (w/compute-changes (snapshot) (snapshot)) [])
(check "new comments"
       (w/compute-changes (snapshot) (snapshot :comments 3)) ["💬 3 new comments"])
(check "one comment is singular"
       (w/compute-changes (snapshot) (snapshot :comments 1)) ["💬 1 new comment"])
(check "merged"
       (w/compute-changes (snapshot) (snapshot :state "MERGED")) ["🎉 Merged"])
(check "approved"
       (w/compute-changes (snapshot) (snapshot :review-decision "APPROVED")) ["✅ Approved"])
(check "changes requested"
       (w/compute-changes (snapshot) (snapshot :review-decision "CHANGES_REQUESTED"))
       ["🔴 Changes requested"])
(check "ci failing"
       (w/compute-changes (snapshot) (snapshot :checks "failing")) ["❌ CI failing"])
(check "new conflict"
       (w/compute-changes (snapshot) (snapshot :mergeable "CONFLICTING")) ["⚠️ Merge conflicts"])
(check "conflict resolved"
       (w/compute-changes (snapshot :mergeable "CONFLICTING") (snapshot :mergeable "MERGEABLE"))
       ["✅ Conflicts resolved"])
(check "review submitted without decision change"
       (w/compute-changes (snapshot) (snapshot :reviews 1)) ["👀 1 new review"])

(println "field-transitions")
(check "no change → []" (w/field-transitions (snapshot) (snapshot)) [])
(check "ci transition"
       (w/field-transitions (snapshot) (snapshot :checks "failing")) ["🔧 CI: passing → failing"])
(check "review transition uses labels"
       (w/field-transitions (snapshot) (snapshot :review-decision "APPROVED"))
       ["👀 Review: none → approved"])
(check "merge transition uses labels"
       (w/field-transitions (snapshot) (snapshot :mergeable "CONFLICTING"))
       ["🔀 Merge: mergeable → conflicting"])
(check "state transition"
       (w/field-transitions (snapshot) (snapshot :state "MERGED")) ["📦 State: open → merged"])

(println)
(if (pos? @failures)
  (do (println (format "%d failure(s)" @failures)) (System/exit 1))
  (println "All tests passed"))

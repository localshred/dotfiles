#!/usr/bin/env bb

(ns mx.commands.goto
  (:require
   [cheshire.core :as json]
   [clojure.java.io :as io]
   [clojure.java.shell :as shell]
   [clojure.string :as string]
   [clojure.tools.cli :as cli]))

(defn tap [x] (println x) x)

(defn stderr
  [x]
  (binding [*out* *err*]
    (tap x)))

(defn safe-lower-case
  [s]
  (when (some? s)
    (string/lower-case s)))

(defn not-blank?
  [s]
  (not (string/blank? s)))

(def provider?
  #{"github"})

(def cli-opts
  [["-u" "--user USER" "User or org to open"
    :parse-fn safe-lower-case]
   ["-r" "--repo REPO" "Repo to open"
    :parse-fn safe-lower-case]
   ["-i" "--issues" "Navigate to repo issues"]
   ["-p" "--pull-requests" "Navigate to repo pull requests"]
   ["-n" "--number N" "Issue or Pull Request number to open. Ignored unless paired with -p or -i."
    :parse-fn #(Integer/parseInt %1)]
   ["-s" "--scm" "SCM Provider. Currently supported providers: github"
    :parse-fn keyword
    :validate [provider? (format "Invalid SCM provider. Should be one of: %s"
                                 (string/join ", " (map name provider?)))]]
   ["-d" "--debug" "Enable debug logging"]
   ["-y" "--dry" "Debug and exit without opening the URL"]
   ["-h" "--help" "Print this help text"]])

(defmulti task (fn [{:keys [options errors]}]
                 (cond
                   (true? (:help options))         :help
                   (seq errors)                    :help
                   :else                           :goto-scm)))

;; {
;;   "l": {
;;     "repos": { "d": "dotfiles" },
;;     "scm": "github",
;;     "host": "https://some.other.github.com", # optional, defaults to github.com
;;     "user": "localshred"
;;   },
;; }
(defn- config-path
  [env-var-name]
  (or (when-let [dir (System/getenv env-var-name)]
        (str dir "/mx.goto.json"))
      (str (System/getenv "HOME") "/code/src/utils/" env-var-name "/mx.goto.json")))

(def personal-config-path
  (config-path "dotfiles"))

(def work-config-path
  (config-path "dotfiles_work"))

(defn- load-config [path]
  (when (and path (.exists (io/file path)))
    (-> path (io/reader) (json/parse-stream true))))

(def user-aliases
  (merge (load-config personal-config-path)
         (load-config work-config-path)))

(def repo-aliases
  (->> user-aliases
    (map (fn [[_ {:keys [user repos]}]] [user repos]))
    (into {})))

(defmulti scm-host :scm)

(defmethod scm-host "github"
  [options]
  (get-in options [:user :host] "https://github.com"))

(defmethod scm-host :default
  [options]
  (when (:debug options)
    (stderr repo-aliases))
  "https://github.com")

(defmulti build-url
  (fn [{:keys [scm user repo issues pull-requests number]
        :or   {scm "github"}}]
    (cond
      (and issues number)        [scm :issue]
      (and pull-requests number) [scm :pull]
      issues                     [scm :issues]
      pull-requests              [scm :pulls]
      repo                       [scm :repo]
      user                       [scm :user]
      :else                      :invalid-url)))

(defmethod build-url :invalid-url
  [options]
  (binding [*out* *err*]
    (println "Invalid options given:")
    (println options)
    nil))

(defmethod build-url ["github" :user]
  [{:keys [user] :as opts}]
  (format "%s/%s" (scm-host opts) (:user user)))

(defmethod build-url ["github" :repo]
  [{:keys [user repo] :as opts}]
  (format "%s/%s/%s" (scm-host opts) (:user user) repo))

(defmethod build-url ["github" :issues]
  [{:keys [user repo] :as opts}]
  (format "%s/%s/%s/issues" (scm-host opts) (:user user) repo))

(defmethod build-url ["github" :issue]
  [{:keys [user repo number] :as opts}]
  (format "%s/%s/%s/issues/%d" (scm-host opts) (:user user) repo number))

(defmethod build-url ["github" :pulls]
  [{:keys [user repo] :as opts}]
  (format "%s/%s/%s/pulls" (scm-host opts) (:user user) repo))

(defmethod build-url ["github" :pull]
  [{:keys [user repo number] :as opts}]
  (format "%s/%s/%s/pull/%d" (scm-host opts) (:user user) repo number))

(defn- update-user-from-alias
  "Fetches the aliased user (if present) and updates the :user and :scm keys.
  Will not overwrite the incoming :scm key if present."
  [options]
  (when (:debug options)
    (stderr {:user-aliases user-aliases}))
  (let [user-val (:user options)
        user-key (if (keyword? user-val) user-val (keyword user-val))]
    (if-let [aliased-user (get user-aliases user-key)]
      (cond-> options
        (:user aliased-user)   (assoc :user aliased-user)
        (and
          (not (provider? (:scm options)))
          (:scm aliased-user)) (assoc :scm (:scm aliased-user)))
      (update options :user #(hash-map :user (if (keyword? %) (name %) (str %)))))))

(defn- update-repo-from-user-aliases
  [{:keys [user repo] :as options}]
  (when (:debug options)
    (stderr {:repo-aliases repo-aliases}))
  (let [repo-key (if (keyword? repo) repo (keyword repo))]
    (if-let [aliased-repo (get-in repo-aliases [(:user user) repo-key])]
      (assoc options :repo aliased-repo)
      (update options :repo #(if (keyword? %) (name %) (str %))))))

(defn- parse-from-args
  [options arguments]
  (let [[user repo number] (string/split (string/join " " arguments) #"[\s\/#]+")]
    (cond-> options
      (some? user)     (assoc :user (keyword user))
      (some? repo)     (assoc :repo (keyword repo))
      (some? number)   (assoc :number (Integer/parseInt number) :issues (not (:pull-requests options)))
      (:debug options) (tap))))

(defmethod task :goto-scm
  [{:keys [arguments options] :as cli-parsed}]
  (when (:debug options)
    (stderr cli-parsed))
  (let [url (-> (if (seq arguments)
                  (parse-from-args options arguments)
                  options)
                (update-user-from-alias)
                (update-repo-from-user-aliases)
                (build-url))]
    (cond
      (:dry options)
      (println (format "[DRY] Goto URL %s" url))

      (not (nil? url))
      (do
        (println (format "Opening %s" url))
        (let [{:keys [exit out err]} (shell/sh "open" url)]
          (when (not-blank? out) (println out))
          (when (not-blank? err) (stderr err))
          (System/exit exit))))))

(defmethod task :help
  [{:keys [errors summary]}]
  (println "mx goto [OPTIONS]
  Navigate to SCM provider URLs for user, repo, issues, prs.

Usage:
  mx goto -h
  mx goto -y ...                    # Print URL and exit
  mx goto -d ...                    # Print Debug info while executing
  mx goto -u foo                    # navigate to https://github.com/foo
  mx goto -u foo -s gitlab          # navigate to https://gitlab.com/foo
  mx goto -u foo -r bar             # navigate to https://github.com/foo/bar
  mx goto -u foo -r bar -i          # navigate to https://github.com/foo/bar/issues
  mx goto -u foo -r bar -i -n 123   # navigate to https://github.com/foo/bar/issue/123
  mx goto -u foo -r bar -p          # navigate to https://github.com/foo/bar/pulls
  mx goto -u foo -r bar -p -n 456   # navigate to https://github.com/foo/bar/pull/456

Options:")
  (println summary)
  (when (seq errors)
    (println)
    (println "Errors:")
    (doseq [error errors]
      (println (str "  [!] " error)))
    (System/exit 1)))

(defn main
  "Main entry point for goto command"
  [& args]
  (task (cli/parse-opts args cli-opts)))

;; Run the script when called directly
(when (= *file* (System/getProperty "babashka.file"))
  (apply main *command-line-args*))

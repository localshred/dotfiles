#!/usr/bin/env bb

;; mx-desc: Pick/resume a saved claude session, or start a named new one

(ns mx.commands.claude
  (:require [babashka.fs :as fs]
            [babashka.process :as p]
            [clojure.string :as str])
  (:import [java.time Duration Instant]))

(load-file (str (or (System/getenv "MX_ROOT")
                    (str (System/getProperty "user.home") "/code/src/utils/dotfiles/lib/mx"))
                "/lib/ui.clj"))
(require '[mx.ui :as ui])

;;
;; Static defs
;;

(def projects-dir
  "Where Claude Code stores per-project session transcripts."
  (str (System/getProperty "user.home") "/.claude/projects"))

(def sessions-file
  "Curated `<name> <id> <cwd>` session list, one entry per line."
  (str (System/getProperty "user.home") "/.claude-sessions.txt"))

(def new-session-marker
  "Sentinel id for the leading New-session entry in the picker."
  "__NEW__")

(declare cmd-keep cmd-list cmd-pick cmd-prune cmd-scratch current-session-id fzf-pick gen-id
         launch-new! launch-resume! main new-session! parse-line print-help prompt read-sessions
         resume-or-replace! sanitize-name session-ages session-alive? session-line transcript-file
         write-sessions!)

;;
;; Public functions
;;

(defn cmd-keep
  "Save a session to the list under `name`. Defaults the id to the current
  session (newest transcript in this dir's project) and cwd to the current dir.

  Used to promote a scratch session once it's worth keeping."
  [args]
  (let [name (sanitize-name (first args))
        id (or (second args) (current-session-id))
        cwd (System/getProperty "user.dir")]
    (cond
      (str/blank? name) (println "❌ Usage: mx claude keep <name> [session-id]")
      (str/blank? id)   (println "❌ Could not determine the current session id.")
      :else
      (let [session {:name name :id id :cwd cwd}]
        (write-sessions! (conj (remove #(= (:name %) name) (read-sessions)) session))
        (println (format "💾 Saved %s → %s" (ui/cyan name) (ui/dim id)))))))

(defn cmd-list
  "Print the saved sessions alphabetically with start/update ages.

  Ages are recomputed live from each session's transcript file: `started`
  from its creation time, `updated` from its last-modified time."
  []
  (let [sessions (sort-by :name (read-sessions))]
    (if (empty? sessions)
      (println "📭 No saved sessions.")
      (ui/print-table
       (cons [(ui/dim "NAME") (ui/dim "STARTED") (ui/dim "UPDATED") (ui/dim "CWD") (ui/dim "ID")]
             (map (fn [{:keys [name id cwd]}]
                    (let [{:keys [created updated]} (session-ages id)]
                      [(ui/cyan name)
                       (if created (ui/dim (ui/humanize created)) (ui/dim "—"))
                       (if updated (ui/age-cell updated) (ui/dim "—"))
                       (ui/dim (if (str/blank? cwd) "—" cwd))
                       (ui/dim id)]))
                  sessions))))))

(defn cmd-pick
  "fzf-pick a saved session to resume, or the leading New-session entry to
  start a named new session."
  []
  (let [sessions (read-sessions)
        new-line (str "✨ New session\t" new-session-marker "\t\t\t")
        lines (cons new-line (map session-line sessions))
        picked (first (fzf-pick lines ["--prompt" "session> "]))]
    (cond
      (nil? picked) (println "❌ Nothing picked.")
      :else (let [{:keys [id] :as sel} (parse-line picked)]
              (if (= id new-session-marker)
                (new-session!)
                (launch-resume! sel))))))

(defn cmd-prune
  "Auto-remove sessions whose transcript is gone (reporting which), then offer
  an fzf multi-select to prune more of the survivors."
  []
  (let [sessions (read-sessions)
        {alive true dead false} (group-by #(boolean (session-alive? (:id %))) sessions)]
    (if (seq dead)
      (do (println "🧹 Auto-pruned (transcript gone):")
          (doseq [s dead] (println (format "   %s" (ui/dim (:name s))))))
      (println "✅ No dead sessions to auto-prune."))
    (write-sessions! alive)
    (if (empty? alive)
      (println "📭 No sessions remain.")
      (let [picked (->> (fzf-pick (map session-line alive)
                                  ["--multi" "--prompt" "prune (tab=mark)> "])
                        (map (comp :id parse-line))
                        set)]
        (if (empty? picked)
          (println "👍 Kept all.")
          (let [kept (remove #(picked (:id %)) alive)]
            (write-sessions! kept)
            (println "🧹 Pruned:")
            (doseq [s alive :when (picked (:id s))]
              (println (format "   %s" (ui/dim (:name s)))))))))))

(defn cmd-scratch
  "Launch a throwaway claude session: no name, no saved entry."
  []
  (println "🚀 Starting scratch session...")
  @(p/process {:inherit true} "claude"))

(defn main
  "Route to a subcommand, defaulting to the session picker."
  [& args]
  (let [sub (first args)]
    (cond
      (#{"-h" "--help"} sub)      (print-help)
      (= sub "keep")              (cmd-keep (rest args))
      (= sub "list")              (cmd-list)
      (= sub "scratch")           (cmd-scratch)
      (= sub "prune")             (cmd-prune)
      :else                       (cmd-pick))))

(defn print-help
  "Print usage covering the picker and prune subcommand."
  []
  (println "Usage: mx claude [list | scratch | keep <name> [id] | prune]")
  (println)
  (println "Default (no subcommand): pick a saved session to resume, or start")
  (println "a new named session (first entry). New sessions are saved with a")
  (println "pre-generated id so they can be resumed later.")
  (println)
  (println "Subcommands:")
  (println "  list          Print saved sessions in alphabetical order")
  (println "  scratch       Launch a throwaway session, unsaved")
  (println "  keep <name>   Save the current session under <name> (promote a scratch)")
  (println "  prune         Auto-remove dead sessions, then multi-select to prune more")
  (println)
  (println (ui/dim (str "Session list: " sessions-file))))

;;
;; Private functions
;;

(defn- current-session-id
  "Best-guess current session id: the newest transcript in the project dir for
  the current working directory. The active session's transcript is written
  continuously, so it sorts newest."
  []
  (let [encoded (str/replace (System/getProperty "user.dir") #"[^A-Za-z0-9]" "-")
        dir (str projects-dir "/" encoded)
        files (when (fs/directory? dir) (fs/glob dir "*.jsonl"))]
    (when (seq files)
      (-> (apply max-key #(.toMillis (fs/last-modified-time %)) files)
          fs/file-name
          (str/replace #"\.jsonl$" "")))))

(defn- fzf-pick
  "Run fzf over `lines`, showing only name and cwd, and return the selected
  raw lines (empty on cancel). fzf draws its UI on the tty."
  [lines opts]
  (let [args (into ["fzf" "--height" "40%" "--reverse" "--delimiter" "\t" "--with-nth" "1,4,5,3"]
                   opts)
        {:keys [exit out]} @(p/process args {:in (str/join "\n" lines) :out :string :err :inherit})]
    (if (zero? exit)
      (->> (str/split-lines (str/trim out)) (remove str/blank?))
      [])))

(defn- gen-id
  "Fresh session id (UUID string) for a new session."
  []
  (str (random-uuid)))

(defn- launch-new!
  "Launch a new claude session with a fixed id and display name, in `cwd`."
  [{:keys [id name cwd]}]
  (println (format "🚀 Starting %s..." (ui/cyan name)))
  @(p/process {:inherit true :dir cwd} "claude" "--session-id" id "--name" name))

(defn- launch-resume!
  "Resume a saved session, cd-ing to its recorded cwd when present."
  [{:keys [id name cwd]}]
  (println (format "🚀 Resuming %s..." (ui/cyan name)))
  @(p/process {:inherit true :dir (if (str/blank? cwd) (System/getProperty "user.dir") cwd)}
              "claude" "--resume" id))

(defn- new-session!
  "Prompt for a name and start a new session, handling name collisions by
  offering to reopen the existing session or overwrite it."
  []
  (let [name (sanitize-name (prompt "Session name"))
        cwd (System/getProperty "user.dir")]
    (cond
      (str/blank? name) (println "❌ Cancelled (empty name).")
      :else
      (if-let [existing (first (filter #(= (:name %) name) (read-sessions)))]
        (resume-or-replace! existing cwd)
        (let [session {:name name :id (gen-id) :cwd cwd}]
          (write-sessions! (conj (read-sessions) session))
          (launch-new! session))))))

(defn- parse-line
  "Parse a tab-delimited picker line back into a `{:name :id :cwd}` map.

  Trailing display-only columns (ages) are ignored."
  [line]
  (let [[name id cwd] (str/split line #"\t")]
    {:name name :id id :cwd (or cwd "")}))

(defn- prompt
  "Print a prompt and return the trimmed line the user types."
  [msg]
  (print (str msg ": "))
  (flush)
  (some-> (read-line) str/trim))

(defn- read-sessions
  "Parse the session file into `{:name :id :cwd}` maps, skipping bad lines."
  []
  (if-not (fs/exists? sessions-file)
    []
    (->> (str/split-lines (slurp sessions-file))
         (remove str/blank?)
         (keep (fn [line]
                 (let [[name id cwd] (str/split (str/trim line) #"\s+" 3)]
                   (when (and name id) {:name name :id id :cwd (or cwd "")}))))
         vec)))

(defn- resume-or-replace!
  "On a name collision, ask whether to reopen the existing session or overwrite
  it with a fresh session in `cwd`."
  [existing cwd]
  (case (str/lower-case (or (prompt "Name exists — [r]eopen / [o]verwrite / [c]ancel") ""))
    ("r" "reopen") (launch-resume! existing)
    ("o" "overwrite")
    (let [session {:name (:name existing) :id (gen-id) :cwd cwd}]
      (write-sessions! (conj (remove #(= (:name %) (:name existing)) (read-sessions)) session))
      (launch-new! session))
    (println "❌ Cancelled.")))

(defn- sanitize-name
  "Trim and collapse internal whitespace to hyphens to keep the file parseable."
  [name]
  (some-> name str/trim (str/replace #"\s+" "-")))

(defn- session-ages
  "Live `{:created :updated}` Durations (from now) for a session's transcript,
  derived from the file's creation and last-modified times. nil when the
  transcript is gone."
  [id]
  (when-let [f (transcript-file id)]
    (let [now (Instant/now)]
      {:created (Duration/between (.toInstant (fs/creation-time f)) now)
       :updated (Duration/between (.toInstant (fs/last-modified-time f)) now)})))

(defn- session-alive?
  "True when a transcript `<id>.jsonl` exists under any project dir."
  [id]
  (some? (transcript-file id)))

(defn- session-line
  "Tab-delimited picker line: `name<TAB>id<TAB>cwd<TAB>started<TAB>updated`.

  Ages are display-only; `parse-line` reads back only name/id/cwd."
  [{:keys [name id cwd]}]
  (let [{:keys [created updated]} (session-ages id)]
    (str/join "\t" [name id cwd
                    (if created (ui/humanize created) "—")
                    (if updated (ui/humanize updated) "—")])))

(defn- transcript-file
  "Path to a session's `<id>.jsonl` transcript under any project dir, or nil."
  [id]
  (first (fs/glob projects-dir (str "*/" id ".jsonl"))))

(defn- write-sessions!
  "Persist sessions to the file as `<name> <id> <cwd>` lines."
  [sessions]
  (->> sessions
       (map (fn [{:keys [name id cwd]}]
              (str/join " " (remove str/blank? [name id cwd]))))
       (str/join "\n")
       (#(str % "\n"))
       (spit sessions-file)))

(apply main *command-line-args*)

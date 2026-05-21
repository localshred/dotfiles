#!/usr/bin/env bb

(ns mx.commands.focus-tui
  "Interactive focus dashboard TUI with time-horizon tabs.
   All items (PRs, reviews, TODOs) live in time buckets:
   NOW, SOON, LATER, DONE."
  (:require [babashka.process :as p]
            [charm.components.help :as help]
            [charm.components.list :as item-list]
            [charm.components.text-input :as text-input]
            [charm.components.timer :as timer]
            [charm.message :as msg]
            [charm.program :as program]
            [charm.style.core :as style]
            [clojure.string :as str])
  (:import [java.time LocalDate LocalDateTime]
           [java.time.format DateTimeFormatter]
           [java.time.temporal ChronoUnit]))

;; ---------------------------------------------------------------------------
;; Config
;; ---------------------------------------------------------------------------

(def org-root (str (System/getProperty "user.home") "/org/logseq"))
(def dashboard-path (str org-root "/pages/Focus Dashboard.md"))
(def journal-dir (str org-root "/journals"))
(def todos-path (str org-root "/pages/Focus TODOs.edn"))
(def archive-path (str org-root "/pages/Focus Archive.edn"))
(def refresh-interval-ms (* 5 60 1000))

;; ---------------------------------------------------------------------------
;; Styles
;; ---------------------------------------------------------------------------

(def title-style (style/style :fg style/magenta :bold true))
(def overdue-style (style/style :fg style/red :bold true))
(def today-style (style/style :fg style/white :bold true))
(def soon-style (style/style :fg style/yellow))
(def later-style (style/style :fg 240))
(def done-style (style/style :fg 240 :strikethrough true))
(def hint-style (style/style :fg 240))
(def tab-active-style (style/style :fg style/cyan :bold true :underline true))
(def tab-inactive-style (style/style :fg 240))
(def timestamp-style (style/style :fg 240))
(def input-prompt-style (style/style :fg style/cyan))

;; ---------------------------------------------------------------------------
;; Help
;; ---------------------------------------------------------------------------

(def help-bindings
  (help/from-pairs
   "j/k" "up/down"
   "Enter" "open in browser"
   "Tab" "next tab"
   "a" "add item"
   "x" "mark done"
   "d" "delete"
   "r" "refresh"
   "?" "help"
   "q" "quit"))

(declare load-archive filter-archived build-tab-list)

;; ---------------------------------------------------------------------------
;; Time helpers
;; ---------------------------------------------------------------------------

(def today (LocalDate/now))

(defn parse-date [s]
  (try (LocalDate/parse s DateTimeFormatter/ISO_LOCAL_DATE)
       (catch Exception _ nil)))

(defn days-ago-from-str [s]
  (when-let [d (parse-date s)]
    (.between ChronoUnit/DAYS d today)))

(defn days-from-age-label [label]
  (cond
    (= label "today") 0
    (re-find #"^\d+d$" (or label "")) (parse-long (str/replace label "d" ""))
    :else nil))

;; ---------------------------------------------------------------------------
;; Unified Item Model
;; ---------------------------------------------------------------------------

(defn strip-md-links [s]
  (str/replace s #"\[([^\]]+)\]\([^\)]+\)" "$1"))

(defn extract-first-url [s]
  (second (re-find #"\[.*?\]\((https?://[^\)]+)\)" s)))

(defn item-time-bucket
  "Assign an item to a time bucket based on its age/schedule."
  [item]
  (let [{:keys [age-days due-date source]} item]
    (cond
      ;; TODOs with explicit due dates
      due-date
      (let [days-until (.between ChronoUnit/DAYS today due-date)]
        (cond
          (neg? days-until) :overdue
          (zero? days-until) :today
          (<= days-until 3) :soon
          :else :later))

      ;; Review requests: recent = now, old = later
      (= source :review-request)
      (cond
        (nil? age-days) :today
        (<= age-days 0) :today
        (<= age-days 3) :soon
        :else :later)

      ;; My PRs with issues needing action = now
      (= source :my-pr-action)
      :today

      ;; My PRs waiting on others
      (= source :my-pr-waiting)
      :soon

      ;; My PRs ready to merge
      (= source :my-pr-ready)
      :today

      ;; Drafts
      (= source :my-pr-draft)
      :later

      ;; Slack
      (#{:slack-dm :slack-mention} source)
      :today

      ;; TODOs without due date but with priority
      (= source :todo)
      (case (:priority item)
        :high :today
        :medium :soon
        :later)

      :else :later)))

;; ---------------------------------------------------------------------------
;; Dashboard Parsing -> Unified Items
;; ---------------------------------------------------------------------------

(defn parse-section [text]
  (let [lines (str/split-lines text)
        title (str/trim (first lines))
        items (->> (rest lines)
                   (filter #(str/starts-with? (str/trim %) "- "))
                   (map #(-> % str/trim (subs 2) str/trim))
                   (remove #(= "None" %)))]
    {:title title :items items}))

(defn age-from-item-text [text]
  (when-let [match (re-find #"(\d+)d old|today old" text)]
    (if (string? match)
      0
      (when-let [n (second match)]
        (parse-long n)))))

(defn parse-dashboard-item [section-title raw-item]
  (let [clean (strip-md-links raw-item)
        url (extract-first-url raw-item)
        age (or (age-from-item-text raw-item)
                (days-from-age-label
                 (second (re-find #"`(\w+)`" raw-item))))]
    (cond
      (re-find #"(?i)review request" section-title)
      {:text clean :url url :source :review-request :age-days (or age 0) :icon "[ ]"}

      (re-find #"(?i)my open pr" section-title)
      (cond
        (re-find #"`changes-requested`" raw-item)
        {:text clean :url url :source :my-pr-action :icon "[ ]"}

        (and (re-find #"`failing`" raw-item) (not (re-find #"DRAFT" raw-item)))
        {:text clean :url url :source :my-pr-action :icon "[ ]"}

        (re-find #"`approved`.*`passing`" raw-item)
        {:text clean :url url :source :my-pr-ready :icon "[~]"}

        (re-find #"DRAFT" raw-item)
        {:text clean :url url :source :my-pr-draft :age-days age :icon "[-]"}

        (re-find #"`running`|`pending`" raw-item)
        {:text clean :url url :source :my-pr-waiting :icon "[.]"}

        (re-find #"`needs-review`.*`passing`" raw-item)
        {:text clean :url url :source :my-pr-waiting :icon "[.]"}

        :else
        {:text clean :url url :source :my-pr-waiting :icon "[.]"})

      (re-find #"(?i)unread dm" section-title)
      {:text clean :url url :source :slack-dm :icon "[ ]"}

      (re-find #"(?i)mention" section-title)
      {:text clean :url url :source :slack-mention :icon "[ ]"}

      :else
      {:text clean :url url :source :other :icon "[ ]"})))

(defn load-raw-dashboard-items []
  (when (.exists (java.io.File. dashboard-path))
    (let [content (slurp dashboard-path)
          raw-sections (rest (str/split content #"\n## "))
          sections (map parse-section raw-sections)]
      {:updated (second (re-find #"Last updated: (.+)" content))
       :items (mapcat (fn [s]
                        (map #(parse-dashboard-item (:title s) %) (:items s)))
                      sections)})))

;; ---------------------------------------------------------------------------
;; TODO persistence
;; ---------------------------------------------------------------------------

(defn load-todos []
  (if (.exists (java.io.File. todos-path))
    (read-string (slurp todos-path))
    []))

(defn save-todos! [todos]
  (spit todos-path (pr-str todos)))

(defn todo->item [todo]
  (assoc todo :source :todo :icon (if (:done todo) "[x]" "[ ]")))

;; ---------------------------------------------------------------------------
;; Archive
;; ---------------------------------------------------------------------------

(defn load-archive []
  (if (.exists (java.io.File. archive-path))
    (read-string (slurp archive-path))
    {}))

(defn save-archive! [archive]
  (spit archive-path (pr-str archive)))

(defn item-fingerprint [item]
  (str (:text item)))

(defn archive-item! [item]
  (let [archive (load-archive)
        key (or (:url item) (:text item))]
    (save-archive! (assoc archive key (item-fingerprint item)))))

(defn archived? [archive item]
  (let [key (or (:url item) (:text item))
        stored-fp (get archive key)]
    (and stored-fp (= stored-fp (item-fingerprint item)))))

(defn filter-archived [items archive]
  (remove #(archived? archive %) items))

;; ---------------------------------------------------------------------------
;; State: bucket items into tabs
;; ---------------------------------------------------------------------------

(def tabs [:now :soon :later :done])

(defn tab-label [tab]
  (case tab :now "Now" :soon "Soon" :later "Later" :done "Done"))

(defn bucket-items [dashboard-items todos]
  (let [archive (load-archive)
        all-items (concat dashboard-items (map todo->item todos))
        visible (filter-archived all-items archive)
        bucketed (group-by item-time-bucket visible)]
    {:overdue (get bucketed :overdue [])
     :today (get bucketed :today [])
     :soon (get bucketed :soon [])
     :later (get bucketed :later [])
     :unscheduled (->> (get bucketed :later [])
                       (filter #(and (= :todo (:source %))
                                     (nil? (:due-date %)))))}))

(defn section-label [key]
  (case key
    :overdue "OVERDUE"
    :today "TODAY"
    :soon "NEXT 3 DAYS"
    :scheduled "SCHEDULED"
    :unscheduled "UNSCHEDULED"
    :done "COMPLETED"
    (name key)))

(defn items->list-entries [items]
  (map (fn [item]
         {:title (str (:icon item) " " (:text item))
          :data {:type :item :item item}})
       items))

(defn build-tab-list [tab bucketed done-items]
  (let [sections (case tab
                   :now [[:overdue (:overdue bucketed)]
                         [:today (:today bucketed)]]
                   :soon [[:soon (:soon bucketed)]]
                   :later [[:scheduled (->> (:later bucketed)
                                            (filter :due-date))]
                           [:unscheduled (->> (:later bucketed)
                                              (remove :due-date))]]
                   :done [[:done done-items]])
        entries (->> sections
                     (mapcat (fn [[key items]]
                               (when (seq items)
                                 (cons {:title (str "── " (section-label key)
                                                    " (" (count items) ") ──")
                                        :data {:type :header}}
                                       (items->list-entries items)))))
                     (remove nil?)
                     vec)]
    (item-list/item-list (if (empty? entries)
                           [{:title "Nothing here." :data {:type :empty}}]
                           entries)
                         :height 20
                         :cursor-prefix "> "
                         :item-prefix "  ")))

;; ---------------------------------------------------------------------------
;; Init
;; ---------------------------------------------------------------------------

(defn load-state []
  (let [raw (load-raw-dashboard-items)
        todos (load-todos)
        bucketed (bucket-items (or (:items raw) []) todos)]
    {:updated (:updated raw)
     :bucketed bucketed
     :todos todos
     :done-items []}))

(defn init []
  (let [{:keys [updated bucketed todos done-items]} (load-state)
        t (timer/timer :timeout refresh-interval-ms
                       :interval refresh-interval-ms
                       :running true)
        [t cmd] (timer/timer-init t)]
    [{:tab :now
      :updated updated
      :bucketed bucketed
      :todos todos
      :done-items done-items
      :list (build-tab-list :now bucketed done-items)
      :input (text-input/text-input :prompt "Add: "
                                    :placeholder "text [@due:YYYY-MM-DD] [!high|!med]"
                                    :focused false)
      :mode :browse
      :refresh-timer t
      :help (help/help help-bindings :width 60)
      :show-help false}
     cmd]))

;; ---------------------------------------------------------------------------
;; Update
;; ---------------------------------------------------------------------------

(defn refresh [state]
  (let [{:keys [updated bucketed todos]} (load-state)]
    (-> state
        (assoc :updated updated
               :bucketed bucketed
               :todos todos)
        (as-> s (assoc s :list (build-tab-list (:tab s) bucketed (:done-items s)))))))

(defn switch-tab [state tab]
  (assoc state
         :tab tab
         :list (build-tab-list tab (:bucketed state) (:done-items state))))

(defn next-tab [state]
  (let [idx (.indexOf tabs (:tab state))
        next-idx (mod (inc idx) (count tabs))]
    (switch-tab state (nth tabs next-idx))))

(defn prev-tab [state]
  (let [idx (.indexOf tabs (:tab state))
        prev-idx (mod (dec idx) (count tabs))]
    (switch-tab state (nth tabs prev-idx))))

(defn enter-add-mode [state]
  (-> state
      (assoc :mode :add)
      (update :input text-input/focus)))

(defn exit-add-mode [state]
  (-> state
      (assoc :mode :browse)
      (update :input text-input/blur)
      (update :input text-input/reset)))

(defn parse-todo-input [text]
  (let [due-match (re-find #"@due:(\d{4}-\d{2}-\d{2})" text)
        due-date (when due-match (parse-date (second due-match)))
        priority (cond
                   (re-find #"!high" text) :high
                   (re-find #"!med" text) :medium
                   :else nil)
        clean (-> text
                  (str/replace #"\s*@due:\d{4}-\d{2}-\d{2}\s*" " ")
                  (str/replace #"\s*!(high|med)\s*" " ")
                  str/trim)]
    {:text clean
     :due-date due-date
     :priority priority
     :done false}))

(defn add-item [state]
  (let [raw (str/trim (text-input/value (:input state)))]
    (if (str/blank? raw)
      (exit-add-mode state)
      (let [todo (parse-todo-input raw)
            new-todos (conj (:todos state) todo)]
        (save-todos! new-todos)
        (-> state
            (assoc :todos new-todos)
            exit-add-mode
            refresh)))))

(defn mark-done [state]
  (let [selected (item-list/selected-item (:list state))
        data (:data selected)]
    (when (= :item (:type data))
      (let [item (:item data)
            done-item (assoc item :icon "[x]" :done true)]
        (archive-item! item)
        (-> state
            (update :done-items conj done-item)
            refresh)))))

(defn delete-selected [state]
  (let [selected (item-list/selected-item (:list state))
        data (:data selected)]
    (when (and (= :item (:type data))
               (= :todo (get-in data [:item :source])))
      (let [item (:item data)
            new-todos (remove #(= (:text %) (:text item)) (:todos state))
            new-todos (vec new-todos)]
        (save-todos! new-todos)
        (-> state
            (assoc :todos new-todos)
            refresh)))))

(defn open-selected [state]
  (let [selected (item-list/selected-item (:list state))
        data (:data selected)
        url (when (= :item (:type data))
              (get-in data [:item :url]))]
    (when url
      (p/process "open" url))
    state))

(defn update-fn [state msg]
  (cond
    (or (msg/key-match? msg "ctrl+c")
        (and (= (:mode state) :browse) (msg/key-match? msg "q")))
    [state program/quit-cmd]

    (msg/key-match? msg "esc")
    (if (= (:mode state) :add)
      [(exit-add-mode state) nil]
      [state program/quit-cmd])

    ;; Timer tick
    (timer/for-timer? (:refresh-timer state) msg)
    (let [[new-timer cmd] (timer/timer-update (:refresh-timer state) msg)
          new-state (-> state (assoc :refresh-timer new-timer) refresh)]
      [new-state cmd])

    ;; Add mode
    (= (:mode state) :add)
    (cond
      (msg/key-match? msg "enter")
      [(add-item state) nil]

      :else
      (let [[new-input cmd] (text-input/text-input-update (:input state) msg)]
        [(assoc state :input new-input) cmd]))

    ;; Browse mode
    (msg/key-match? msg "enter")
    [(open-selected state) nil]

    (msg/key-match? msg "tab")
    [(next-tab state) nil]

    (msg/key-match? msg :backtab)
    [(prev-tab state) nil]

    (msg/key-match? msg "r")
    [(refresh state) nil]

    (msg/key-match? msg "a")
    [(enter-add-mode state) nil]

    (msg/key-match? msg "x")
    [(or (mark-done state) state) nil]

    (msg/key-match? msg "d")
    [(or (delete-selected state) state) nil]

    (msg/key-match? msg "?")
    [(update state :show-help not) nil]

    ;; List navigation
    :else
    (let [[new-list cmd] (item-list/list-update (:list state) msg)]
      [(assoc state :list new-list) cmd])))

;; ---------------------------------------------------------------------------
;; View
;; ---------------------------------------------------------------------------

(defn render-tabs [active-tab bucketed done-items]
  (str/join "  "
            (map (fn [tab]
                   (let [count (case tab
                                 :now (+ (count (:overdue bucketed))
                                         (count (:today bucketed)))
                                 :soon (count (:soon bucketed))
                                 :later (count (:later bucketed))
                                 :done (count done-items))
                         label (str (tab-label tab)
                                    (when (pos? count) (str " (" count ")")))
                         s (if (= tab active-tab) tab-active-style tab-inactive-style)]
                     (style/render s label)))
                 tabs)))

(defn view [state]
  (let [{:keys [tab updated bucketed done-items list input mode show-help help]} state]
    (str (style/render title-style "Focus") "  "
         (style/render timestamp-style (str "synced: " (or updated "never")))
         "\n"
         (render-tabs tab bucketed done-items)
         "\n\n"
         (item-list/list-view list)
         (when (= mode :add)
           (str "\n\n" (text-input/text-input-view input)))
         "\n\n"
         (if show-help
           (str (help/full-help-view help) "\n"
                (style/render hint-style "Press ? to hide"))
           (help/short-help-view help)))))

;; ---------------------------------------------------------------------------
;; Main
;; ---------------------------------------------------------------------------

(defn -main [& _args]
  (program/run {:init init
                :update update-fn
                :view view
                :alt-screen true
                :hide-cursor true}))

(apply -main *command-line-args*)

(ns mx.ui
  "Shared terminal-UI helpers for mx commands: ANSI colors, OSC 8
  hyperlinks, width-aware table rendering, and duration formatting.

  Loaded by command scripts via `load-file` since they run from an
  arbitrary working directory and cannot rely on classpath discovery:

      (load-file (str (or (System/getenv \"MX_ROOT\")
                          (str (System/getProperty \"user.home\")
                               \"/code/src/utils/dotfiles/lib/mx\"))
                      \"/lib/ui.clj\"))
      (require '[mx.ui :as ui])"
  (:require [clojure.string :as str]))

;;
;; Static defs
;;

(def ansi-blue "\033[34m")
(def ansi-cyan "\033[36m")
(def ansi-dim "\033[2m")
(def ansi-green "\033[32m")
(def ansi-red "\033[31m")
(def ansi-reset "\033[0m")
(def ansi-yellow "\033[33m")

(declare age-cell age-color blue colorize cyan dim green hyperlink humanize pad print-table
         red strip-ansi visible-len yellow)

;;
;; Public functions
;;

(defn age-cell
  "Colored, humanized duration: red past 14 days, yellow past 7, dim otherwise."
  [duration]
  (str (age-color duration) (humanize duration) ansi-reset))

(defn age-color
  "ANSI color for a duration by staleness: red past 14 days, yellow past 7."
  [duration]
  (let [days (.toDays duration)]
    (cond
      (>= days 14) ansi-red
      (>= days 7)  ansi-yellow
      :else        ansi-dim)))

(defn blue [s] (colorize ansi-blue s))
(defn cyan [s] (colorize ansi-cyan s))
(defn dim [s] (colorize ansi-dim s))
(defn green [s] (colorize ansi-green s))

(defn humanize
  "Render a Duration compactly as days, hours, or minutes."
  [duration]
  (let [days (.toDays duration)
        hours (.toHours duration)
        mins (.toMinutes duration)]
    (cond
      (pos? days)  (str days "d")
      (pos? hours) (str hours "h")
      :else        (str (max mins 0) "m"))))

(defn hyperlink
  "Wrap text in an OSC 8 terminal hyperlink to url (iTerm2, WezTerm, etc.)."
  [url text]
  (str "\033]8;;" url "\033\\" text "\033]8;;\033\\"))

(defn pad
  "Right-pad a possibly-colored cell to a target visible width."
  [cell width]
  (str cell (apply str (repeat (max 0 (- width (visible-len cell))) " "))))

(defn print-table
  "Print rows of cells as columns aligned on visible width; last column is free."
  [rows]
  (let [cols (apply max 0 (map count rows))
        widths (mapv (fn [i] (apply max 0 (map #(visible-len (nth % i "")) rows)))
                     (range cols))]
    (doseq [row rows]
      (println (str/join "  "
                         (map-indexed (fn [i cell]
                                        (if (= i (dec (count row)))
                                          cell
                                          (pad cell (nth widths i))))
                                      row))))))

(defn red [s] (colorize ansi-red s))

(defn strip-ansi
  "Remove OSC 8 hyperlink and SGR color escapes for width calculations."
  [s]
  (-> s
      (str/replace #"\033\]8;;[^\033]*\033\\" "")
      (str/replace #"\033\[[0-9;]*m" "")))

(defn visible-len
  "On-screen column count of a colored/linked cell."
  [s]
  (count (strip-ansi s)))

(defn yellow [s] (colorize ansi-yellow s))

;;
;; Private functions
;;

(defn- colorize
  "Wrap a string in an ANSI color and reset."
  [color s]
  (str color s ansi-reset))

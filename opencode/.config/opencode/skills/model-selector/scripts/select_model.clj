#!/usr/bin/env bb

(ns select-model
  (:require [babashka.cli :as cli]
            [cheshire.core :as json]
            [clojure.string :as str]))

(def models
  {:default "aisuite/gpt-5.6-sol"
   :fast "aisuite/gpt-5.6-luna"
   :fast-alternative "aisuite/gemini-3.5-flash"
   :general "aisuite/us.anthropic.claude-sonnet-5"
   :high-reasoning "aisuite/gpt-5.6-terra"
   :high-reasoning-alternative "aisuite/us.anthropic.claude-opus-4-8"
   :review "aisuite/gemini-3.1-pro-preview"})

(def high-risk-patterns
  [#"\bsecurity\b"
   #"\bauth(?:entication|orization)?\b"
   #"\bincident\b"
   #"\bproduction\b"
   #"\boutage\b"
   #"\bdata loss\b"
   #"\bmigrat(?:e|ion)\b"
   #"\brollback\b"
   #"\broot cause\b"
   #"\bdebug(?:ging)?\b"
   #"\bflaky\b"
   #"\bperformance\b"
   #"\bscal(?:e|ability)\b"
   #"\barchitecture\b"
   #"\brefactor\b"
   #"\bcross[- ]service\b"])

(def review-patterns
  [#"\breview\b"
   #"\bsecond opinion\b"
   #"\baudit\b"
   #"\bcompare\b"])

(def fast-patterns
  [#"\brename\b"
   #"\bformat\b"
   #"\bsummar(?:ize|y)\b"
   #"\bextract\b"
   #"\bclassif(?:y|ication)\b"
   #"\bboilerplate\b"
   #"\bmechanical\b"
   #"\bsmall\b"
   #"\bsimple\b"])

(def ambiguous-patterns
  [#"\bhelp\b"
   #"\blook into\b"
   #"\bfigure out\b"
   #"\bwhat(?:'s| is) wrong\b"])

(defn matching-patterns [patterns task]
  (filterv #(re-find % task) patterns))

(defn render-pattern [pattern]
  (str pattern))

(defn select-model [task]
  (let [normalized-task (str/lower-case task)
        high-risk (matching-patterns high-risk-patterns normalized-task)
        review (matching-patterns review-patterns normalized-task)
        fast (matching-patterns fast-patterns normalized-task)
        ambiguous (matching-patterns ambiguous-patterns normalized-task)]
    (cond
      (seq high-risk)
      {:primary (:high-reasoning models)
       :fallback (:high-reasoning-alternative models)
       :confidence "high"
       :rationale (str "High-risk or multi-step work detected: "
                       (str/join ", " (map render-pattern high-risk))
                       ". Prefer maximum reasoning headroom.")}

      (seq review)
      {:primary (:general models)
       :fallback (:review models)
       :confidence "medium"
       :rationale (str "Review-oriented work detected: "
                       (str/join ", " (map render-pattern review))
                       ". Use a strong general model; use the fallback for an "
                       "independent perspective.")}

      (and (seq fast) (empty? ambiguous))
      {:primary (:fast models)
       :fallback (:fast-alternative models)
       :confidence "medium"
       :rationale (str "Bounded, low-risk task signals detected: "
                       (str/join ", " (map render-pattern fast))
                       ". Optimize for latency, but verify changes with the "
                       "normal test path.")}

      :else
      {:primary (:default models)
       :fallback (:general models)
       :confidence (if (or (seq ambiguous) (str/blank? task)) "low" "medium")
       :rationale "No decisive high-risk or bounded-task signal was found. Use the balanced default and increase to Terra if investigation expands."})))

(defn print-recommendation [recommendation]
  (println (str "Model: " (:primary recommendation)))
  (println (str "Fallback: " (:fallback recommendation)))
  (println (str "Confidence: " (:confidence recommendation)))
  (println (str "Why: " (:rationale recommendation))))

(defn main [& args]
  (let [{:keys [args opts]} (cli/parse-args args {:spec {:json {:coerce :boolean}}})
        recommendation (select-model (str/join " " args))]
    (if (:json opts)
      (println (json/generate-string recommendation {:pretty true}))
      (print-recommendation recommendation))))

(apply main *command-line-args*)

#!/usr/bin/env bb
;; Claude Code status line. Reads session JSON on stdin and prints one line:
;;   model · effort · branch · ctx [####------] 42% · 5h: 60% left (resets 14:30) · 7d: 80% left · cache cold
;; Input fields: https://code.claude.com/docs/en/statusline#available-data

(require '[babashka.process :refer [shell]]
         '[cheshire.core :as json]
         '[clojure.string :as str])
(import '(java.time Instant ZoneId)
        '(java.time.format DateTimeFormatter))

;; The 7d segment shows its reset time once remaining usage drops below this.
;; The 5h segment always shows it.
(def low-limit-pct 25)

(defn clock
  "Formats epoch seconds as local time, e.g. \"14:30\"; nil when absent."
  [epoch-seconds pattern]
  (when (number? epoch-seconds)
    (-> (Instant/ofEpochSecond (long epoch-seconds))
        (.atZone (ZoneId/systemDefault))
        (.format (DateTimeFormatter/ofPattern pattern)))))

(defn cache-cold?
  [{:keys [caching_observed warm expires_at]} now-seconds]
  (boolean (and caching_observed
                (or (not warm)
                    (and (number? expires_at) (>= now-seconds expires_at))))))

(defn status-from-input
  "Pulls the displayed fields out of Claude Code's session JSON."
  [input now-seconds]
  (let [pct-left #(when (number? %) (Math/round (- 100.0 %)))]
    {:model       (get-in input [:model :display_name])
     :effort      (get-in input [:effort :level])
     :cwd         (get-in input [:workspace :current_dir])
     :ctx-used    (some-> (get-in input [:context_window :used_percentage]) double Math/round)
     :five-left   (pct-left (get-in input [:rate_limits :five_hour :used_percentage]))
     :five-resets (clock (get-in input [:rate_limits :five_hour :resets_at]) "HH:mm")
     :week-left   (pct-left (get-in input [:rate_limits :seven_day :used_percentage]))
     :week-resets (clock (get-in input [:rate_limits :seven_day :resets_at]) "EEE HH:mm")
     :cache-cold? (cache-cold? (:prompt_cache input) now-seconds)}))

(defn context-bar
  "Ten-cell bar, one cell per 10% of context used."
  [used-pct]
  (let [filled (min 10 (quot (+ used-pct 5) 10))]
    (str "[" (str/join (repeat filled "#")) (str/join (repeat (- 10 filled) "-")) "]")))

(defn limit-segment
  "\"5h: 12% left\", plus \"(resets 14:30)\" either always or only when running low."
  [label left resets show-resets]
  (when left
    (cond-> (str label ": " left "% left")
      (and resets (or (= show-resets :always) (< left low-limit-pct)))
      (str " (resets " resets ")"))))

(defn status-line
  [{:keys [model effort ctx-used five-left five-resets week-left week-resets cache-cold?]} branch]
  (->> [model
        (when (seq effort) (str "effort:" effort))
        branch
        (when ctx-used (str "ctx " (context-bar ctx-used) " " ctx-used "%"))
        (limit-segment "5h" five-left five-resets :always)
        (limit-segment "7d" week-left week-resets :when-low)
        (when cache-cold? "cache cold")]
       (remove str/blank?)
       (str/join " · ")))

(defn current-branch [cwd]
  (when (seq cwd)
    (let [{:keys [exit out]} (shell {:out :string :err :string :continue true}
                                    "git" "-C" cwd "--no-optional-locks"
                                    "rev-parse" "--abbrev-ref" "HEAD")]
      (when (zero? exit) (str/trim out)))))

;; A malformed payload prints an empty line rather than a stack trace.
(println
 (try
   (let [now-seconds (/ (System/currentTimeMillis) 1000.0)
         status (status-from-input (json/parse-stream *in* true) now-seconds)]
     (status-line status (current-branch (:cwd status))))
   (catch Exception _ "")))

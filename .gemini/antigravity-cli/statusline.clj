#!/usr/bin/env bb
;; Antigravity CLI (agy) status line. Reads session JSON on stdin and prints one line:
;;   model · mode · branch · ctx [####------] 42% · 5h: 60% left (resets 14:30) · 7d: 91% left
;; Input fields: https://antigravity.google/docs/cli/statusline

(require '[babashka.process :refer [shell]]
         '[clojure.data.json :as json]
         '[clojure.string :as str])
(import '(java.time Instant ZoneId)
        '(java.time.format DateTimeFormatter))

;; Multi-day quota buckets show their reset time once remaining usage drops below this.
;; Short-window (e.g. 5h) buckets always show it.
(def low-limit-pct 25)

(defn parse-reset-instant
  "Returns an Instant from ISO-8601 reset_time, falling back to now + reset_in_seconds."
  [reset-time reset-in-seconds now-seconds]
  (or (when (and (string? reset-time) (seq reset-time))
        (try (Instant/parse reset-time) (catch Exception _ nil)))
      (when (number? reset-in-seconds)
        (Instant/ofEpochSecond (+ (long now-seconds) (long reset-in-seconds))))))

(defn format-instant
  [instant pattern]
  (when instant
    (-> instant
        (.atZone (ZoneId/systemDefault))
        (.format (DateTimeFormatter/ofPattern pattern)))))

(defn short-window? [label reset-in-seconds]
  (let [s (str/lower-case label)]
    (cond
      (or (str/includes? s "5h") (str/includes? s "hour")) true
      (or (str/includes? s "week") (str/includes? s "7d")) false
      :else (and (number? reset-in-seconds) (<= reset-in-seconds 86400)))))

(defn other-family-prefix
  "Returns the inactive model family's quota prefix to filter out (3p- on Gemini, gemini- on 3P),
  or nil when the model may span both families or cannot be classified."
  [model]
  (when (seq model)
    (let [s             (str/lower-case model)
          orchestrator? (str/includes? s "orchestrator")
          third-party?  (boolean (re-find #"claude|gpt" s))
          gemini?       (or (str/includes? s "gemini")
                            (and orchestrator? (not third-party?)))]
      (cond
        (and orchestrator? third-party?) nil
        gemini?                          "3p-"
        third-party?                     "gemini-"))))

(defn short-quota-label [bucket-name strip-family?]
  (let [lower (str/lower-case bucket-name)
        label (if strip-family?
                (str/replace lower #"^(gemini|3p)-" "")
                lower)]
    (cond
      (= label "weekly")               "7d"
      (str/ends-with? label "-weekly") (str (subs label 0 (- (count label) 7)) "-7d")
      :else                            label)))

(defn quota-entries
  "Normalizes agy's quota map for the active model family into sorted bucket records."
  [quota model now-seconds]
  (let [skip-prefix (other-family-prefix model)]
    (->> quota
         (keep (fn [[bucket-k {:keys [remaining_fraction reset_time reset_in_seconds disabled]}]]
                 (let [raw-label (name bucket-k)]
                   (when (and (not disabled)
                              (number? remaining_fraction)
                              (not (and skip-prefix
                                        (str/starts-with? (str/lower-case raw-label) skip-prefix))))
                     (let [short?  (short-window? raw-label reset_in_seconds)
                           instant (parse-reset-instant reset_time reset_in_seconds now-seconds)]
                       {:label        (short-quota-label raw-label (boolean skip-prefix))
                        :left         (Math/round (* 100.0 (double remaining_fraction)))
                        :resets       (format-instant instant (if short? "HH:mm" "EEE HH:mm"))
                        :show-resets  (if short? :always :when-low)
                        :sort-seconds (if (number? reset_in_seconds)
                                        (long reset_in_seconds)
                                        Long/MAX_VALUE)})))))
         (sort-by (juxt :sort-seconds :label)))))

(defn status-from-input
  "Pulls the displayed fields out of agy's session JSON."
  [input now-seconds]
  (let [pct-used #(when (number? %) (Math/round (double %)))
        model    (get-in input [:model :display_name])]
    {:model    model
     :effort   (get-in input [:model :effort])
     :mode     (:cycle_mode input)
     :cwd      (or (get-in input [:workspace :current_dir]) (:cwd input))
     :vcs-type (get-in input [:vcs :type])
     :ctx-used (pct-used (get-in input [:context_window :used_percentage]))
     :quotas   (quota-entries (:quota input) model now-seconds)}))

(defn effort-already-in-model? [model effort]
  (and (seq model)
       (seq effort)
       (str/includes? (str/lower-case model)
                      (str "(" (str/lower-case effort) ")"))))

(defn context-bar
  "Ten-cell bar, one cell per 10% of context used."
  [used-pct]
  (let [filled (min 10 (quot (+ used-pct 5) 10))]
    (str "[" (str/join (repeat filled "#")) (str/join (repeat (- 10 filled) "-")) "]")))

(defn limit-segment
  "\"gemini-5h: 60% left\", plus \"(resets 14:30)\" either always or only when running low."
  [label left resets show-resets]
  (when left
    (cond-> (str label ": " left "% left")
      (and resets (or (= show-resets :always) (< left low-limit-pct)))
      (str " (resets " resets ")"))))

(defn status-line
  [{:keys [model effort mode ctx-used quotas]} branch]
  (->> (concat
        [model
         (when (and (seq effort) (not (effort-already-in-model? model effort)))
           (str "effort:" effort))
         mode
         branch
         (when ctx-used (str "ctx " (context-bar ctx-used) " " ctx-used "%"))]
        (map (fn [{:keys [label left resets show-resets]}]
               (limit-segment label left resets show-resets))
             quotas))
       (remove str/blank?)
       (str/join " · ")))

(defn current-branch [cwd vcs-type]
  (when (and (seq cwd) (= vcs-type "git"))
    (let [{:keys [exit out]} (shell {:out :string :err :string :continue true}
                                    "git" "-C" cwd "--no-optional-locks"
                                    "rev-parse" "--abbrev-ref" "HEAD")]
      (when (zero? exit) (str/trim out)))))

;; A malformed payload prints an empty line; the error goes to stderr so agy
;; does not hit its consecutive-failure circuit breaker.
(println
 (try
   (let [now-seconds (/ (System/currentTimeMillis) 1000.0)
         status      (status-from-input (json/read-str (slurp *in*) :key-fn keyword) now-seconds)]
     (status-line status (current-branch (:cwd status) (:vcs-type status))))
   (catch Exception e
     (binding [*out* *err*] (println "statusline:" (ex-message e)))
     "")))

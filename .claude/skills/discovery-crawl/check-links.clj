#!/usr/bin/env bb
;; Checks that every link a discovery-crawl map cites opens.
;; Input: URLs on stdin, one per line. Output: one tab-separated line per URL,
;; "<verdict>\t<status>\t<url>", in input order. Verdicts:
;;   opens          2xx/3xx
;;   blocked        401/403/429/451/999 — couldn't open, not proof the page is gone
;;   missing        404/410
;;   other          any other status
;;   error          no response (DNS, TLS, timeout)
(require '[babashka.http-client :as http]
         '[clojure.string :as str])

(def user-agent
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36")

(defn verdict [status]
  (cond
    (<= 200 status 399) "opens"
    (#{401 403 429 451 999} status) "blocked"
    (#{404 410} status) "missing"
    :else "other"))

(defn check [url]
  (try
    (let [{:keys [status]} (http/get url {:throw false
                                          :timeout 20000
                                          :headers {"User-Agent" user-agent}})]
      [(verdict status) (str status) url])
    (catch Exception e
      ["error" (.getSimpleName (class e)) url])))

(let [urls (->> (str/split-lines (slurp *in*))
                (map str/trim)
                (remove str/blank?)
                distinct)]
  (doseq [row (pmap check urls)]
    (println (str/join "\t" row))))

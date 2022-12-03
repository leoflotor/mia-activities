;; One way to define the repeat macro using a loop and the for keyword
(defmacro myrepeat (reps expr)
  (loop for i from 1 to reps
        do (eval expr)))

;; The repeat macro using a loop and the repeat keyword
(defmacro myrepeat2 (reps expr)
  (loop repeat reps
        do (eval expr)))


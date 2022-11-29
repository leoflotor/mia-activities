(defmacro repeat (reps expr)
  (loop for i from 1 to reps
        do (eval expr)))

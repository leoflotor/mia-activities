
(defun suma (x y)
    (+ x y))

; Esto cuenta como lo visto en OCaml?
; # suma 3 ;;
; - : int -> int = <fun>
(defun suma3 (x) 
    (suma 3 x))

(defun maximo (x y)
    (if (> x y)
        x
        y))

(write-line 
    (format nil "The sum is: ~D" (suma 1 4)))

(write-line 
    (format nil "The sum3 is: ~D" (suma3 7)))

(write-line 
    (format nil "The max is: ~D" (maximo 1 4)))
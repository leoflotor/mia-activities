;;;; Diseño de funciones simples para probar LISP

;;; Los pitfalls de mis ideas preconcebidas debido a mi experiencia.

(defun ispositiveV1 (x)
    (if (> x 0)
        "yay"
        "nay"))

; Funcion signv2/1 solo dice si un numero es positivo
(defun ispositiveV2 (x)
    (if (> x 0)
        'yay
        'nay))

; Queria ver si `>=` es un operador valido. Si lo es.
(defun signV1 (x)
    (if (>= x 0)
        'pos
        'neg))

; No continua el flujo de control!
; Retorna `nil` porque falla en la primera condicion.
(defun signV2 (x)
    (if (>= x 0)
        'pos)
    (if (< x 0)
        'neg))

; Sigue el flujo de control, pero siempre regresa `'neg` independientemente
; del valor de entrada!
(defun signV3 (x)
    (if (>= x 0)
        'pos)
    'neg)

; Esto es lo equivalente a un if-then-else-if como en otros lenguages es
; if-elif.
(defun signV4 (x)
    (if (>= x 0)
        'pos
        (if (< x 0)
            'neg)))

; Esto se volvio impractico muy rapido, y confuso. Me puedo imaginar la 
; pesadez que seria con condiciones mas grandes.
(defun signV5 (x)
    (if (= x 0)
        'cero
        (if (> x 0)
            'pos
            'neg)))

; Esta funcion se vielve equivalente a estructuras de control 
; `if-then-else`. Se usa `t` en la ultima condicion porque para que una
; sea elegida tiene que ser cierta, y no hay necesidad declararla
; explicitamente.
(defun signV6 (x)
    (cond 
        ((= x 0) 'cero)
        ((> x 0) 'pos)
        (t 'neg))) ; (< x 0)



; Si se cambia de `"x"` a `'x` hay un error, no entiendo el backtrace.
(write-line (ispositiveV1 4))

; Se tiene que dar formato para verlo en terminal, supongo que porque no 
; es un string sino un simbolo.
; Si se usa en el REPL no sucede este problema.
; No se que hace `nil`.
; No se porque los symbolos no se pueden imprimir.
(write-line 
    (format nil "is x positive? ~D" (ispositiveV2 4)))

(write-line 
    (format nil "signV1 of x: ~D" (signV1 3)))

(write-line 
    (format nil "signV2 of x: ~D" (signV2 3)))

(write-line 
    (format nil "signV3 of x: ~D" (signV3 3)))

(write-line 
    (format nil "signV4 of x: ~D" (signV4 -3)))

(write-line 
    (format nil "signV5 of x: ~D" (signV5 -3)))

(write-line 
    (format nil "signV6 of x: ~D" (signV6 0)))
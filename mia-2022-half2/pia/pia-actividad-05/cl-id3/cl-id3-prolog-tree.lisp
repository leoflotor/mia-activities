(in-package :cl-id3)

;; Final de cada linea.
(defun print-dot ()
  (format t "])."))

;; Comas para dividir entradas.
(defun print-comma ()
  (format t ", "))

;; Valor por defecto cuando la entrada esta vacia.
(defun print-empty ()
  (format t "_"))

(defun print-newline ()
  (format t "~%"))

;; Es necesario que la primera letra sea minuscula para que prolog no lo tome como
;; variables. Entonces se puede cambiar la palabra completa a minusculas.
(defun downcase-attr (attr)
  (if (numberp attr)
      (format t "~a/" attr)
      (format t "~a/" (string-downcase attr))))

(defun downcase-value (value)
  (if (numberp value)
      (format t "~a" value)
      (format t "~a" (string-downcase value))))

;; Convierte un arbol generado con el paquete en su respectivo conjunto de ramas.
(defun tree-to-branches (tree)
  (if (leaf-p tree)
      (list (list tree))
      (mapcan (lambda (node)
                (mapcar (lambda (path)
                          (cons (root tree) path))
                        (tree-to-branches node)))
              (children tree))))

;;; Funcion auxiliar para la conversion de un arbol en lisp a clausulas en prolog.
(defun prolog-tree-aux (tree filename)
  (let ((branches (tree-to-branches tree)))
    (dribble filename)
    (loop for branch in branches 
          do (format t "branch(~a, [" (string-downcase (car (last branch))))
          do (let ((attributes (butlast *attributes*)))
               (dotimes (n (length attributes))
                 (if (member (nth n attributes) branch)
                   (when t
                     (downcase-attr (nth n attributes))
                     (downcase-value (nth (+ (position (nth n attributes) branch :test #'equal) 1) branch)))
                   (print-empty))
                 (if (eql n (- (length attributes) 1))
                   (print-dot)
                   (print-comma))))
          do (print-newline))
    (dribble)))

;; Convierte un arbol en lisp a prolog. Guarda el arbol en el directorio /home/usr
;; por defecto.
(defun prolog-tree (ramas &optional (filename "~/prolog_tree.pl"))
  (if (not (probe-file filename))
    (prolog-tree-aux ramas filename)
    (format t "File already exists.")))


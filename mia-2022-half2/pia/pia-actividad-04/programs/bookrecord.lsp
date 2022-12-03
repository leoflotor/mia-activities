;; Crea una lista con parametros para almacenar la informacion de cada libro
(defun crea-libro (titulo autor edit precio)
  (list :titulo titulo :autor autor :edit edit :precio precio))

;; Crea variable global para almacenar la base de datos
(defvar *base-de-datos* nil)

;; Agrega un nuevo registro a la base de datos a partir de la lista con parametros
(defun agregar-reg (libro) (push libro *base-de-datos*))

;; Muestra la base de datos dandole formato para facilitar la lectura
(defun muestra-bd ()
  (dolist (libro *base-de-datos*)
    (format t "~{~a:~10t~a~%~}~%" libro)))

;; Definicion alternativa para formatear la base de datos
(defun muestra-bd2 ()
  (format t"~{~{~a:~10t~a~%~}~%~}" *base-de-datos*))

;; Busca en la base de datos los libros que corresponden al autor de interes
(defun selecciona-por-autor (autor)
  (remove-if-not
    #'(lambda (libro) (equal (getf libro :autor) autor))
    *base-de-datos*))

(in-package :cl-id3)

;;; cl-id3-cross-validation

;; Optional variable if the usr doesn't want to print the tree
(defun cross-validation (k &optional (print_ t))
  ;; Clean the tree list
  (setq *trees* nil)
  (let* ((long (length *examples*)))
    (loop repeat k do
	 (let* ((trainning-data (folding (- long k) long))
		(test-data (difference trainning-data *examples*))
		(tree (induce trainning-data)))
       ;; Only report the tree if wanted, will do it by default.
	   (if print_
         (report tree test-data))
       ;; Save tree
       (push tree *trees*)))))

(defun report (tree data)
  (let ((positives (count-positives tree data)))
    (print-tree tree)
    (format t 
	    "~%Instances classified correctly: ~S~%Instances classified incorrectly: ~S~%~%"
	    positives 
	    (- (length data) positives))))

(defun count-positives (tree data)
  (apply #'+
	 (mapcar #'(lambda (e) 
		     (if (eql (classify e tree) 
			      (get-value *target* e))
			 1 0)) data)))

(defun folding (n size)
  (let ((buffer nil))
    (loop repeat n 
       collect (nth (let ((r (random size)))
		      (progn
			(while (member r buffer) (setf r (random size)))
			(push r buffer)
			r)) *examples*))))

(defun difference (list1 list2)
  (loop for i in list1 collect
       (setf list2 (remove i list2)))
  list2)

;; Let the trees vote/fight
(defun let-them-vote (example)
  (setq *main-class* nil *results* nil)
  (loop for tree in *trees* and index from 1
	 do (push (classify-new-instance example tree) *results*)
	 do (format t "~%Classification for tree no. ~a: ~a~%" index 
                (classify-new-instance example tree)))
  (most-voted *results*)
  (format t "~%The most voted class was: ~a~%" *main-class*)
  )

;; Most voted class
(defun most-voted (results)
    (let ((aux 0))
      (loop for class in (get-domain *target*)
            do (format t "~%Class ~a was detected ~a time(s).~%" class (count class results))
            do (if (> (count class results) aux)
                 (setq aux (count class results) *main-class* class)
                 nil))))

(defun tree-ptl (tree)
  (cond
   ((null tree) ())
   ((atom tree) (list t "(" tree "," "[" "]" ")"))
   (t (append (list t "(" (first tree) "," "[")
	      (ptl-list (children2 tree))
	      (list "]" ")")
	      )
      )
   )
  )

(defun children2 (tree)
  (rest tree)
  )

(defun ptl-list (children2)
  (cond
   ((null children2) ())
   ((null (rest children2)) (tree-ptl (first children2)))
   (t (append (tree-ptl (first children2))
	      (list ",")
	      (ptl-list (rest children2))
	      ))
   )
  )

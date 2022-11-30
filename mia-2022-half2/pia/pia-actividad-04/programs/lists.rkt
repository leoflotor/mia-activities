#lang racket
;; Author: Leonardo Flores-Torres
;; Professor: Alejandro Guerra-Hernandez
;; Course: Programming for Artificial Intelligence
;; --------------------------------------------------------------------------------------


;; TRIVIAL EXAMPLE.
;; my-listsum just sums recursively all elements of a list.
(define (my-listsum lst)
  (if (empty? lst)
      0
      (+ (first lst) (my-listsum (rest lst)))))

#|

Note. For all function definitions involving set operations, the sets are represented
as lists. It is assumed that all lists do not have repeated elements due to the nature
of sets. Thus, no filtering is done to remove duplicates. No sorting is needed for
set operations, only element-uniqueness is requested to the usr to guarantee correct
results.

|#

;; my-remove removes all instances of a value from a list.
(define (my-remove val lst)
  (filter (λ (x) (not (eq? x val))) lst))

;; my-remove-rec recursively removes all instances of a value from a list.
(define (my-remove-rec val lst)
  (if (empty? lst)
      empty
      (if (eq? val (first lst))
          (my-remove-rec val (rest lst))
          (cons (first lst) (my-remove-rec val (rest lst))))))

;; my-member-rec recursively iterates through a list and returns #t if a given value
;; exists at least once in a list, else returns #f.
(define (my-member-rec val lst)
  (if (empty? lst)
      false
      (if (eq? val (first lst))
          true
          (my-member-rec val (rest lst)))))

;; my-subset returns #f if a set A is subset of another set B, "A subset B", else
;; returns #f.
;; Note. This implementation seemed to be easily achieveable with a map!
(define (my-subset lsta lstb)
  (andmap (λ (x) (my-member-rec x lstb)) lsta))

;; my-subset-rec is the recursive implementation of my-subset.
(define (my-subset-rec lsta lstb)
  (if (empty? lsta)
      true    ; If the end of lsta is reached it means all elements of lsta are in lstb
      (if (my-member-rec (first lsta) lstb)
          (my-subset-rec (rest lsta) lstb)
          false)))    ; If one element in lsta is not in lstb then lsta is not a subset

;; my-intersection-rec recursively computes the intersection of two sets A and B,
;; "A intersection B".
(define (my-intersection-rec lsta lstb)
  (if (empty? lsta)
      empty
      (if (my-member-rec (first lsta) lstb)
          (cons (first lsta) (my-intersection-rec (rest lsta) lstb))
          (my-intersection-rec (rest lsta) lstb))))

;; my-union-rec returns the set which is the union of two other sets A and B,
;; "A union B".
(define (my-union-rec lsta lstb)
  (if (empty? lsta)    ; When lsta is empty it means we have finished
      (sort lstb <)    ; Just to order the returned list, sorting can be omitted
      (if (my-member-rec (first lsta) lstb)
          (my-union-rec (rest lsta) lstb)
          (my-union-rec (rest lsta) (cons (first lsta) lstb)))))

;; my-difference-rec recursively computes the difference between two sets,
;; "A difference B".
(define (my-difference-rec lsta lstb)
  (if (empty? lstb)
      lsta
      (if (my-member-rec (first lstb) lsta)
          (my-difference-rec (my-remove-rec (first lstb) lsta) (rest lstb))
          (my-difference-rec lsta (rest lstb)))))

; Compute permutations of a list. Wtf?
#;(define (perms lst)
  (match lst
    [(list x)  (list (list x))]
    [(list x y) (list (list x y) (list y x))]
    [xs (foldr append empty
               (map (λ (x)
                      (map (curry cons x)
                           (perms (remove x xs)))) xs))]
    )
  )

;; The general idea of the algorith to compute the permutations of a list is explained
;; below.
;; For each of the n elements in the list, first find all the permutations of the
;; remaining n-1 elements. Then, prepend the element to each permutation. Finally,
;: return a list of all resulting permutations.
(define (my-permutations lst)
  (cond [(empty? lst) empty]
        [(empty? (rest lst)) (list lst)]
        [else
         (let splice ([l '()]
                      [head (first lst)]
                      [tail (rest lst)])
           (append
            (map (λ (x) (cons head x))
                 (my-permutations (append l tail)))
            (if (empty? tail)
                empty
                (splice (cons head l) (first tail) (rest tail)))))]))

#;(define (all-permutations lst)
  (cond ((empty? lst) empty)
        ((null (cdr list)) (list list))
        (t (loop for element in list
             append (mapcar (lambda (l) (cons element l))
                            (all-permutations (remove element list)))))))


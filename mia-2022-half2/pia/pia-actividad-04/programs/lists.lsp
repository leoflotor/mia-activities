;; Author: Leonardo Flores-Torres
;; Professor: Alejandro Guerra-Hernandez
;; Course: Programming for Artificial Intelligence
;; --------------------------------------------------------------------------------------

#|

Note. This file only contains a couple of the functions implemented in racket
using the loop-macro. It is assumed that all sets represented by lists have unique
elements only.

|#

;; my-member operation to check whether a value is member of a list at least once.
(defun my-member (val lst)
  (loop for item in lst thereis (equal val item)))

;; my-subset operation equivalent to that done in racket, and making use of loop
(defun my-subset (lsta lstb)
  (loop for item in lsta
    always (my-member item lstb)))

;; my-subsett just collects the items from a list lsta that appear in another list 
;; lstb, if those items are the same as those in lsta then lsta is subset of lstb.
;; Although, the function my-subset is cleaner, more lispy even?
(defun my-subsett (lsta lstb)
  (if 
    (equal 
      lsta
      (loop for item in lsta when (my-member item lstb) collect item))
    t))





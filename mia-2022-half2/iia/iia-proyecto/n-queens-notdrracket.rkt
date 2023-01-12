#lang racket

;; Define figures for empty cells and for the queens
(define-values (cellfig queenfig) (values " ." ". Q"))
    
;; Function that creates a chessboard as a n-squared array
(define (make-board n)
  (let loop ([v n]
             [l '()])
    (if (zero? v)
        (list->vector l)
        (loop (sub1 v) (cons (make-vector n 0) l)))))

;; Function to allow the access to the chessboard by row and column and replace the value in that position
(define (board-set! board row col val)
  (vector-set! (vector-ref board col) row val))
      
;; Function to allow the access to the chessboard by row and column 
(define (board-ref board row col)
  (vector-ref (vector-ref board col) row))

;; Function to copy/save board state
(define (board-copy board)
  (for/vector ([v board])
    (vector-copy v)))

;; Function to print the state of the board
(define (board-print board [showfigs #false])
  (let*-values ([(n) (vector-length board)]
                [(cell) (if (not showfigs) " ." cellfig)]
                [(queen) (if (not showfigs) " Q" queenfig)])
    (for* ([r n]
           [c n])
      (when (zero? c) (newline))
      (let ([v (board-ref board r c)])
        (if (zero? v)
            (display cell)
            (display queen)
            ))))
  (newline))

; Depth first search procedure
(define (depth-first-search n)
  (let ([sols '()]
        [board (make-board n)])
    (let loop ([row 0]
               [col 0])
      (when (< col n)
        (let ([valid (not (attacked board row col))])
          (when valid
            (board-set! board row col 1)
            (if (= col (sub1 n))
                (let ([copy (board-copy board)])
                  (set! sols (cons copy sols)))
                (loop 0 (add1 col)))
            (board-set! board row col 0))
          (when (< (add1 row) n) (loop (add1 row) col)))))
    sols))

;; Function that tests if the current position in the board can be attacked by a queen already in the board
(define (attacked board row col)
  (let ([n (vector-length board)])
    (let loop ([ac (sub1 col)])
      (if (< ac 0) #f
          (let ([r1 (+ row (- col ac))]
                [r2 (+ row (- ac col))])
            (if (or (= 1 (board-ref board row ac))
                    (and (< r1 n) (= 1 (board-ref board r1 ac)))
                    (and (>= r2 0) (= 1 (board-ref board r2 ac))))
                #t
                (loop (sub1 ac))))))))

(define (solve n [showfigs #false])
  (let* ([sols (depth-first-search n)]
         [nsols (length sols)])
    (display (format "Number of solutions found: ~a. ~%~%" nsols))
    (for ([board sols]
           [i (in-range 0 nsols)])
      (display (format "Solution (~a):" (add1 i)))
      (board-print board showfigs)
      (newline))))
















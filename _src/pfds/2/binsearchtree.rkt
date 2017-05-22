#lang typed/racket
; binsearchtree.rkt

(require racket/match)

(provide (all-defined-out))

(struct Empty () #:transparent)
(struct {T E T} Node ([left : (Tree E)] [val : E] [right : (Tree E)]) #:transparent)

(define-type {Tree Elem} (U
                           Empty
                           (Node (Tree Elem) Elem (Tree Elem))
                           ))

(: member  (-> Real (Tree Real) Boolean))
(define (member a t)
  (match t
    [(Empty) #f]
    [(Node l v r)
     (if (> v a)
       (member a l)
       (if (< v a)
         (member a r)
         #t))]))

(: insert (-> Real (Tree Real) (Tree Real)))
(define (insert a t)
  (match t
    [(Empty) (Node (Empty) a (Empty))]
    [(Node l v r)
     (if (> v a)
       (Node (insert a l) v r)
       (if (> v a)
         (Node l v (insert a r))
         t))]))

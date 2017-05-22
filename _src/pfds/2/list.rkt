#lang typed/racket
; list.rkt

(require racket/match)

(provide (all-defined-out))

(define-type {MyList A} (U
                          Empty
                          (Cons A (MyList A))))

(struct Empty () #:transparent)
(struct {A _} Cons ([x : A] [xs : (MyList A)]) #:transparent)

(define (raise-empty-stack)
  (raise 'Empty-MyList))

(: empty Empty)
(define empty (Empty))

(: isEmpty (-> (MyList Any) Boolean))
(define isEmpty
  (match-lambda
    [(Empty) #t]
    [_ #f]))

(: cons (All {A} (-> A (MyList A) (MyList A))))
(define (cons a s)
  (Cons a s))

(: head (All {A} (-> (MyList A) A)))
(define head
  (match-lambda
    [(Empty) (raise-empty-stack)]
    [(Cons a _) a]))

(: tail (All {A} (-> (MyList A) (MyList A))))
(define tail
  (match-lambda
    [(Empty) (raise-empty-stack)]
    [(Cons _ s-) s-]))

(: ++ (All {A} (-> (MyList A) (MyList A) (MyList A))))
(define/match (++ xs ys)
  [((Empty) _) ys]
  [((Cons x xsr) _) (cons x (++ xsr ys))])

(: update (All {A} (-> (MyList A) Integer A (MyList A))))
(define/match (update xs i y)
  [((Empty) _ _) (raise-empty-stack)]
  [((Cons _ xsr) 0 y) (Cons y xsr)]
  [((Cons x xsr) i y) (Cons x (update xsr (sub1 i) y))])

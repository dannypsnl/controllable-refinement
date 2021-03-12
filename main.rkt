#lang racket

(define/contract (sorted? l)
  (list? . -> . boolean?)
  (andmap = (sort l <) l))

(define/contract (insert l a)
  ((and/c list? sorted?) any/c . -> . list?)
  (append l (list a)))

(insert '(1 2 3) 4)

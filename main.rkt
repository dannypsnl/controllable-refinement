#lang racket

(require racket/set)

;;; helpers
(define (lookup/type-of env v)
  (hash-ref env v))
(define (extend/env env v t)
  (hash-set! env v t))
;;; types
(struct ty:-> (p* ret) #:transparent)
(struct ty:prop
  (ty prop*)
  #:mutable
  #:transparent)
;;; prop, do can be: '+, '-, and #f
(struct prop (do? name) #:transparent)

(define (ty-> #:env (env (make-hash)) exp expect-ty)
  (ty=? #:env env expect-ty (<-ty exp #:env env)))
(define (ty=? #:env env expect-ty actual-ty)
  (match* {expect-ty actual-ty}
    [({ty:prop ty prop-operation*} {ty:prop ty2 prop-have*})
     (unless (equal? ty ty2)
       (error 'type-check "expect: ~a, get: ~a" expect-ty actual-ty))
     (let ([had-prop* (list->mutable-set prop-have*)]
           [require-prop* (mutable-set)])
       (for ([prop-op prop-operation*])
         (match (prop-do? prop-op)
           ;;; a bug hiding at here: we shouldn't allow program like the following example
           ;;; list[a]{+sorted sorted}, which is useless and dangerous
           ['+ (set-add! had-prop* (prop-name prop-op))]
           ['- (set-remove! had-prop* (prop-name prop-op))]
           [#f (set-add! require-prop* (prop-name prop-op))]))
       (unless (subset? require-prop* had-prop*)
         (set-subtract! require-prop* had-prop*)
         (error 'type-check "~a is not ~a" actual-ty (set->list require-prop*)))
       (set-ty:prop-prop*! actual-ty (set->list had-prop*)))]))
(define (<-ty exp #:env env)
  (match exp
    [`{,f ,arg* ...}
     (let ([f-ty (<-ty f #:env env)])
       (for ([p (ty:->-p* f-ty)]
             [arg arg*])
         (ty=? p (<-ty arg #:env env) #:env env))
       (ty:->-ret f-ty))]
    [x (cond
         [(number? x) 'number]
         [(boolean? x) 'bool]
         [(symbol? x)
          (let ([t (lookup/type-of env x)])
            (if (and (procedure? t) (not (parameter? t)))
                (t)
                t))]
         [else (error (format "unknown form: ~a" x))])]))

(define env (make-hash))
; sort : list{+sorted} -> void
(extend/env env 'sort (ty:-> (list (ty:prop 'list (list (prop '+ 'sorted))))
                             (ty:prop 'void '())))
; insert : list{-sorted} -> any -> void
(extend/env env 'insert (ty:-> (list (ty:prop 'list (list (prop '- 'sorted))) (ty:prop 'any '()))
                               (ty:prop 'void '())))
; binary-search : list{sorted} -> any
(extend/env env 'binary-search (ty:-> (list (ty:prop 'list (list (prop #f 'sorted))))
                                      (ty:prop 'any '())))
(extend/env env 'test-list (ty:prop 'list '()))
(extend/env env 'test-element (ty:prop 'any '()))

(ty-> '(sort test-list) (ty:prop 'void '()) #:env env)
;;; uncomment this one or reorder sort/binary-search would be type error
;(ty-> '(insert test-list) (ty:prop 'void '()) #:env env)
(ty-> '(binary-search test-list) (ty:prop 'any '()) #:env env)

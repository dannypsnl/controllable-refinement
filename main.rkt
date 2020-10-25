#lang racket

(require racket/hash)

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

(define (ty-> #:env (env (make-hash)) exp expect-ty)
  (ty=? #:env env expect-ty (<-ty exp #:env env)))
(define (ty=? #:env env expect-ty actual-ty)
  (match* {expect-ty actual-ty}
    [({ty:prop ty prop-operation*} {ty:prop ty2 prop-have*})
     (unless (equal? ty ty2)
       (error 'type-check "expect: ~a, get: ~a" expect-ty actual-ty))
     (let ([had-prop* (make-hash)]
           [require-prop* (make-hash)])
       (hash-union! had-prop* prop-have*)
       (for ([prop-name (hash-keys prop-operation*)]
             [prop-do (hash-values prop-operation*)])
         (match prop-do
           ['?+ (hash-set! had-prop* prop-name 'require)]
           ['?- (hash-remove! had-prop* prop-name)]
           ['+ (unless (not (hash-ref had-prop* prop-name #f))
                 (error 'type-check "~a should not have ~a" actual-ty prop-name))
               (hash-set! had-prop* prop-name 'require)]
           ['- (unless (hash-ref had-prop* prop-name #f)
                 (error 'type-check "~a lacks ~a" actual-ty prop-name))
               (hash-remove! had-prop* prop-name)]
           ['require (hash-set! require-prop* prop-name 'require)]))
       (unless (hash-keys-subset? require-prop* had-prop*)
         (for ([prop-to-remove (hash-keys had-prop*)])
           (hash-remove! require-prop* prop-to-remove))
         (error 'type-check "~a lacks ~a" actual-ty (hash-keys require-prop*)))
       (set-ty:prop-prop*! actual-ty had-prop*))]))
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
         [(symbol? x) (lookup/type-of env x)]
         [else (error (format "unknown form: ~a" x))])]))

(let ()
  (define env (make-hash))
  ; sort : (list {?+sorted}) -> void
  (extend/env env 'sort (ty:-> (list (ty:prop 'list #hash((sorted . ?+))))
                               (ty:prop 'void #hash())))
  ; insert : (list {?-sorted}) -> any -> void
  (extend/env env 'insert (ty:-> (list (ty:prop 'list #hash((sorted . ?-))) (ty:prop 'any #hash()))
                                 (ty:prop 'void #hash())))
  ; binary-search : (list {sorted}) -> any
  (extend/env env 'binary-search (ty:-> (list (ty:prop 'list #hash((sorted . require))))
                                        (ty:prop 'any #hash())))
  (extend/env env 'test-list (ty:prop 'list #hash()))
  (extend/env env 'test-element (ty:prop 'any #hash()))

  (ty-> '(sort test-list) (ty:prop 'void #hash()) #:env env)
  ;;; uncomment this one or reorder sort/binary-search would be type error
  #;(ty-> '(insert test-list) (ty:prop 'void #hash()) #:env env)
  (ty-> '(binary-search test-list) (ty:prop 'any #hash()) #:env env))

(let ()
  (define env (make-hash))
  ; println : (string {-owned}) -> void
  (extend/env env 'println (ty:-> (list (ty:prop 'string #hash((owned . -))))
                                  (ty:prop 'void #hash())))
  (extend/env env 'hello-world (ty:prop 'string #hash((owned . require))))

  (ty-> '(println hello-world) (ty:prop 'void #hash()) #:env env)
  ;;; uncomment this one would cause a type error
  #;(ty-> '(println hello-world) (ty:prop 'void #hash()) #:env env))

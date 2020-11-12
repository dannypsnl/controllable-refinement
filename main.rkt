#lang racket

(require racket/hash)

;;; environment
(define (make-env)
  (make-hash))
(define (lookup/type-of env v)
  (hash-ref env v))
(define (extend/env env v t)
  (hash-set! env v t))
;;; type
(struct ty (prop*) #:mutable #:transparent)
(struct ty:-> ty (p* ret) #:mutable #:transparent)
(struct ty:base ty (name) #:mutable #:transparent)

(define (ty-> #:env (env (make-env)) exp expect-ty)
  (ty=? #:env env expect-ty (<-ty exp #:env env)))
(define (ty=? #:env env expect-ty actual-ty [check-prop? #t])
  (unless
      (match* {expect-ty actual-ty}
        [({ty:base _ ty} {ty:base _ ty2})
         (equal? ty ty2)]
        [({ty:-> _ p1* r1} {ty:-> _ p2* r2})
         ;;; when ty=? is not checking application, affect to property should be avoid
         (and (andmap (λ (p1 p2) (ty=? p1 p2 #f #:env env)) p1* p2*) (ty=? r1 r2 #f #:env env))])
    (error 'type-check "expect: ~a, get: ~a" expect-ty actual-ty))
  (when check-prop?
    (let ([prop-operation* (ty-prop* expect-ty)]
          [prop-have* (ty-prop* actual-ty)])
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
        (set-ty-prop*! actual-ty had-prop*)))))
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
  (define env (make-env))
  ; sort : (list {?+sorted}) -> void
  (extend/env env 'sort (ty:-> #hash() (list (ty:base #hash((sorted . ?+)) 'list))
                               (ty:base #hash() 'void)))
  ; insert : (list {?-sorted}) -> any -> void
  (extend/env env 'insert (ty:-> #hash() (list (ty:base #hash((sorted . ?-)) 'list) (ty:base #hash() 'any))
                                 (ty:base #hash() 'void)))
  ; binary-search : (list {sorted}) -> any
  (extend/env env 'binary-search (ty:-> #hash() (list (ty:base #hash((sorted . require)) 'list))
                                        (ty:base #hash() 'any)))
  (extend/env env 'test-list (ty:base #hash() 'list))
  (extend/env env 'test-element (ty:base #hash() 'any))

  (ty-> '(sort test-list) (ty:base #hash() 'void) #:env env)
  ;;; uncomment this one or reorder sort/binary-search would be type error
  #;(ty-> '(insert test-list) (ty:base #hash() 'void) #:env env)
  (ty-> '(binary-search test-list) (ty:base #hash() 'any) #:env env))

(let ()
  (define env (make-env))
  ; println : (string {-owned}) -> void
  (extend/env env 'println (ty:-> #hash() (list (ty:base #hash((owned . -)) 'string))
                                  (ty:base #hash() 'void)))
  (extend/env env 'hello-world (ty:base #hash((owned . require)) 'string))

  (ty-> '(println hello-world) (ty:base #hash() 'void) #:env env)
  ;;; uncomment this one would cause a type error
  #;(ty-> '(println hello-world) (ty:base #hash() 'void) #:env env))

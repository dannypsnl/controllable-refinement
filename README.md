# controllable-refinement

Refinement type, which introduces predicate into type system and helpful for real programming task. In this repository, I'm going to show a refinement type system with user-controlled predicate, such predicate provides more advanced ability.

Implementation was in `main.rkt`, this version based on **STLC**, and basically show the idea.

### Description

In this system, the most important is **property**, user-controllable predicate. Polymorphism was introduced to provide more example for convience. A base type must be `T`, a polymorphism use application form in **racket** `[T a, b, c, ...]` where `T` is type and `a`, `b`, `c` are type variable, finally, a type with property use `(T {P1, P2, P3, ...})`, predicate can have `+`, `?+`, `-`, and `?-` these operations. Formal rules can be found in this [pdf](https://github.com/dannypsnl/controllable-refinement/blob/develop/scribblings/controllable-refinement.pdf).

#### Example

The first example is sorted property, `sort` function makes a list became `sorted`, but `insert` could break this property.

```
(: sort (-> (list {?+sorted} a) void))
(: insert (-> (list {?-sorted} a) a void))
(: binary-search (-> (list {sorted} a) a))
```

Second example is making the ownership system.

```
(: println (-> (string {-owned}) void))
(: hello-world string{owned})
(println hello-world)
(println hello-world) ;;; compile error, `hello-world` is not `owned` now.
```

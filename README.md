# controllable-refinement

Refinement type, which introduces predicate into type system and helpful for real programming task. In this repository, I'm going to show a refinement type system with user-controlled predicate, such predicate provides more advanced ability.

Implementation was in `main.rkt`, this version based on **STLC**, and basically show the idea.

### Description

In this system, the most important is **property**, user-controlled predicate. With or without polymorphism is not important, but for convience, let's introduces it to provide more example. A base type must be `T`, a polymorphism use application form in **racket** `[T a, b, c, ...]` where `T` is type and `a`, `b`, `c` are type variable, finally, a type with property use `(T {P1, P2, P3, ...})`. Polymorphism with property is valid. `+ Property` would introduce new property if it doesn't existed, `- Property` do remove if existed that property. Without `+/-` then the property is required. In this case, we ensure that `binary-search` would only get `sorted` list as expected.

#### Example

The first example is sorted property, `sort` function makes a list became `sorted`, but `insert` could break this property.

```
(: sort (-> (list {+sorted} a) void))
(: insert (-> (list {-sorted} a) a void))
(: binary-search (-> (list {sorted} a) a))
```

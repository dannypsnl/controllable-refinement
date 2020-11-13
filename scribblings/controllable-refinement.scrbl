#lang scribble/manual
@require[@for-label[racket/base]
         scribble-math]

@title{controllable-refinement}
@author{Lîm Tsú-thuàn}

The type system based on @bold{STLC}, introducing user-controllable type refinement. Meta type variables are @${A}, @${B}. Meta predicate variable is @${P}. A type with predicate write as @${A_P}, introduce predicate write as @${P_+}, eliminate write as @${P_-}, @${P_{?+}} for anyway introduce, @${P_{?-}} for anyway eliminate.

@itemlist[
@item{verify-predicate @$${
\frac{
    \Gamma , f : A_{P} \rightarrow B , x : A_{P}
}{
    f x : B
}
}}

@item{introduce-predicate @$${
\frac{
    \Gamma , f : (p : A_{P_{+}}) \rightarrow B , x : A
}{
    f x : B , x : A_{P}, p : A
}
}}

@item{eliminate-predicate @$${
\frac{
    \Gamma , f : (p : A_{P_{-}}) \rightarrow B , x : A_{P}
}{
    f x : B , x : A , p : A_{P}
}
}}

@item{anyway-introduce-predicate @$${
\frac{
    \Gamma , f : A_{P_{?+}} \rightarrow B , x : A
}{
    f x : B , x : A_{P}
}
\frac{
    \Gamma , f : A_{P_{?+}} \rightarrow B , x : A_{P}
}{
    f x : B , x : A_{P}
}
}}

@item{anyway-eliminate-predicate @$${
\frac{
    \Gamma , f : A_{P_{?-}} \rightarrow B , x : A_{P}
}{
    f x : B , x : A
}
\frac{
    \Gamma , f : A_{P_{?-}} \rightarrow B , x : A
}{
    f x : B , x : A
}
}}
]

Notice that it can be extended to with polymorphism without changing previous definition.

@section{extension: related predicate}

Sometime we would like to update related predicate, for example:

@racketblock[
(: open (-> (file {writable readable})))
(: write (-> (file {writable}) void))
(: close (-> (file {+close}) void))

(let ([file (open "xxx")])
  (write file "hello")
  (close file)
  (write file "hello")) ;;; error
]

where @code{+close} also means @code{?-readable ?-writable}. This extension is quite simple, we can add related predicate information into environment, rewrite predicates of type while parsing type.

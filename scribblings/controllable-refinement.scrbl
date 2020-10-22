#lang scribble/manual
@require[@for-label[racket/base]
         scribble-math]

@title{controllable-refinement}
@author{Lîm Tsú-thuàn}

The type system based on @bold{STLC}, introducing user-controllable type refinement. Meta type variables are @${A}, @${B}. Meta predicate variable is @${P}. A type with predicate write as @${A_P}, introduce predicate write as @${P_+}, eliminate write as @${P_-}.

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
    \Gamma , f : A_{P_+} \rightarrow B , x : A
}{
    f x : B , x : A_{P}
}
\frac{
    \Gamma , f : A_{P_+} \rightarrow B , x : A_{P}
}{
    f x : B , x : A_{P}
}
}}

@item{eliminate-predicate @$${
\frac{
    \Gamma , f : A_{P_-} \rightarrow B , x : A_{P}
}{
    f x : B , x : A
}
\frac{
    \Gamma , f : A_{P_-} \rightarrow B , x : A
}{
    f x : B , x : A
}
}}
]

Notice that it can be extended to with polymorphism without changing previous definition.

Red[]

; some tests

#include %..\curry.Red ; include the red curry library

;-- a test function with multiple arguments and refinements

foo: function [
	{a foo function}
    a b [any-type!] c [any-type!] "just some vars"
    /add1 r1 "a ref"
    /add2 s1 [any-type!] s2 [any-type!] "with two args"
    /add3 t1 t2 t3 "this has three"
    /neg /double /square "some options"
    /local l1 l2 l3
    /extern x1 x2 x3 "what is this?"
    return: [any-type!] "return val"
][
	; some actions
    l1: 1 l2: 2 l3: 3
    r: a + b + c
    if add1 [r: r + r1]
    if add2 [r: r + s1 + s2]
    if add3 [r: r + t1 + t2 + t3]
    if neg [r: negate r]
    if double [r: r * 2]
    if square [r: r ** 2]
	r ; return this
]

;-- "curry" is the name of this currying function, "c!" is a shortcut for it. you can use "curry" or "c!" in your code

;-- basic usage

f: c! foo [1] ; this will curry foo and fixing its first argument (a) to 1
;== func [b c][foo 1 b c] ; the result is a function having two open arguments b and c

f: c!/doc foo [1] ; this will add a docstring showing that its a curried function from "foo" and how it was curried 
;== func ["Curried by: c! foo [1]" b c][foo 1 b c]

f: c!/anon foo [1] ; this will specify the curry function to use an anonymous copy of the original function
;== func [b c /local l1 l2 l3 r][func [
;    "a foo function"
;    a b [any-t...
?? f ; you can check how the function's code were actually embedded in the curried function

;-- testing skipped arguments and refinements

f: c! foo [1 _ 2 /add3 _ _ 3] ; this will fix a, skip b, and fix c. we use a refinement "/add3" which have three more arguments, but we'll skip the first two of them
;== func [b t1 t2][foo/add3 1 b 2 t1 t2 3]

f: c! foo [1 _ 2 /add3 _ _ 3 /square/neg] ; this shows we're using more refinements. refinement that don't have args can be written directly with no space needed in-between
;== func [b t1 t2][foo/add3/square/neg 1 b 2 t1 t2 3]

print f 2 3 4 ; just test if the actual calculation is correct
;== 225

;-- currying some Red's natives functions
reverse: c! sort [_ /reverse] ; we're curried a native function "sort" using its "reverse" refinement to alter it's behavior and given a new name "reverse" to it
;== func [
;    series
;][sort/reverse
;series]

print reverse [2 5 3 4 6 3 0 9] ; testing it
;== [9 6 5 4 3 3 2 0]

;-- we're showing a simple application of currying native functions to create an abstraction of code my a special use case, enhancing readability and conciseness

stack: copy [] ; our stack data structure is a block

push: c! append [stack _] ; we create a "push" function accepting one argument to push it to our stack
?? push ; this will display the resulting code of this function
;== func [
;    value
;][append stack
;value]

pop: c! take [stack /last] ; we create a "pop" function to pop it from our stack
?? pop ; to show the code
;== func [][take/last stack]

; some neat operation using the curried functions: push and pop

print push 3 push 5 
;== [3 5]

print push pop * pop
;== [15]

print push 2
;== [15 2]

print x: pop
;== 2

print push pop / x
;== [7.5]


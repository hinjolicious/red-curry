Red[]

; some tests

#include %..\curry.Red

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

f: c! foo [1]
;== func [b c][foo 1 b c]

f: c!/doc foo [1]
;== func ["Curried by: c! foo [1]" b c][foo 1 b c]

f: c!/anon foo [1]
;== func [b c /local l1 l2 l3 r][func [
;    "a foo function"
;    a b [any-t...
?? f

f: c! foo [1 _ 2 /add3 _ _ 3]
;== func [b t1 t2][foo/add3 1 b 2 t1 t2 3]

f: c! foo [1 _ 2 /add3 _ _ 3 /square/neg]
;== func [b t1 t2][foo/add3/square/neg 1 b 2 t1 t2 3]

print f 2 3 4
;== 225

reverse: c! sort [_ /reverse]
;== func [
;    series
;][sort/reverse
;series]

print reverse [2 5 3 4 6 3 0 9]
;== [9 6 5 4 3 3 2 0]

stack: copy []
;== []

print mold push: c! append [stack _]
;== func [
;    value
;][append stack
;value]

print mold pop: c! take [stack /last]
;== func [][take/last stack]

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

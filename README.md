# Currying for Red

Currying support for the [Red programming language](https://www.red-lang.org/).
This library provides a convenient way to **fix arguments**, **skip placeholders**, and **use refinements** when building specialized versions of existing functions.

---

## ✨ Features

* Fix multiple arguments at once:

  ```red
  f: curry foo [1 2 3]
  ```
* Skip arguments with `_` placeholders:

  ```red
  f: curry foo [_ _ 3]
  ```
* Full refinement support:

  ```red
  f: curry foo [_ 1 /ref 1 _ 3]
  ```
* Works with both **normal** and **native functions**.
* Optionally generate docstrings:

  ```red
  f: curry/doc foo [1]
  ```
* Create anonymous curried copies of functions:

  ```red
  f: curry/anon foo [1]
  ```

---

## 📦 Installation

Clone or download this repo and include the module in your project:

```red
#include %curry.red
```

You now have access to:

* `curry` — the main currying function
* `c!` — a short alias for `curry`

---

## 🚀 Usage

### Basic Example

```red
foo: func [a b c d][a + b + c + d]

f: curry foo [1 2]   ; fix a & b
f 3 4
;== 10
```

### Skipping with Placeholders

```red
f: curry foo [_ 2]   ; skip a, fix b
f 10 5
;== 17
```

### Refinements

```red
bar: func [a b /plus c /square][either square [a * a + b][a + b] + any [c 0]]

f: curry bar [1 2 /plus 5 /square]
f
;== 1 * 1 + 2 + 5 = 8
```

### Native Functions

```red
half: curry divide [_ 2]
half 10
;== 5
```

### Docstring

```red
square: curry/doc power [_ 2]  ; add docstring
help square
USAGE:
     SQUARE number

DESCRIPTION: 
     Curried by: curry power [_ 2]. 
     SQUARE is a function! value.

ARGUMENTS:
     number  
```

### Anonymous Copy

```red
foo: func [a b c][a + b + c]
f1: curry foo [1 2]
;== func [c][foo 1 2 c]   ; calling original function
f1: curry/anon foo [1 2]  ; using annonymous copy
;== func [c][func [a b c] [a + b + c] 1 2 c]
```

### Nested Currying

```red
foo: func [a b c d e f][a + b + c + d + e + f]	; original function
f1: curry foo [1 2]				; curry it, fixed a and b
;== func [c d e f][foo 1 2 c d e f]
f2: curry f1 [_ _ 5 6]				; curry it again, now skip c and d, fix e and f
;== func [c d][f1 c d 5 6]
f2 3 4						; call f2, give open arguments c and d
;== 21
 
```

### More complex example

```red
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
; currying foo, fixing a, skip b, fix c
; using refinement /add3 fixing only t3 and more refinements: /square and /neg
f: c! foo [1 _ 2 /add3 _ _ 3 /square/neg]
;== func [b t1 t2][foo/add3/square/neg 1 b 2 t1 t2 3]

print f 2 3 4 ; call the curried function and give it's open arguments: b, t1 and t2
;== 225
```

---

## 🔍 Feature Comparison with Other Languages & Libraries

| Feature                               | `curry`(This Library) | Ramda.js | Haskell | Python `functools.partial` | Lodash FP |
| ------------------------------------- | ----------------------- | -------- | ------- | ---------------------------- | --------- |
| **Placeholder Support (`_`)** | ✅                      | ✅       | ❌      | ❌                           | ✅        |
| **Argument Skipping**           | ✅                      | ✅       | ❌      | ❌                           | ✅        |
| **Multiple Argument Fixing**    | ✅                      | ✅       | ✅      | ✅                           | ✅        |
| **Refinement Support**          | ✅                      | ❌       | ❌      | ❌                           | ❌        |
| **Multi-Argument Refinements**  | ✅                      | ❌       | ❌      | ❌                           | ❌        |
| **Auto-Generated Docstrings**   | ✅                      | ❌       | ❌      | ❌                           | ❌        |
| **Native Syntax Integration**   | ✅                      | ❌       | ❌      | ❌                           | ❌        |
| **Anonymous Function Option**   | ✅                      | ❌       | ❌      | ❌                           | ❌        |
| **Handles Native Functions**    | ✅                      | ✅       | ✅      | ✅                           |           |

* The table is from an AI model asked about this library.

## 🛠 Limitations

* Minimal error handling — errors are passed through to the original function or Red itself.
* Check the function spec before currying it.
* Educational purpose, use at your own risk.

---

## 📜 License

Open source, free to use. *“Use it, enhance it, improve it and share it!”*

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
square: curry/doc power [_ 2]
help square
;== "Curried by: c! power [_ 2]"
```

### Anonymous Copy

```red
f: curry/anon bar [1 _ 3]
```

---

## 🛠 Limitations

* Minimal error handling — errors are passed through to the original function or Red itself.
* Check the function spec before currying it.
* Educational purpose, use at your own risk.

---

## 📜 License

Open source, free to use. *“Use it, enhance it, improve it and share it!”*

Red [
    Title: "Currying function in Red"
    Version: 2.4.5
    Author: "Hinjolicious"
    Features: {
        1. Fixing/closures of multiple arguments at the same time.
        2. Skipping arguments with "_" in positional or refinement arguments.
        3. Handle refinements 
        4. Curry normal and (most) native functions.
        5. Generate docstring for the curried functions (use /doc).
        6. Curry using the original function or a annonymous copy of it. (use /anon).
    }
    Usage: {
        1. foo: func [a b c d][a + b + c + d]
           f: c! foo [1 2] ; fixing a & b
        2. f: c! foo [_ 2] ; skip a, fix b
        3. f: c! bar [1 2 /plus 5 /square]
        4. half: c! divide [_ 2] ; divide is a native function
        5. square: c!/doc power [_ 2] ; generate curry info
        6. f: c!/anon bar [1 _ 3]
    }
    Limitation: {
        1. Check your original function, before currying it.
        2. Safety/error handling is minimal/barely exist.
        3. This for educational purpose, use at your own risks.
    }
]

;-- parse curry spec --

parse-curry-spec: function [
    "Parse curry specification and refinements"
    spec [block!]
][
    args: copy []
    refs: make map! []
    current-ref: none
    
    parse spec [
        any [
            ; handle refinements
            set refinement refinement! (
                refinement: to-word refinement
                current-ref: refinement
                put refs current-ref copy []
            )
            |
            ; handle placeholders (_)
            quote _ (
                either current-ref 
                    [ append select refs current-ref '_ ]
                    [ append args '_ ]
            )
            |
            ; handle literal values
            set value [integer! | float! | string! | word! | block! | path!] (
                either current-ref 
                    [ append/only select refs current-ref value ]
                    [ append/only args value ]
            )
            |
            skip
        ]
    ]
    reduce [args refs]
]

;-- parse spec from the original function, and separate into [args] and #[refs_map]

parse-spec: function [
	"Parse function spec, tracking multi-arg refinements"
	spec [block!]
][
	args: copy []
	refs: make map! []
	current-ref: none
	in-local?: false
	in-extern?: false
	
	parse spec [
		any [
			; handle mode switches
			set current-ref refinement! (
				if (to-word current-ref) = 'local  [in-local?:  true]
				if (to-word current-ref) = 'extern [in-extern?: true]
				unless any [in-local? in-extern?] [
					put refs current-ref copy [] ; initialize with empty block
				]
			)
			; capture arguments (including multi-refinement args)
			| if (all [not in-local? not in-extern?]) [
				set arg word! (
					either current-ref 
						[append select refs current-ref arg] ; add to refinement's args
						[append args arg]
				)
			]
			| skip
		]
	]
	reduce [args refs] ; args: [a b], refs: #[/plus [c d] /square []]
]

;-- CURRYING FUNCTION --

c!: function [
	{Currying function with multiple arguments closures, skipping arguments, handle refinements.}
    'fn [word!]             "Function name"
    curry_spec [block!]     "Curry specification with placeholders and refinements [1 _ 3 /plus 4 /min 5]"
    /doc                    "Create docstring"
    /anon                   "Using function's anonymous copy"
][
    parsed_curry_spec: parse-curry-spec curry_spec ; from parse-curry-spec
    curry_args: parsed_curry_spec/1 ; positional args [1 _ 3]
    curry_refs: parsed_curry_spec/2 ; refinements as map #[ add3: [_ 2 3] ]
	
    func_spec: parse-spec spec-of get fn ; spec info of the original function
    func_args: func_spec/1 ; positional args
    func_refs_map: func_spec/2 ; refinements as map #[ /add1 [r1] /add2 [s1 s2] ... ]

    ; 1. process positional args

    fixed_args: make map! [] ; to store name and val of fixed args
    remaining_args: copy []  ; open args for the curried function
    pos: 1

    foreach arg func_args [ ; walk thru each pos args
        case [
            pos > length? curry_args [
                append remaining_args arg ; no more curry, add to remaining
            ]
            curry_args/:pos = '_ [
                append remaining_args arg ; placeholder, add to remaining
                pos: pos + 1
            ]
            true [
                put fixed_args arg curry_args/:pos ; store fixed arg's name and value
                pos: pos + 1
            ]
        ]
    ]

    ; 2. process refinements

    applied_ref_args: copy [] ; to store applied refinement args
    ref_string: copy "" ; build refinement string

    foreach [ref_name ref_args] to-block curry_refs [

        append ref_string rejoin ["/" ref_name] ; add refinement to call string
        original_ref_args: func_refs_map/(to-refinement ref_name) ; get the original refinement's argument names

        foreach arg_name original_ref_args [ ; process each argument of this refinement
            case [
                empty? ref_args [ ; no more args provided
                    append remaining_args arg_name
                    append applied_ref_args arg_name
                ]
                ref_args/1 = '_ [
                    append remaining_args arg_name ; placeholder becomes the actual arg name
                    append applied_ref_args arg_name
                    ref_args: next ref_args
                ]
                true [
                    append/only applied_ref_args ref_args/1 ; fixed refinement value
                    ref_args: next ref_args
                ]
            ]
        ]
    ]

    ; 3. process applied args

    applied-args: collect [
        foreach arg func_args [
            either val: select fixed_args arg [
                keep/only val ; preserves the block structure
            ][
                keep arg ; unfixed args remain as words
            ]
        ]
    ]

    if doc [ ; add docstring
        insert remaining_args rejoin [ "Curried by: c! " (:fn) " " (mold curry_spec) ] 
    ]

	do compose/deep [ 
		function [(remaining_args)] [ 
			( load rejoin [ (mold either anon [get fn][:fn]) (ref_string) ] ) (applied-args) (applied_ref_args) 
		] 
	]
]

;-- END ---

; some tests
comment {
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


>> f: c! foo [1]
== func [b c][foo 1 b c]
>> f: c!/doc foo [1]
== func ["Curried by: c! foo [1]" b c][foo 1 b c]
>> f: c!/anon foo [1]
== func [b c /local l1 l2 l3 r][func [
    "a foo function"
    a b [any-t...
>> ?? f
f: func [b c /local l1 l2 l3 r][func [
    "a foo function"
    a b [any-type!] c [any-type!] "just some vars"
    /add1 r1 "a ref"
    /add2 s1 [any-type!] s2 [any-type!] "with two args"
    /add3 t1 t2 t3 "this has three"
    /neg /double /square "some options"
    /local l1 l2 l3 r
] [
    l1: 1 l2: 2 l3: 3
    r: a + b + c
    if add1 [r: r + r1]
    if add2 [r: r + s1 + s2]
    if add3 [r: r + t1 + t2 + t3]
    if neg [r: negate r]
    if double [r: r * 2]
    if square [r: r ** 2]
    r
] 1 b c]
>> f: c! foo [1 _ 2 /add3 _ _ 3]
== func [b t1 t2][foo/add3 1 b 2 t1 t2 3]
>> f: c! foo [1 _ 2 /add3 _ _ 3 /square/neg]
== func [b t1 t2][foo/add3/square/neg 1 b 2 t1 t2 3]
>> f 2 3 4
== 225
>> reverse: c! sort [_ /reverse]
== func [
    series
][sort/reverse
series]
>> reverse [2 5 3 4 6 3 0 9]
== [9 6 5 4 3 3 2 0]
>> 

>> stack: copy []
== []
>> push: c! append [stack _]
== func [
    value
][append stack
value]
>> pop: c! take [stack /last]
== func [][take/last stack]
>> push 3 push 5
== [3 5]
>> push pop * pop
== [15]
>> push 2
== [15 2]
>> x: pop
== 2
>> push pop / x
== [7.5]
>> 
}

(source-directories '("." "./sk-tests/" "../"))
(load "testdefs.scm")
(load "sk.scm")

;;; Testing Predicate Constraint System

;;; ==== Testing constraint-compiler ====
; Empty emitter
(test-check "testpcx.tex-constraint-compiler-1"
(constraint-compiler `() `(= 1 1))

`())

; One emitter
(test-check "testpcx.tex-constraint-compiler-2"
(constraint-compiler `((p0 x)) `(= x 1))

`((p0 (((p0 x)) (= x 1)))))

; Duplicated emitters
(test-check "testpcx.tex-constraint-compiler-3"
(constraint-compiler `((p0 x) (p0 y)) `(= x y))

`((p0 (((p0 x) (p0 y)) (= x y)))))

; Two emitters
(test-check "testpcx.tex-constraint-compiler-4"
(constraint-compiler `((p0 x) (q1 y)) `(= x y))

`((p0 (((p0 x) (q1 y)) (= x y)))
  (q1 (((q1 y) (p0 x)) (= x y)))))

; Three emitters
(test-check "testpcx.tex-constraint-compiler-5"
(constraint-compiler `((p0 x) (q1 y) (q0 z)) `(and (= x y) (= x z)))

`((p0 (((p0 x) (q1 y) (q0 z)) (and (= x y) (= x z))))
  (q1 (((q1 y) (p0 x) (q0 z)) (and (= x y) (= x z))))
  (q0 (((q0 z) (p0 x) (q1 y)) (and (= x y) (= x z))))))

; Three emitters and duplicated two
(test-check "testpcx.tex-constraint-compiler-6"
(constraint-compiler `((q1 y) (p0 x) (q1 z)) `(and (= x y) (= x z)))

`((p0 (((p0 x) (q1 y) (q1 z)) (and (= x y) (= x z))))
  (q1 (((q1 y) (p0 x) (q1 z)) (and (= x y) (= x z))))))

;;; ==== Testing constraint-emitter ====
; Positive emitter
(test-check "testpcx.tex-constraint-emitter-1"
(constraint-emitter (p x))

`(p0 x))

; Negative emitter
(test-check "testpcx.tex-constraint-emitter-2"
(constraint-emitter (noto (p x)))

`(p1 x))

;;; ==== Testing constrainto ====
;;; No emitter
(reset-program)
(test-check "testpcx.tex-constrainto-1"
((lambda ()
  (constrainto () ())
  #t))

#t)

;;; No verifier
(reset-program)
(test-check "testpcx.tex-constrainto-2"
((lambda ()
  (constrainto ((p x)) ())
  constraint-rules))

`((p0 (((p0 x)) (and)))))

;;; One negative emitter
(reset-program)
(test-check "testpcx.tex-constrainto-3"
((lambda ()
  (constrainto ((noto (q y))) ((= y 1)))
  constraint-rules))

`((q1 (((q1 y)) (and (= y 1))))))

;;; One positive emitter
(reset-program)
(test-check "testpcx.tex-constrainto-4"
((lambda ()
  (constrainto ((r z)) ((= z 2)))
  constraint-rules))

`((r0 (((r0 z)) (and (= z 2))))))

;;; Mixed negative and positive emitters
(reset-program)
(test-check "testpcx.tex-constrainto-5"
((lambda ()
  (constrainto ((s a) (noto (t b))) ((= a 3) (= b 4)))
  constraint-rules))

`((s0 (((s0 a) (t1 b)) (and (= a 3) (= b 4))))
  (t1 (((t1 b) (s0 a)) (and (= a 3) (= b 4))))))

; Three emitters and duplicated two
(reset-program)
(test-check "testpcx.tex-constrainto-6"
((lambda ()
  (constrainto ((noto (q y)) (p x) (noto (q z))) ((= x y) (= x z)))
  constraint-rules))

`((p0 (((p0 x) (q1 y) (q1 z)) (and (= x y) (= x z))))
  (q1 (((q1 y) (p0 x) (q1 z)) (and (= x y) (= x z))))))

;;; ==== Testing quote-symbol ====
(test-check "testpcx.tex-quote-symbol"
(quote-symbol (1 "blue" green))

`('1 '"blue" 'green))

;;; ==== Testing constraint-constructor ====
;;; One layer
(test-check "testpcx.tex-constraint-constructor-1"
(constraint-constructor (x y) (1 2) (and (= x y) (= a b)))

`((lambda (x y) (and (= x y) (= a b))) 1 2))

;;; Cascade macros (internal treated as data, not program)
(test-check "testpcx.tex-constraint-constructor-2"
(constraint-constructor (a b) (3 4) 
    (constraint-constructor (x y) (1 2) (and (= x y) (= a b))))

`((lambda (a b)
   (constraint-constructor (x y) (1 2) (and (= x y) (= a b))))
  3
  4))

;;; Cascade invoke multiple layers (using unquote to eval internal macro)
(test-check "testpcx.tex-constraint-constructor-3"
(constraint-constructor (a b) (3 4) 
    ,(constraint-constructor (x y) (1 2) (and (= x y) (= a b))))

`((lambda (a b) ((lambda (x y) (and (= x y) (= a b))) 1 2)) 3 4))

;;; Eval to false
(test-check "testpcx.tex-constraint-constructor-4"
(eval (constraint-constructor (a b) (3 4) 
    ,(constraint-constructor (x y) (1 1) (and (= x y) (> a b)))))

#f)

;;; Eval to true
(test-check "testpcx.tex-constraint-constructor-5"
(eval (constraint-constructor (a b) ('g 'g) 
    ,(constraint-constructor (x y) (42 42) (and (= x y) (eq? a b)))))

#t)

;;; ==== Testing constraint-checker ====
;;; No matched emitter name
(test-check "testpcx.tex-constraint-checker-1"
(constraint-checker 'q1 `(2) `((p0 (((p0 x)) (and (= x 1))))))

#f)

;;; No ready verifier (length > 0)
(test-check "testpcx.tex-constraint-checker-2"
(constraint-checker 'q1 `(2) `((p0 (((p0 x) (q1 y)) (and (= x 1) (= y 2))))
                               (q1 (((q1 y) (p0 x)) (and (= x 1) (= y 2))))))

#f)

;;; Check returns false
(test-check "testpcx.tex-constraint-checker-3"
(constraint-checker 'p0 `(2) `((p0 (((p0 x)) (and (= x 1))))))

#f)

;;; Check returns true
(test-check "testpcx.tex-constraint-checker-4"
(constraint-checker 'p0 `(2) `((p0 (((p0 x)) (and (> x 1))))))

#t)

;;; ==== Testing constraint-updater ====
;;; No matched emitter name
(reset-program)
(test-check "testpcx.tex-constraint-updater-1"
(constraint-updater 'q1 `(2) `((p0 (((p0 x)) (and (= x 1))))))

`())

;;; No pending emitter (length = 0)
(test-check "testpcx.tex-constraint-updater-2"
(constraint-updater 'p0 `(2) `((p0 (((p0 x)) (and (= x 1))))))

`())

;;; Updated constraint rules
(test-check "testpcx.tex-constraint-updater-3"
(constraint-updater 'q1 `(2) `((p0 (((p0 x) (q1 y)) (and (= x 1) (= y 2))))
                               (q1 (((q1 y) (p0 x)) (and (= x 1) (= y 2))))))

`((p0 (((p0 x)) ((lambda (y) (and (= x 1) (= y 2))) '2)))))

;;; ==== Testing constraint-emitter-matched-constants? ====
; No constants in parameters
(test-check "testpcx.tex-constraint-emitter-matched-constants-1"
(constraint-emitter-matched-constants? `(a b) `('0 'hello))

#t)

; No matched constants
(test-check "testpcx.tex-constraint-emitter-matched-constants-2"
(constraint-emitter-matched-constants? `(a 0) `('a '1))

#f)

; Matched constants (symbol, number, string, list)
(test-check "testpcx.tex-constraint-emitter-matched-constants-3"
(constraint-emitter-matched-constants?
  `(a   0 'a b         "world" (list 'tomato 'potato))
  `('a '0 'a '"hello" '"world" (list 'tomato 'potato)))

#t)

;;; ==== Testing constraint-emitter-remove-constants ====
; Empty list
(test-check "testpcx.tex-constraint-emitter-remove-constants-1"
(constraint-emitter-remove-constants `() `())

`(() ()))

; All constants (symbol, number, string, list)
(test-check "testpcx.tex-constraint-emitter-remove-constants-2"
; The values does not matter, see assumption in the comment
(constraint-emitter-remove-constants `('r 1 "hello" (list 'foo 'bar)) `('s 0 "world" (list 'tomato 'potato)))

`(() ()))

; Reverse ordering (symbol, number, string, list)
(test-check "testpcx.tex-constraint-emitter-remove-constants-3"
; The ordering does not matter as long as they matched the values
(constraint-emitter-remove-constants `(s n str lst) `('s 0 "world" (list 'tomato 'potato)))

`((lst str n s) ((list 'tomato 'potato) "world" 0 's)))

;;; ==== Testing constraint-emitter-reorder ====
; Untouched
(test-check "testpcx.tex-constraint-emitter-reorder-1"
(constraint-emitter-reorder 'apple `((assign 's sv) (assign 'e ev) (assign p pv)) `('e '1))

`((assign 's sv) (assign 'e ev) (assign p pv)))

; Matched variable
(test-check "testpcx.tex-constraint-emitter-reorder-2"
(constraint-emitter-reorder 'assign `((assign 's sv) (assign 'e ev) (assign p pv) (assign q qv)) `('a '1))

`((assign p pv) (assign 's sv) (assign 'e ev) (assign q qv)))

; Matched constant
(test-check "testpcx.tex-constraint-emitter-reorder-3"
(constraint-emitter-reorder 'assign `((assign 's sv) (assign 'e ev) (assign p pv) (assign q qv)) `('e '0))

`((assign 'e ev) (assign 's sv) (assign p pv) (assign q qv)))

; Variable before constant
; To show the caller must ensure the constants are before the variables
(test-check "testpcx.tex-constraint-emitter-reorder-4"
(constraint-emitter-reorder 'assign `((apple 's sv) (assign p pv) (assign 'e ev) (assign q qv)) `('e '0))

`((assign p pv) (apple 's sv) (assign 'e ev) (assign q qv)))

;;; ==== Testing constraint-emitter-filter ====
; Unmatched name
(test-check "testpcx.tex-constraint-emitter-filter-1"
(constraint-emitter-filter 'apple `((assign 's sv) (assign p pv) (assign 'e ev) (assign q qv)) `('e '0))

#f)

; Unmatched constants (no variables)
(test-check "testpcx.tex-constraint-emitter-filter-2"
(constraint-emitter-filter 'assign `((assign 's sv) (assign 'p pv) (assign 'e ev) (assign 'q qv)) `('r '0))

#f)

; Matched variables (unmatched constants)
(test-check "testpcx.tex-constraint-emitter-filter-3"
(constraint-emitter-filter 'assign `((assign 's sv) (assign p pv) (assign 'e ev) (assign q qv)) `('r '0))

#t)

; Matched constants (no variables)
(test-check "testpcx.tex-constraint-emitter-filter-4"
(constraint-emitter-filter 'assign `((assign 's sv) (assign 'p pv) (assign 'e ev) (assign 'q qv)) `('e '0))

#t)

; Matched constants and variables (only the first match will be used later)
(test-check "testpcx.tex-constraint-emitter-filter-5"
(constraint-emitter-filter 'assign `((assign 's sv) (assign p pv) (assign 'e ev) (assign q qv)) `('e '0))

#t)

;;; ==== Integrated testing ====
;;; Integrate constraint-updater and constraint-checker
(test-check "testpcx.tex-variable-constraint-1"
(constraint-checker 'p0 `(1)
  (constraint-updater 'q1 `(2) `((p0 (((p0 x) (q1 y)) (and (= x 1) (= y 2))))
                               (q1 (((q1 y) (p0 x)) (and (= x 1) (= y 2)))))))

#t)

(test-check "testpcx.tex-variable-constraint-2"
(constraint-checker 'p0 `(2)
  (constraint-updater 'q1 `(1) `((p0 (((p0 x) (q1 y)) (and (= x 1) (= y 2))))
                               (q1 (((q1 y) (p0 x)) (and (= x 1) (= y 2)))))))

#f)

(test-check "testpcx.tex-constant-constraint-1"
(constraint-checker 'p0 `(1 1)
  (constraint-updater 'q1 `(1 2) `((p0 (((p0 1 x) (q1 1 y)) (and (= x 1) (= y 2))))
                               (q1 (((p0 1 x) (q1 1 y)) (and (= x 1) (= y 2)))))))

#t)

(test-check "testpcx.tex-constant-constraint-2"
(constraint-checker 'p0 `(2 2)
  (constraint-updater 'q1 `(2 1) `((p0 (((p0 2 x) (q1 2 y)) (and (= x 1) (= y 2))))
                               (q1 (((p0 2 x) (q1 2 y)) (and (= x 1) (= y 2)))))))

#f)

(test-check "testpcx.tex-variable-and-constant-constraint-1"
(constraint-checker 'p0 `(1 1)
  (constraint-updater 'q1 `(1 2) `((p0 (((p0 1 x) (q1 z y)) (and (= x 1) (= y 2))))
                               (q1 (((p0 1 x) (q1 z y)) (and (= x 1) (= y 2)))))))

#t)

(test-check "testpcx.tex-variable-and-constant-constraint-2"
(constraint-checker 'p0 `(2 2)
  (constraint-updater 'q1 `(2 1) `((p0 (((p0 2 x) (q1 z y)) (and (= x 1) (= y 2))))
                               (q1 (((p0 2 x) (q1 z y)) (and (= x 1) (= y 2)))))))

#f)

;;; [ToDo] Sort constant constraint before variable constraint in constrainto
;;; Integrate constrainto, constraint-updater, and constraint-checker
(reset-program)
(constrainto ((p x) (noto (q y))) ((= x 1) (= y 2)))

(test-check "testpcx.tex-variable-constraint-3"
(constraint-checker 'p0 `(1)
  (constraint-updater 'q1 `(2) `()))

#t)

;;; Integrate constrainto, local constraint rules (L), constraint-updater, and constraint-checker
(test-check "testpcx.tex-variable-constraint-4"
(constraint-checker 'p0 `(1)
  (constraint-updater 'q1 `(3) 
                    `((p0 (((p0 x)) ((lambda (y) (and (= x 1) (= y 2))) '2))))))

#f)

(test-check "testpcx.tex-variable-constraint-5"
(constraint-checker 'p0 `(1)
                    `((p0 (((p0 x)) ((lambda (y) (and (= x 1) (= y 2))) '2)))))

#t)

(reset-program)
(constrainto [(p 1 2) (noto (q 2 1))] [])

(test-check "testpcx.tex-constant-constraint-3"
(constraint-checker 'p0 `(1 2)
  (constraint-updater 'q1 `(2 1) `()))

#t)

(test-check "testpcx.tex-constant-constraint-4"
(constraint-checker 'p0 `(1 1)
  (constraint-updater 'q1 `(3 1) 
                    `((p0 (((p0 1 x)) ((lambda (y) (and (= x 1) (= y 2))) '2))))))

#f)

(test-check "testpcx.tex-constant-constraint-5"
(constraint-checker 'p0 `(2 1)
                    `((p0 (((p0 2 x)) ((lambda (y) (and (= x 1) (= y 2))) '2)))))

#t)

;;; Integrate constrainto (special rule), kill all searches.
(reset-program)
(defineo (p x) (== x 1))

; Without killer constraint.
(test-check "testpcx.tex-variable-constraint-6a"
(run* (q) (p q))

`(1))

; Add a constraint has no impact.
(constrainto () (#f #t))
(test-check "testpcx.tex-variable-constraint-6b"
(run* (q) (p q))

`(1))

; Add killer constraint.
(constrainto () ((= 1 1)))
(test-check "testpcx.tex-variable-constraint-6c"
(run* (q) (p q))

`(1))


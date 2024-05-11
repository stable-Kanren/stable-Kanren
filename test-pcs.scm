(load "mktests.scm")

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
  (q1 (((q1 y) (q0 z) (p0 x)) (and (= x y) (= x z))))
  (q0 (((q0 z) (p0 x) (q1 y)) (and (= x y) (= x z))))))

; Three emitters and duplicated two
(test-check "testpcx.tex-constraint-compiler-6"
(constraint-compiler `((q1 y) (p0 x) (q1 z)) `(and (= x y) (= x z)))

`((p0 (((p0 x) (q1 z) (q1 y)) (and (= x y) (= x z))))
  (q1 (((q1 y) (p0 x) (q1 z)) (and (= x y) (= x z))))))

;;; ==== Testing constraint-emitter ====
; Positive emitter
(test-check "testpcx.tex-constraint-emitter-1"
(constraint-emitter (p x))

`(p0 x))

; Negative emitter
(test-check "testpcx.tex-constraint-emitter-1"
(constraint-emitter (noto (p x)))

`(p1 x))

;;; ==== Testing constrainto ====
;;; No emitter
(reset-program)
(test-check "testpcx.tex-constrainto-1"
((lambda ()
  (constrainto () ())
  constraint-rules))

`())

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

`((p0 (((p0 x) (q1 z) (q1 y)) (and (= x y) (= x z))))
  (q1 (((q1 y) (p0 x) (q1 z)) (and (= x y) (= x z))))))

;;; ==== Testing quote-symbol ====
(test-check "testpcx.tex-quote-symbol"
(quote-symbol (1 "blue" green))

`('1 '"blue" 'green))

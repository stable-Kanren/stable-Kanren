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

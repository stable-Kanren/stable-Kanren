(source-directories '("." "./sk-tests/" "../"))
(load "testdefs.scm")
(load "sk.scm")

;;; ==== Testing has-negation? ====
;;; One predicate
(test-check "sktests.tex-has-negation?-0t"
(has-negation? (noto (p x)))

#t)

(test-check "sktests.tex-has-negation?-0f"
(has-negation? (p x))

#f)

(test-check "sktests.tex-has-negation?-1t"
(has-negation? (noto fail))

#t)

(test-check "sktests.tex-has-negation?-1f"
(has-negation? succeed)

#f)

;;; More than one predicate
(test-check "sktests.tex-has-negation?-2t"
(has-negation? (q x) (noto fail))

#t)


(test-check "sktests.tex-has-negation?-2f"
(has-negation? (q x) fail)

#f)

(test-check "sktests.tex-has-negation?-3"
(has-negation? (q x) (noto succeed) fail)

#t)

;;; Combine with conde/fresh
(test-check "sktests.tex-has-negation?-4t"
(has-negation? (fresh (x y) (q x) (noto succeed) fail))

#t)

(test-check "sktests.tex-has-negation?-4f"
(has-negation? (fresh (x y) (q x) succeed fail))

#f)

(test-check "sktests.tex-has-negation?-5t"
(has-negation? (conde [(q x) (noto succeed)] [fail]))

#t)

(test-check "sktests.tex-has-negation?-5f"
(has-negation? (conde [(q x) succeed] [fail]))

#f)

(test-check "sktests.tex-has-negation?-6t"
(has-negation? (fresh (x y) (conde [(q x) (noto succeed)] [fail])))

#t)

(test-check "sktests.tex-has-negation?-6f"
(has-negation? (fresh (x y) (conde [(q x) succeed] [fail])))

#f)

(test-check "sktests.tex-has-negation?-7t"
(has-negation? (conde [(fresh (x) (q x) (noto succeed))] [fail]))

#t)

(test-check "sktests.tex-has-negation?-7f"
(has-negation? (conde [(fresh (x) (q x) succeed)] [fail]))

#f)

;;; ==== Testing ignore-negation ====
(test-check "sktests.tex-ignore-negation-1"
(run* (q) 
  (ignore-negation
    (conde [(fresh (x) (== q 1) (noto succeed) (== x 2))])))

`(1))

(test-check "sktests.tex-ignore-negation-2"
(run* (q)
  (ignore-negation
    (conde [(fresh (x) (== q 1) (noto succeed) (== x 2))]
           [(== q 2) succeed])))

`(2 1))

(test-check "sktests.tex-ignore-negation-3"
(run* (q)
  (ignore-negation
    (conde [(fresh (x) (== q 1) (noto succeed) (== x 2))]
           [(== q 3) succeed])))

`(3 1))

(test-check "sktests.tex-ignore-negation-4"
(run* (q)
  (ignore-negation
    (conde [(fresh (x) (== q 1) (noto succeed) (== x 2))]
           [(noto (== q 3)) succeed])))

`(_.0 1))

(test-check "sktests.tex-ignore-negation-5"
(run* (q)
  (ignore-negation
    (conde [(fresh (x) (== q 1) (noto succeed) (== x 2))]
           [(noto (== q 3)) (== q 4)])))

`(4 1))

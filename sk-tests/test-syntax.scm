(source-directories '("." "./sk-tests/" "../"))
(load "testdefs.scm")
(load "sk.scm")

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

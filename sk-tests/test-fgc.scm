(source-directories '("." "./sk-tests/" "../"))
(load "testdefs.scm")
(load "sk.scm")

;;; ==== Fine grind checking test cases ====

;;; ==== Testing emitter-signature ====
;;; One emitter
(test-check "sktests.tex-emitter-signature-0a"
(emitter-signature (noto (p x)))

`((p 1)))

(test-check "sktests.tex-emitter-signature-0b"
(emitter-signature (q x y z))

`((q 3)))

;;; Complex emitters
(test-check "sktests.tex-emitter-signature-1"
(emitter-signature (q x y z) (noto (p x)))

`((q 3) (p 1)))

;;; ==== Testing emitter-global-checking ====
(reset-program)
(test-check "sktests.tex-emitter-global-checking-0a"
(begin
  (emitter-global-checking (emitter-signature (noto (p x))))
  global-checking-rules)

`((p . 1)))

(reset-program)
(test-check "sktests.tex-emitter-global-checking-0b"
(begin
  (emitter-global-checking (emitter-signature (q x y z) (noto (p x))))
  global-checking-rules)

`((p . 1) (q . 3)))

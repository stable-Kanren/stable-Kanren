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

;;; ==== Testing nqueens lower bound constrainto ====
(reset-program)
(defineo (num x) (conde [(== x 1)] [(== x 2)] [(== x 3)] [(== x 4)]))

; Constraint verification, not solving, so we need num(x), num(y).
(defineo (row x) (fresh (y) (num x) (num y) (queen x y)))
(defineo (col y) (fresh (x) (num x) (num y) (queen x y)))

; Bottom up rules to make sure the lower bound.
(constrainto ((num x) (noto (row u))) ((= x u)))
(constrainto ((num y) (noto (col v))) ((= y v)))


; queen(X,Y) :- not free(X,Y), num(X), num(Y).
(defineo (queen x y) (conde [(num x) (num y) (noto (free x y))]))
; free(X,Y) :- not queen(X,Y), num(X), num(Y).
(defineo (free x y) (conde [(num x) (num y) (noto (queen x y))]))

(constrainto ((queen x y) (queen u v)) ((> x u)))
(constrainto ((queen x y) (queen u v)) ((= x u)))
(constrainto ((queen x y) (queen u v)) ((= y v)))
(constrainto ((queen x y) (queen u v)) ((= (abs (- x u)) (abs (- y v)))))

(test-check "sktests.tex-nqueens"
(length (run* (q) (fresh (y1 y2 y3)
		    	    (queen 1 y1) (queen 2 y2) (queen 3 y3)
					(== q `((1 ,y1) (2 ,y2) (3 ,y3))))))

2)

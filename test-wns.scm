(load "test-val.scm")

;;; Testing Working Normal Program Solver
(reset-program)
; a(1)
(defineo (a x)
  (conde
    [(== x 1)]))

; b(2).
(defineo (b x)
  (conde
    [(== x 2)]))

; p(X) :- a(X), not p(X).
; p(X) :- b(X).
(defineo (p x)
  (conde
    [(a x)
     (noto (p x))]
    [(b x)]))

;;; The above program is unsatisfiable due to the p(1) :- a(1), not p(1).
;;; This global constraint causes a(1) to fail as well.
(test-check "testwns.tex-1a"
(run 1 (q) (a q) )

`())

(test-check "testwns.tex-1b"
(run 1 (q) (b q) )

`())

(test-check "testwns.tex-1p"
(run 1 (q) (p q) )

`())

;;; If we ignore the global constraint and use run-partial to get partial results.
;;; The global constraint p(1) :- a(1), not p(1) is not affecting the result.
;;; Note: This is not stable model semantics expected, but it could be other
;;; useful semantics and applications.
(test-check "testwns.tex-pa"
(run-partial 1 (q) (a q) )

`(1))

(test-check "testwns.tex-pb"
(run-partial 1 (q) (b q) )

`(2))

(test-check "testwns.tex-pp"
(run-partial 1 (q) (p q) )

`(2))


(reset-program)
; a(1)
(defineo (a x)
  (conde
    [(== x 1)]))

; b(1).
; b(2).
(defineo (b x)
  (conde
    [(== x 1)]
    [(== x 2)]))

; p(X) :- a(X), not p(X).
; p(X) :- b(X).
(defineo (p x)
  (conde
    [(a x)
     (noto (p x))]
    [(b x)]))

;;; After adding the fact b(1), p(1) :- a(1), not p(1) won't be a trouble, since
;;; we can prove p(1) via b(1).
(test-check "testwns.tex-2a"
(sort compare-element (remove-duplicates 
  (run* (q) (a q) )))

`(1))

(test-check "testwns.tex-2b"
(sort compare-element (remove-duplicates 
  (run* (q) (b q) )))

`(1 2))

(test-check "testwns.tex-2p"
(sort compare-element (remove-duplicates
  (run* (q) (b q) )))

`(1 2))

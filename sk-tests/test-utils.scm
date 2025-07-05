(source-directories '("." "./sk-tests/" "../"))
(load "testdefs.scm")
(load "sk.scm")

;;; ==== Testing rotate-to-first ====
; Empty list
(test-check "testutil.tex-rotate-to-first-1"
(rotate-to-first 1 `() =)

`())

; Element not in list
(test-check "testutil.tex-rotate-to-first-2"
(rotate-to-first 3 `(1 2) =)

`(1 2))


; First element in the list
(test-check "testutil.tex-rotate-to-first-3"
(rotate-to-first 1 `(1 2 3) =)

`(1 2 3))

; Element in the list
(test-check "testutil.tex-rotate-to-first-4"
(rotate-to-first 2 `(1 2 3) =)

`(2 3 1))

; Last element in the list
(test-check "testutil.tex-rotate-to-first-5"
(rotate-to-first 3 `(1 2 3) =)

`(3 1 2))

;;; ==== Testing move-to-first ====
; Empty list
(test-check "testutil.tex-move-to-first-1"
(move-to-first 6 `() =)

`())

; Element not in list
(test-check "testutil.tex-move-to-first-2"
(move-to-first 7 `(1 2 3 4 5 6) =)

`(1 2 3 4 5 6))

; First element in the list
(test-check "testutil.tex-move-to-first-3"
(move-to-first 1 `(1 2 3 4 5 6) =)

`(1 2 3 4 5 6))

; Element in the list
(test-check "testutil.tex-move-to-first-4"
(move-to-first 3 `(1 2 3 4 5 6) =)

`(3 1 2 4 5 6))

; Last element in the list
(test-check "testutil.tex-move-to-first-5"
(move-to-first 6 `(1 2 3 4 5 6) =)

`(6 1 2 3 4 5))

; Difference between rotate and move
(test-check "testutil.tex-move-to-first-and-rotate-to-first-1"
(equal? (move-to-first 6 `(1 2 3 4 5 6) =) (rotate-to-first 6 `(1 2 3 4 5 6) =))

#t)

(test-check "testutil.tex-move-to-first-and-rotate-to-first-2"
(equal? (move-to-first 3 `(1 2 3 4 5 6) =) (rotate-to-first 3 `(1 2 3 4 5 6) =))

#f)

;;; ==== Testing sym-append-str ====
; Empty string
(test-check "testutil.tex-sym-append-str-1"
(sym-append-str 'a "")

'a)

; Normal case
(test-check "testutil.tex-sym-append-str-2"
(sym-append-str 'a "1")

'a1)

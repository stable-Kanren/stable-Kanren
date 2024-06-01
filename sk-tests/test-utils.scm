(source-directories '("." "../"))
(load "mktests.scm")

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


;;; ==== Testing sym-append-str ====
; Empty string
(test-check "testutil.tex-sym-append-str-1"
(sym-append-str 'a "")

'a)

; Normal case
(test-check "testutil.tex-sym-append-str-2"
(sym-append-str 'a "1")

'a1)

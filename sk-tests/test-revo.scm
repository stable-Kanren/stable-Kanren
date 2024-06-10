(source-directories '("." "./sk-tests/" "../"))
(load "testdefs.scm")
(load "sk.scm")

(reset-program)
(defineo (conso a d p)
    (== (cons a d) p))

(defineo (nullo x)
  (== `() x))

(defineo (revo xs sx)
  (fresh (empty) 
    (nullo empty)
    (rev-acco xs empty sx)))

(defineo (rev-acco xs acc sx)
  (conde
    [(nullo xs) (== sx acc)]
    [(fresh (h t acc1)
      (conso h t xs)
      (conso h acc acc1)
      (rev-acco t acc1 sx))]))

(test-check "sktests.tex-revo"
(run 1 (q) (revo '() '()))

`(_.0))
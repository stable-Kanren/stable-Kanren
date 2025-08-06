(source-directories '("." "./sk-tests/" "../"))
(load "test-utils.scm")
(load "testdefs.scm")
(load "sk.scm")
(load "skdefs.scm")

; Test cases are converted from "mktests.scm"
; ==== Testing caro ====
(test-check "testskdefs.tex-1"
(run* (r)
  (caro `(a c o r n) r))

(list 'a))


(test-check "testskdefs.tex-2"
(run* (q)
  (caro `(a c o r n) 'a)
  (== #t q))

(list #t))


(test-check "testskdefs.tex-3"
(run* (r)
  (fresh (x y)
    (caro `(,r ,y) x)
    (== 'pear x)))

(list 'pear))


(test-check "testskdefs.tex-4"
(run* (r)
  (fresh (x y)
    (caro `(grape raisin pear) x)
    (caro `((a) (b) (c)) y)
    (== (cons x y) r)))

(list `(grape a)))

; ==== Testing cdro ====
(test-check "testskdefs.tex-5"
(run* (r)
  (fresh (v)
    (cdro `(a c o r n) v)
    (caro v r)))

(list 'c))


(test-check "testskdefs.tex-6"
(run* (r)
  (fresh (x y)
    (cdro `(grape raisin pear) x)
    (caro `((a) (b) (c)) y)
    (== (cons x y) r)))

(list `((raisin pear) a)))


(test-check "testskdefs.tex-7"
(run* (q)
  (cdro '(a c o r n) '(c o r n))
  (== #t q))

(list #t))
 

(test-check "testskdefs.tex-8"
(run* (x)
  (cdro '(c o r n) `(,x r n)))

(list 'o))
 

(test-check "testskdefs.tex-9"
(run* (l)
  (fresh (x)
    (cdro l '(c o r n))
    (caro l x)
    (== 'a x)))

(list `(a c o r n)))

; ==== Testing conso ====
(test-check "testskdefs.tex-10"
(run* (l)
  (conso '(a b c) '(d e) l))

(list `((a b c) d e)))


(test-check "testskdefs.tex-11"
(run* (x)
  (conso x '(a b c) '(d a b c)))

(list 'd))


(test-check "testskdefs.tex-12"
(run* (r)
  (fresh (x y z)
    (== `(e a d ,x) r)
    (conso y `(a ,z c) r)))

(list `(e a d c)))


(test-check "testskdefs.tex-13"
(run* (x)
  (conso x `(a ,x c) `(d a ,x c)))

(list 'd))


(define x 'd)       
(test-check "testskdefs.tex-14"
(run* (l)
  (fresh (x)
    (== `(d a ,x c) l)
    (conso x `(a ,x c) l)))

(list `(d a d c)))


(test-check "testskdefs.tex-15"
(run* (l)
  (fresh (x)
    (conso x `(a ,x c) l)
    (== `(d a ,x c) l)))

(list `(d a d c)))


(test-check "testskdefs.tex-16"
(run* (l)
  (fresh (d x y w s)
    (conso w '(a n s) s)
    (cdro l s)
    (caro l x)
    (== 'b x)
    (cdro l d)
    (caro d y)
    (== 'e y)))

(list `(b e a n s)))

; ==== Testing nullo ====
(test-check "testskdefs.tex-17"
(run* (q)
  (nullo `(grape raisin pear))
  (== #t q))

`())

(test-check "testskdefs.tex-18"
(run* (q)
  (nullo '())
  (== #t q))

`(#t))

(test-check "testskdefs.tex-19"
(run* (x)
  (nullo x))

`(()))

; ==== Testing membero ====
(test-check "testskdefs.tex-20"
(run* (q) 
  (membero 'olive `(virgin olive oil))
  (== #t q))

(list #t))

(test-check "testskdefs.tex-21"
(run 1 (y)
  (membero y `(hummus with pita)))

(list `hummus))

(test-check "testskdefs.tex-22"
(run 1 (y)
  (membero y `(with pita)))

(list `with))

(test-check "testskdefs.tex-23"
(run 1 (y)
  (membero y `(pita)))

(list `pita))

(test-check "testskdefs.tex-24"
(run* (y)
  (membero y `()))

`())

(test-check "testskdefs.tex-25"
(run* (y)
  (membero y `(hummus with pita)))

`(hummus with pita))

(test-check "testskdefs.tex-26"
(run* (x)
  (membero 'e `(pasta ,x fagioli)))

(list `e))

(test-check "testskdefs.tex-27"
(run 1 (x)
  (membero 'e `(pasta e ,x fagioli)))

(list `_.0))

(test-check "testskdefs.tex-28"
(run 1 (x)
  (membero 'e `(pasta ,x e fagioli)))

(list `e))

(test-check "testskdefs.tex-29"
(run* (r)
  (fresh (x y)
    (membero 'e `(pasta ,x fagioli ,y))
    (== `(,x ,y) r)))

`((e _.0) (_.0 e)))

(test-check "testskdefs.tex-30"
(run 1 (l)
  (membero 'tofu l))

`((tofu . _.0)))

; Safe variable assumption not allow the following test.
; (test-check "testskdefs.tex-31"
; (run 5 (l)
;   (membero 'tofu l))


; `((tofu . _.0)
;  (_.0 tofu . _.1)
;  (_.0 _.1 tofu . _.2)
;  (_.0 _.1 _.2 tofu . _.3)
;  (_.0 _.1 _.2 _.3 tofu . _.4))
; )

(test-check "testskdefs.tex-31"
(run 5 (l)
  (membero 'tofu l))

`((tofu . _.0)
 (_.0 tofu . _.1))
)

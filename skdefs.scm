(source-directories '("." "./sk-tests/" "../" "../../"))
(load "sk.scm")

(defineo (caro p a)
  (fresh (d)
    (== (cons a d) p)))

(defineo (cdro p d)
  (fresh (a)
    (== (cons a d) p)))

(defineo (conso a d p)
  (== (cons a d) p))

(defineo (nullo x)
  (== '() x))

(defineo (appendo l s out)
  (conde [(nullo l) (== s out)]
         [(fresh (a d res)
            (conso a d l)
            (conso a res out)
            (appendo d s res))]))

(defineo (membero x l)
  (conde [(fresh (a)
            (caro l a)
            (== a x))]
         [(fresh (d)
            (cdro l d)
            (membero x d))]))

; Remove all occurance of x from ls.
; This is not the same as the one defined in The Reasoned Schemer.
; But it's the same as the one defined in cKanren paper.
(defineo (rembero x ls out)
  (conde [(== `() ls) (== `() out)]
         [(fresh (a d res)
            (== `(,a . ,d) ls)
            (rembero x d res)
            (rembero-helper a x res out))]))

(defineo (rembero-helper a x res out)
  (conde [(== a x) (== res out)]
         [(noto (== a x)) (== `(,a . ,res) out)]))

; As the underlying miniKanren is a pure relational language, we need to introduce
; some impure operators just like the "is", ">", "-" in Prolog so that we can
; utilize the modern CPU.
;
; Impure, non-relational arithmetic operations using `project`
; Create a stub twins for program analysis in `defineo`.
(define (project+) succeed)
(define (project-) succeed)

(defineo (gt lhs rhs)
  (project (lhs rhs)
    (if (> lhs rhs)
        succeed
        fail)))

(defineo (sub minuend subtrahend res)
  (project (minuend subtrahend)
    (== res (- minuend subtrahend))))

(defineo (diagonal x y x1 y1)
  (project (x y x1 y1)
    (if (= (abs (- x x1)) (abs (- y y1)))
        succeed
        fail)))

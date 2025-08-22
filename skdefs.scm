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

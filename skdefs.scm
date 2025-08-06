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


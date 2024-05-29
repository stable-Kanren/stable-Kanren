(source-directories '("." "../../"))
(load "mk.scm")

(defineo (num x)
 (conde
   [(== x 1)]
   [(== x 2)]
   [(== x 3)]
   [(== x 4)]
   ; [(== x 5)]
   ; [(== x 6)]
   ; [(== x 7)]
   ; [(== x 8)]
   ; [(== x 9)]
   ; [(== x 10)]
))

; Constraint verification, not solving, so we need num(x), num(y).
(defineo (row x)
  (fresh (y)
       (num x)
       (num y)
       (queen x y)))

(defineo (col y)
  (fresh (x)
       (num x)
       (num y)
       (queen x y)))

; Bottom up rules to make sure the lower bound.
(constrainto ((num x) (noto (row u))) ((= x u)))

(constrainto ((num y) (noto (col v))) ((= y v)))


; queen(X,Y) :- not free(X,Y), num(X), num(Y).
(defineo (queen x y)
 (conde
   [(num x) (num y) (noto (free x y))]))

; free(X,Y) :- not queen(X,Y), num(X), num(Y).
(defineo (free x y)
 (conde
   [(num x) (num y) (noto (queen x y))]))

(constrainto ((queen x y) (queen u v)) ((> x u)))

(constrainto ((queen x y) (queen u v)) ((= x u)))

(constrainto ((queen x y) (queen u v)) ((= y v)))

(constrainto ((queen x y) (queen u v)) ((= (abs (- x u)) (abs (- y v)))))

; Adding a dummy head to predicate constraints, this also requires changes
; in resolution.
; (defineo (false)
;   (conde
;     [(fresh (x y v)
;        (num x) (num y) (num v) (queen x y) (queen x v))]
;     [(fresh (x y u)
;        (num x) (num y) (num u) (queen x y) (queen u y))]))

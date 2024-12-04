(source-directories '("." "../../"))
(load "sk.scm")

; vertex(0).
; vertex(1).
; vertex(2).
; vertex(3).
; vertex(4).
(defineo (vertex x)
 (conde
   ;[(== x 0)]
   [(== x 1)]
   [(== x 2)]
   [(== x 3)]
   [(== x 4)]
   [(== x 5)]
   [(== x 6)]
))

; edge(0, 1).
; edge(1, 2).
; edge(2, 3).
; edge(3, 4).
; edge(4, 0).
; edge(4, 1).
; edge(4, 2).
; edge(4, 3).
(defineo (edge x y)
 (conde
   ;[(== x 0) (== y 1)]
   [(== x 1) (== y 2)]
   [(== x 1) (== y 3)]
   [(== x 1) (== y 4)]
   [(== x 2) (== y 4)]
   [(== x 2) (== y 5)]
   [(== x 2) (== y 6)]
   [(== x 3) (== y 1)]
   [(== x 3) (== y 4)]
   [(== x 3) (== y 5)]
   [(== x 4) (== y 1)]
   [(== x 4) (== y 2)]
   [(== x 5) (== y 3)]
   [(== x 5) (== y 4)]
   [(== x 5) (== y 6)]
   [(== x 6) (== y 2)]
   [(== x 6) (== y 3)]
   [(== x 6) (== y 5)]
))

; reachable(V) :- chosen(U, V), reachable(U).
; reachable(V) :- chosen(1, V).
(defineo (reachable v)
  (conde
    [(chosen 1 v)]
    [(fresh (u) (vertex u) (chosen u v) (reachable u))]))

; :- vertex(U), not reachable(U).
(constrainto ((vertex u) (noto (reachable v))) ((= u v)))

; free(U, V) :- vertex(U), vertex(V), edge(U, V), chosen(U, W).
; chosen(U, V) :- vertex(U), vertex(V), edge(U, V), not free(U, V).
(defineo (chosen u v)
  (vertex u)
  (vertex v)
  (edge u v)
  (noto (free u v)))

(defineo (free u v)
  (vertex u)
  (vertex v)
  (edge u v)
  (noto (chosen u v)))

; :- chosen(U, V), chosen(X, Y), X = U, V != Y.
; :- chosen(U, W), chosen(V, W), X != U, V = Y.
(constrainto ((chosen u v) (chosen x y)) ((= x u) (not (= v y))))
(constrainto ((chosen u v) (chosen x y)) ((not (= x u)) (= v y)))

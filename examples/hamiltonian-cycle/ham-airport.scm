(source-directories '("." "../../"))
(load "sk.scm")

; Graphviz
; digraph G {

; DFW -> JFK;
; DFW -> LAX;
; DFW -> ORD;
; JFK -> ORD;
; JFK -> PHL;
; JFK -> SEA;
; LAX -> DFW;
; LAX -> ORD;
; LAX -> PHL;
; ORD -> DFW;
; ORD -> JFK;
; PHL -> LAX;
; PHL -> ORD;
; PHL -> SEA;
; SEA -> JFK;
; SEA -> LAX;
; SEA -> PHL;

; }

; airport(0).
; airport(1).
; airport(2).
; airport(3).
; airport(4).
(defineo (airport x)
 (conde
   [(== x 'DFW)]
   [(== x 'JFK)]
   [(== x 'LAX)]
   [(== x 'ORD)]
   [(== x 'PHL)]
   [(== x 'SEA)]
))

; fly('DFW, 'JFK).
; fly('JFK, 'LAX).
; fly('LAX, 'ORD).
(defineo (fly x y)
 (conde
   [(== x 'DFW) (== y 'JFK)]
   [(== x 'DFW) (== y 'LAX)]
   [(== x 'DFW) (== y 'ORD)]
   [(== x 'JFK) (== y 'ORD)]
   [(== x 'JFK) (== y 'PHL)]
   [(== x 'JFK) (== y 'SEA)]
   [(== x 'LAX) (== y 'DFW)]
   [(== x 'LAX) (== y 'ORD)]
   [(== x 'LAX) (== y 'PHL)]
   [(== x 'ORD) (== y 'DFW)]
   [(== x 'ORD) (== y 'JFK)]
   [(== x 'PHL) (== y 'LAX)]
   [(== x 'PHL) (== y 'ORD)]
   [(== x 'PHL) (== y 'SEA)]
   [(== x 'SEA) (== y 'JFK)]
   [(== x 'SEA) (== y 'LAX)]
   [(== x 'SEA) (== y 'PHL)]
))

; reachable(V) :- buy(U, V), reachable(U).
; reachable(V) :- buy('DFW, V).
(defineo (reachable v)
  (conde
    [(buy 'DFW v)]
    [(fresh (u) (airport u) (buy u v) (reachable u))]))

; :- airport(U), not reachable(U).
(constrainto ((airport u) (noto (reachable v))) ((eq? u v)))

; free(U, V) :- airport(U), airport(V), fly(U, V), buy(U, W).
; buy(U, V) :- airport(U), airport(V), fly(U, V), not free(U, V).
(defineo (buy u v)
  (airport u)
  (airport v)
  (fly u v)
  (noto (free u v)))

(defineo (free u v)
  (airport u)
  (airport v)
  (fly u v)
  (noto (buy u v)))

; :- buy(U, V), buy(X, Y), X = U, V != Y.
; :- buy(U, W), buy(V, W), X != U, V = Y.
(constrainto ((buy u v) (buy x y)) ((eq? x u) (not (eq? v y))))
(constrainto ((buy u v) (buy x y)) ((not (eq? x u)) (eq? v y)))

; Example query
;> (run 1 (q) (fresh (a b c d e f)
;                (buy a b) (buy b c) (buy c d)
;                (buy d e) (buy e f) (buy f a)
;                (== q `(,a ,b ,c ,d ,e ,f))))
;
;> (run* (q) (buy 'JFK 'PHL) (buy 'PHL 'SEA) (buy 'SEA 'LAX)
;            (buy 'LAX 'DFW) (buy 'DFW 'ORD) (buy 'ORD 'JFK))
;
;
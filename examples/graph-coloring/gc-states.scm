(source-directories '("." "../../"))
(load "mk.scm")
; Problem instances.
; A graph with vertices and edges G = <V, E>.
(defineo (node x)
 (conde
    [(== x 'AZ)]
    [(== x 'CA)]
    [(== x 'CO)]
    [(== x 'NV)]
    [(== x 'NM)]
    [(== x 'UT)]
))

; edge(1,2).
(defineo (edge x y)
 (conde
    [(== x 'AZ) (== y 'CA)]
    [(== x 'AZ) (== y 'NM)]
    [(== x 'AZ) (== y 'NV)]
    [(== x 'AZ) (== y 'UT)]
    [(== x 'CA) (== y 'NV)]
    [(== x 'CO) (== y 'NM)]
    [(== x 'CO) (== y 'UT)]
    [(== x 'NV) (== y 'UT)]
))

(defineo (neighbors x y)
  (conde
    [(edge x y)]
    [(edge y x)]))

; color(r).
(defineo (color c)
 (conde
  [(== c 'red)]
  [(== c 'green)]
  [(== c 'blue)]))

; Algorithms.
; % Equivelent to the choice rule
; 1{assign(N, C): color(C)}1 :- node(N).
; ======
; assign(N, C) :- node(N), color(C), not free(N, C).
(defineo (assign n c)
  (node n) (color c) (noto (free n c)))

; free(N, C) :- node(N), color(C), not assign(N, C).
(defineo (free n c)
  (node n) (color c) (noto (assign n c)))

; % One node can't take more than one color. (Upper bound)
; :- assign(N, C1), assign(N, C2), C1 != C2.
(constrainto ((assign n1 c1) (assign n2 c2)) ((eq? n1 n2) (not (eq? c1 c2))))

; % One node must take one color. (Lower bound)
; :- not assign(N, r), not assign(N, g), not assign(N, b), node(N).
; (constrainto ((noto (assign n1 c1)) (noto (assign n2 c2)) (noto (assign n3 c3))) ((eq? n1 n2) (eq? n2 n3) (eq? n1 n3)))
; Top-down may not need this rule, if we have sufficient number of "assign" 
; in the query.
; The equivalent rules are:
; assigned(N) :- node(N), color(C), assign(N, C).
; :- node(N), not assigned(N).
(defineo (assigned n)
  (fresh (c) (node n) (color c) (assign n c)))
(constrainto ((node n) (noto (assigned m))) ((eq? n m)))
; ======

; % Graph coloring constraint.
; :- edge(N, M), assign(N, C), assign(M, C).
(constrainto ((neighbors x y) (assign n1 c1) (assign n2 c2)) ((eq? x n1) (eq? y n2) (eq? c1 c2)))

; Solver specified rules (Not stable model semantics)
; % Top-down solver rules, this is an engineering hack, not stable model
; semantics. Other bottom-up solver won't produce the right answer.
; % Solving heuristic, node ordering.
; :- assign(N1, C1), assign(N2, C2), N1 > N2.
(constrainto ((assign n1 c1) (assign n2 c2)) ((> (symbol-hash n1) (symbol-hash n2))))

; % Remove duplicated answers in top-down query.
; :- assign(N1, C1), assign(N2, C2), N1 = N2, C1 = C2.
(constrainto ((assign n1 c1) (assign n2 c2)) ((eq? n1 n2) (eq? c1 c2)))

(source-directories '("." "../../"))
(load "sk.scm")
; Problem instances.
; A graph with vertices and edges G = <V, E>.
; Small graph 3 nodes, big graph 6 nodes.

; node(1..6).
(defineo (node x)
 (conde
    [(== x 1)]
    [(== x 2)]
    [(== x 3)]
    ; [(== x 4)]
    ; [(== x 5)]
    ; [(== x 6)]
))

; edge(1,2).
(defineo (edge x y)
 (conde
    [(== x 1) (== y 2)]
    [(== x 1) (== y 3)]
    [(== x 2) (== y 3)]
    ; [(== x 2) (== y 4)]
    ; [(== x 3) (== y 4)]
    ; [(== x 3) (== y 5)]
    ; [(== x 3) (== y 6)]
    ; [(== x 4) (== y 5)]
    ; [(== x 5) (== y 6)]
))

(defineo (neighbors x y)
  (conde
    [(edge x y)]
    [(edge y x)]))

; color(r).
(defineo (color c)
 (conde
  [(== c 'r)]
  [(== c 'g)]
  [(== c 'b)]))

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
(constrainto ((assign n1 c1) (assign n2 c2)) ((= n1 n2) (not (eq? c1 c2))))

; % One node must take one color. (Lower bound)
; :- not assign(N, r), not assign(N, g), not assign(N, b), node(N).
; (constrainto ((noto (assign n1 c1)) (noto (assign n2 c2)) (noto (assign n3 c3))) ((= n1 n2 n3)))
; Top-down may not need this rule, if we have sufficient number of "assign" 
; in the query.
; The equivalent rules are:
; assigned(N) :- node(N), color(C), assign(N, C).
; :- node(N), not assigned(N).
(defineo (assigned n)
  (fresh (c) (node n) (color c) (assign n c)))
(constrainto ((node n) (noto (assigned m))) ((= n m)))
; ======

; % Graph coloring constraint.
; :- edge(N, M), assign(N, C), assign(M, C).
(constrainto ((neighbors x y) (assign n1 c1) (assign n2 c2)) ((= x n1) (= y n2) (eq? c1 c2)))

; Solver specified rules (Not stable model semantics)
; % Top-down solver rules, this is an engineering hack, not stable model
; semantics. Other bottom-up solver won't produce the right answer.
; % Solving heuristic, node ordering.
; :- assign(N1, C1), assign(N2, C2), N1 > N2.
; (constrainto ((assign n1 c1) (assign n2 c2)) ((> n1 n2)))

; % Remove duplicated answers in top-down query.
; :- assign(N1, C1), assign(N2, C2), N1 = N2, C1 = C2.
; (constrainto ((assign n1 c1) (assign n2 c2)) ((= n1 n2) (eq? c1 c2)))
; So they combined as one rule.
; (constrainto ((assign n1 c1) (assign n2 c2)) ((= n1 n2)))

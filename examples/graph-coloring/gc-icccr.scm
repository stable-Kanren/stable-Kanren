(source-directories '("." "../../"))
(load "sk.scm")
(load "skdefs.scm")

; % Problem instances.
; % A graph with vertices and edges G = <V, E>.
; Small graph 3 nodes, big graph 6 nodes.
; node(1).
; node(2).
; node(3).
(defineo (node x)
  (conde
    [(== x 1)]
    [(== x 2)]
    [(== x 3)]
    ; [(== x 4)]
    ; [(== x 5)]
    ; [(== x 6)]
))

; edge(1, 2).
; edge(2, 3).
; edge(3, 1).
(defineo (edge x y)
  (conde
    [(== x 1) (== y 2)]
    [(== x 1) (== y 3)]
    [(== x 2) (== y 3)]
    ; [(== x 2) (== y 4)]
    ; [(== x 3) (== y 4)]
    ; ; [(== x 3) (== y 5)]
    ; [(== x 3) (== y 6)]
    ; [(== x 4) (== y 5)]
    ; [(== x 5) (== y 6)]
))

(defineo (neighbors x y)
  (conde
    [(edge x y)]
    [(edge y x)]))

; % Color options.
; color(r).
; color(g).
; color(b).
(defineo (color c)
  (conde
    [(== c 'r)]
    [(== c 'g)]
    [(== c 'b)]))

; % Algorithms.
; % Pick a color one at a time and test against all previous colorings.
(defineo (colorize in out)
  (conde
    [(sufficient in) (== in out)]
    [(fresh (n c tmp)
        (node n)
        (color c)
        (safe c n)
        (== `((,n ,c) . ,in) tmp)
        (colorize tmp out))]))

; % iterate in, call `(safe c n)` to build up constraints.
(defineo (populate in)
  (conde 
    [(nullo in)]
    [(noto (nullo in))
     (fresh (t n c)
       (== `((,n ,c) . ,t) in)
       (safe c n)
       (populate t))]))

; % Relational wrapper.
(defineo (gc in out)
  (populate in)
  (colorize `() out))

(defineo (gc in out)
  (colorize `() out)
  (populate in))

; % Check if the two neighbors get the same color for all previous colorings.
(defineo (safe c n)
  succeed)

(defineo (sufficient ans)
  succeed)

(constrainto [(safe c1 n1) (safe c2 n2)] [(violate c1 n1 c2 n2)])

(constrainto [(node n1) (node n2)] [(or (eq? n1 n2) (< n1 n2))])

(constrainto [(sufficient ans)] [(bad ans)])

(define (violate c1 n1 c2 n2)
  (and (not (null? (run 1 (q) (neighbors n1 n2)))) (eq? c1 c2)))

(define (bad ans)
  (not (= (length (run* (q) (node q))) (length ans))))

(source-directories '("." "../../"))
(load "mk.scm")

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
    ; [(== x 3) (== y 5)]
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
(defineo (colorize n in out)
  (conde
    [(== n 0) (== in out)]
    [(fresh (n1 c tmp)
        (gt n 0)
        (color c)
        (noto (violate c n in))
        (sub n 1 n1)
        (== `((,n ,c) . ,in) tmp)
        (colorize n1 tmp out))]))

; % Check if the two neighbors get the same color for all previous colorings.
(defineo (violate c n ans)
  (conde
    [(fresh (h t)
        (== `(,h . ,t) ans)
        (violate c n t))]
    [(fresh (n1 c1 t)
        (== `((,n1 ,c1) . ,t) ans)
        (neighbors n n1)
        (== c c1))]))

(define (gt lhs rhs)
  (lambdag@ (n f c : S P L)
    (let ((lhs-num (walk lhs S))
          (rhs-num (walk rhs S)))
        (if (or (not (number? lhs-num)) (not (number? rhs-num)))
            (fail n f c)
            (if (> lhs-num rhs-num)
                (succeed n f c)
                (fail n f c))))))

(define (sub minuend subtrahend res)
  (lambdag@ (n f c : S P L)
    (let ((minuend-num (walk* minuend S))
          (subtrahend-num (walk* subtrahend S)))
        (if (or (not (number? minuend-num)) (not (number? subtrahend-num)))
            (fail n f c)
        ((== res (- minuend-num subtrahend-num)) n f c)))))

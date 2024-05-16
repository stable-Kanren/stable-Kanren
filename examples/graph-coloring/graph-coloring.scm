(defineo (node x)
  (conde
    [(== x 1)]
    [(== x 2)]
    [(== x 3)]))

(defineo (edge x y)
  (conde
    [(== x 1) (== y 2)]
    [(== x 2) (== y 3)]
    [(== x 3) (== y 1)]))

(defineo (neighbors x y)
  (conde
    [(edge x y)]
    [(edge y x)]))

(defineo (color c)
  (conde
    [(== c 'r)]
    [(== c 'g)]
    [(== c 'b)]))

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
(load "send-sc.scm")

; Given partial answers through verifiers.
(define (oracle l v)
  (or
  (and (eq? l 's) (= v 9))
  ;(and (eq? l 'e) (= v 5))
  ;(and (eq? l 'n) (= v 6))
  ;(and (eq? l 'd) (= v 7))
  (and (eq? l 'm) (= v 1))
  (and (eq? l 'o) (= v 0))
  ;(and (eq? l 'r) (= v 8))
  ;(and (eq? l 'y) (= v 2))
  (or (eq? l 'e) (eq? l 'n) (eq? l 'd) (eq? l 'r) (eq? l 'y))
  )
)

(constrainto [(assign l v)] [(not (oracle l v))])

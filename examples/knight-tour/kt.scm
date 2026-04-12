(source-directories '("." "../../"))
(load "sk.scm")

(defineo (steps s)
  (conde
    [(== s  1)]
    [(== s  2)]
    [(== s  3)]
    [(== s  4)]
    [(== s  5)]
    [(== s  6)]
    [(== s  7)]
    [(== s  8)]
    [(== s  9)]
    [(== s 10)]
    [(== s 11)]
    [(== s 12)]
    [(== s 13)]
    [(== s 14)]
    [(== s 15)]
    [(== s 16)]
    [(== s 17)]
    [(== s 18)]
    [(== s 19)]
    [(== s 20)]
    [(== s 21)]
    [(== s 22)]
    [(== s 23)]
    [(== s 24)]
    [(== s 25)]
    ; [(== s 26)]
    ; [(== s 27)]
    ; [(== s 28)]
    ; [(== s 29)]
    ; [(== s 30)]
    ; [(== s 31)]
    ; [(== s 32)]
    ; [(== s 33)]
    ; [(== s 34)]
    ; [(== s 35)]
    ; [(== s 36)]
))

(defineo (nums n)
  (conde
    [(== n 1)]
    [(== n 2)]
    [(== n 3)]
    [(== n 4)]
    [(== n 5)]
    ;[(== n 6)]
))

(defineo (pick s x y)
  (nums x) (nums y) (steps s) (noto (free s x y)))

(defineo (free s x y)
  (nums x) (nums y) (steps s) (noto (pick s x y)))

; Each step only pick one (x, y).
(constrainto [(pick s1 x1 y1) (pick s2 x2 y2)] [(= s1 s2) (not (= x1 x2)) (not (= y1 y2))])

; The same (x, y) cannot be visited more than once.
(constrainto [(pick s1 x1 y1) (pick s2 x2 y2)] [(= x1 x2) (= y1 y2) (not (= s1 s2))])

; Each step must pick one (x, y).
(defineo (assigned s)
  (fresh (x y) (pick s x y)))
(constrainto [(steps s1) (noto (assigned s2))] [(= s1 s2)])

; Knight tour constraint: next step not in the 8 directions of the previous step.
(constrainto [(pick s1 x1 y1) (pick s2 x2 y2)] [(= s2 (+ s1 1)) (not (directions x1 x2 y1 y2))])

(define (directions x1 x2 y1 y2)
  (or 
    (and (= x2 (+ x1 2)) (= y2 (+ y1 1)))
    (and (= x2 (+ x1 1)) (= y2 (+ y1 2)))
    (and (= x2 (- x1 1)) (= y2 (+ y1 2)))
    (and (= x2 (- x1 2)) (= y2 (+ y1 1)))
    (and (= x2 (- x1 2)) (= y2 (- y1 1)))
    (and (= x2 (- x1 1)) (= y2 (- y1 2)))
    (and (= x2 (+ x1 1)) (= y2 (- y1 2)))
    (and (= x2 (+ x1 2)) (= y2 (- y1 1)))
 ))

(source-directories '("." "../../"))
(load "sk.scm")
(load "skdefs.scm")

(defineo (nums x)
  (conde
    [(== x 1)]
    [(== x 2)]
    [(== x 3)]
    [(== x 4)]
    [(== x 5)]
    [(== x 6)]
    [(== x 7)]
    ; [(== x 8)]
))

(defineo (x-nums x)
  (nums x))

(defineo (y-nums x)
  (nums x))

; nqueens(Qi, Qo).
(defineo (nqueens qi qo)
    (conde
        [(sufficient qi)
         (== qi qo)]
        [(fresh (x y qn)
            (x-nums x)
            (y-nums y)
            (safe x y)
            (== `((,x ,y) . ,qi) qn)
            (nqueens qn qo))]))

; % Iterate `in`, call `(safe c n)` to build up constraints.
(defineo (populate in)
  (conde 
    [(nullo in)]
    [(noto (nullo in))
     (fresh (t x y)
       (== `((,x ,y) . ,t) in)
       (safe x y)
       (populate t))]))

; % Relational wrapper.
(defineo (nq in out)
  (populate in)
  (nqueens `() out))

(defineo (nq in out)
  (nqueens `() out)
  (populate in))

(defineo (safe x y)
  succeed)

(constrainto [(safe x y) (safe x1 y1)] [(invalid x y x1 y1)])

;% check if a queen can attack any previously selected queen
; attack(X, _, [q(X, _) | _]). % same row
; attack(_, Y, [q(_, Y) | _]). % same col
; attack(X, Y, [q(X2, Y2) | _]) :- % same diagonal
;    Xd is X2 - X, abs(Xd, Xd2),
;    Yd is Y2 - Y, abs(Yd, Yd2),
;    Xd2 = Yd2.

; attack(X, Y, [_ | T]) :-
;    attack(X, Y, T).
(define (invalid x y x1 y1)
  (or (= x x1) (= y y1) (= (abs (- x x1)) (abs (- y y1)))))

(constrainto [(x-nums n1) (x-nums n2)] [(or (eq? n1 n2) (< n1 n2))])

(defineo (sufficient ans)
  succeed)

(constrainto [(sufficient ans)] [(bad ans)])

(define (bad ans)
  (not (= (length (run* (q) (nums q))) (length ans))))

; Finding one answer.
; > (run 1 (q) (nqueens `() q))
; Given partial answer.
; > (run* (q) (nq `((3 2) (4 7)) q))
; (((1 6) (2 4) (3 2) (4 7) (5 5) (6 3) (7 1)))
; Given wrong answer.
; > (run* (q) (nq `((3 2) (4 3)) q))
; ()
; Finding all answers.
; > (run* (q) (nqueens `() q))
; Get the total number of answers.
; > (length (run* (q) (nqueens `() q)))
; Time measurement.
; > (time (length (run* (q) (nqueens `() q))))

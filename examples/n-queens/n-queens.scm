(source-directories '("." "../../"))
(load "sk.scm")
(load "skdefs.scm")
; Example taken from s(ASP) paper
; (https://www.cs.nmsu.edu/ALP/wp-content/uploads/2017/04/marple_etal2017.pdf)
;% solve the N queens problem for a given N, returning a list of queens as Q
; nqueens(N, Q) :- 
;    nqueens(N, N, [], Q).

;% pick queens one at a time and test against all previous queens
; nqueens(X, N, Qi, Qo) :-
;    X > 0,
;    pickqueen(X, Y, N),
;    not attack(X, Y, Qi),
;    X1 is X - 1,
;    nqueens(X1, N, [q(X, Y) | Qi], Qo).

; nqueens(0, _, Q, Q).
(defineo (nqueens n q)
    (queens n n `() q))

(defineo (queens x n qi qo)
    (conde
        [(== x 0)
         (== qi qo)]
        [(fresh (x1 y qn)
            (gt x 0)
            (pickqueen x y n)
            (noto (attack x y qi))
            (sub x 1 x1)
            (== `((,x ,y) . ,qi) qn)
            (queens x1 n qn qo))]))

;% pick a queen for row X.
; pickqueen(X, Y, Y) :-
;    Y > 0, q(X, Y).

; pickqueen(X, Y, N) :-
;    N > 1,
;    N1 is N - 1,
;    pickqueen(X, Y, N1).

(defineo (pickqueen x y n)
    (conde
        [(gt n 0)
         (== y n)]
        [(fresh (n1)
            (gt n 1)
            (sub n 1 n1)
            (pickqueen x y n1))]))

;% check if a queen can attack any previously selected queen
; attack(X, _, [q(X, _) | _]). % same row
; attack(_, Y, [q(_, Y) | _]). % same col
; attack(X, Y, [q(X2, Y2) | _]) :- % same diagonal
;    Xd is X2 - X, abs(Xd, Xd2),
;    Yd is Y2 - Y, abs(Yd, Yd2),
;    Xd2 = Yd2.

; attack(X, Y, [_ | T]) :-
;    attack(X, Y, T).
(defineo (attack x y qs)
    (conde
        [(fresh (h t)
            (== `(,h . ,t) qs)
            (attack x y t))]
        [(fresh (x1 y1 t)
            (== `((,x1 ,y1) . ,t) qs)
            (== x1 x))]
        [(fresh (x1 y1 t)
            (== `((,x1 ,y1) . ,t) qs)
            (== y1 y))]
        [(fresh (x1 y1 t)
            (== `((,x1 ,y1) . ,t) qs)
            (diagonal x y x1 y1))]))

; q(X, Y) :- not negq(X, Y).
; negq(X, Y) :- not q(X, Y).

; We've noticed this loop rules and the q(X, Y) in pickqueen(X, Y, Y) doesn't
; contribute to the solving process at all. Removing these rules the program
; still can produce the correct answer. So the q(X, Y) works as a functional term.

; abs(X, X) :- X >= 0.
; abs(X, Y) :- X < 0, Y is X * -1.

; Finding one answer.
; > (run 1 (q) (nqueens 8 q))
; Finding all answers.
; > (run* (q) (nqueens 8 q))
; Get the total number of answers.
; > (length (run* (q) (nqueens 8 q)))
; Time measurement.
; > (time (length (run* (q) (nqueens 8 q))))

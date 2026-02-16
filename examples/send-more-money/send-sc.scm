(load "send.scm")

; Break into smaller constraints.
; :- assign(d, D), assign(e, E), assign(y, Y), (D + E) \ 10 != Y.
(constrainto [(assign 'd d) (assign 'e ev) (assign 'y yv)]
             [(not (= yv (mod (+ d ev) 10)))])

; (D + E) / 10 is the first carry bit, C1.
; :- assign(d, D), assign(e, E), assign(n, N), assign(r, R), ((D + E) / 10 + N + R) \ 10 != E.
(constrainto [(assign 'd dv) (assign 'e ev) (assign 'n nv) (assign 'r rv)]
             [(not (= ev (mod (+ nv rv (floor (/ (+ dv ev) 10))) 10)))])

; (N + R + C1) / 10 is the second carry bit, C2.
; :- assign(d, D), assign(n, N), assign(r, R), assign(e, E), assign(o, O), (((D + E) / 10 + N + R) / 10 + E + O) \ 10 != N.
(constrainto [(assign 'd dv) (assign 'n nv) (assign 'r rv) (assign 'e ev) (assign 'o ov)]
             [(not (= nv (mod (+ ov ev (floor (/ (+ nv rv (floor (/ (+ dv ev) 10)) ) 10))) 10)))])

; (E + O + C2) / 10 is the third carry bit, C3.
; assign(d, D), assign(n, N), assign(r, R), assign(e, E), assign(o, O), assign(s, S), assign(m, M), ((((D + E) / 10 + N + R) / 10 + E + O) / 10 + S + M) \ 10 != O.
(constrainto [(assign 'n nv) (assign 'd dv) (assign 'r rv) (assign 'e ev) (assign 'o ov) (assign 's sv) (assign 'm mv)]
             [(not (= ov (mod (+ mv sv (floor (/ (+ ev ov (floor (/ (+ nv rv (floor (/ (+ dv ev) 10)) ) 10)) ) 10))) 10)))])

; (S + M + C3) / 10 is the fourth carry bit, C4.
; :- assign(d, D), assign(n, N), assign(r, R), assign(e, E), assign(o, O), assign(s, S), assign(m, M), ((((D + E) / 10 + N + R) / 10 + E + O) / 10 + S + M) / 10 != M.
(constrainto [(assign 'n nv) (assign 'd dv) (assign 'r rv) (assign 'e ev) (assign 'o ov) (assign 's sv) (assign 'm mv)]
             [(not (= mv (floor (/ (+ sv mv (floor (/ (+ ev ov (floor (/ (+ nv rv (floor (/ (+ dv ev) 10)) ) 10)) ) 10))) 10))))])

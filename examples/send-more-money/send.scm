(source-directories '("." "../../"))
(load "sk.scm")
; letter(s;e;n;d;m;o;r;y).
(defineo (letter l)
  (conde
    [(== l 's)]
    [(== l 'e)]
    [(== l 'n)]
    [(== l 'd)]
    [(== l 'm)]
    [(== l 'o)]
    [(== l 'r)]
    [(== l 'y)]
    ))

; values(0..9).
(defineo (values v)
  (conde
    [(== v 0)]
    [(== v 1)]
    [(== v 2)]
    [(== v 3)]
    [(== v 4)]
    [(== v 5)]
    [(== v 6)]
    [(== v 7)]
    [(== v 8)]
    [(== v 9)]
    ))

; % exact 1 occurrence of each letter
; % 1 { assign(L,Val) : values(Val) } 1 :- letter(L).
; assign(L, V) :- letter(L), values(V), not n_assign(L, V).
; n_assign(L, V) :- letter(L), values(V), not assign(L, V).
(defineo (assign l v)
  (letter l) (values v) (noto (n_assign l v)))
(defineo (n_assign l v)
  (letter l) (values v) (noto (assign l v)))

; :- assign(L, V1), assign(L, V2), V1 != V2.
(constrainto [(assign l1 v1) (assign l2 v2)] [(eq? l1 l2) (not (= v1 v2))])
; :- assign(L1, V), assign(L2, V), L1 != L2.
(constrainto [(assign l1 v1) (assign l2 v2)] [(not (eq? l1 l2)) (= v1 v2)])

; assigned(L) :- letter(L), values(V), assign(L, V).
(defineo (assigned l)
  (fresh (v) (letter l) (values v) (assign l v)))

; :- letter(L), not assigned(L).
(constrainto [(letter l1) (noto (assigned l2))] [(eq? l1 l2)])

;     S E N D
; +   M O R E
;-------------
; = M O N E Y
; :- assign(s, S), assign(e, E), assign(n, N), assign(d, D), assign(m, M), assign(o, O), assign(r, R), assign(y, Y), S*1000+E*100+N*10+D + M*1000+O*100+R*10+E != M*10000+O*1000+N*100+E*10+Y.
(constrainto [(assign 's sv) (assign 'e ev) (assign 'n nv) (assign 'd dv) (assign 'm mv) (assign 'o ov) (assign 'r rv) (assign 'y yv)]
           [(not (= (+ (* sv 1000) (* ev 100) (* nv 10) (* dv 1)
                       (* mv 1000) (* ov 100) (* rv 10) (* ev 1))
       (+ (* mv 10000) (* ov 1000) (* nv 100) (* ev 10) (* yv 1))))])

; :- assign(s, 0).
(constrainto [(assign 's sv)] [(= sv 0)])
; :- assign(m, 0).
(constrainto [(assign 'm mv)] [(= mv 0)])

(load "mktests.scm")

(defineo (conso a d p)
  (== (cons a d) p))

; User prefer to write a simple form.
(defineo (membero x xs)
  (fresh (h t)
    (conso h t xs)
    (conde
      [(== h x)]
      [(noto (== h x)) (membero x t)])))

; [ToDo] Add a normalization macro to conver the above program's body to the DNF.
; membero(X, [H|T]) :- X = H.
; membero(X, [H|T]) :- not X = H, membero(X, T).
(defineo (membero x xs)
  (conde
    [(fresh (h t)
      (conso h t xs)
      (== h x))]
    [(fresh (h t)
      (conso h t xs)
      (noto (== h x))
      (membero x t))]))

(test-check "membero.tex-1"
(sort compare-element (remove-duplicates 
  (run 10 (q) (fresh (lst elem) 
                (== lst `(1 2 3))
                (== q `(,elem ,lst))
                (membero elem lst)))))

`((1 (1 2 3))
  (2 (1 2 3))
  (3 (1 2 3))))

(test-check "membero.tex-2"
(sort compare-element (remove-duplicates 
  (run 10 (q) (fresh (lst elem a b c)
                (== lst `(,a ,b ,c))
                (membero elem lst)
                (== q `(,elem ,lst))))))

`((_.0 (_.0 _.1 _.2))
  (_.0 (_.1 _.0 _.2))
  (_.0 (_.1 _.2 _.0))))

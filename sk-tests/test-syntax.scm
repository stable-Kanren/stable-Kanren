(source-directories '("." "./sk-tests/" "../"))
(load "testdefs.scm")
(load "sk.scm")

;;; ==== Testing has-negation? ====
;;; One predicate
(test-check "sktests.tex-has-negation?-0t"
(has-negation? (noto (p x)))

#t)

(test-check "sktests.tex-has-negation?-0f"
(has-negation? (p x))

#f)

(test-check "sktests.tex-has-negation?-1t"
(has-negation? (noto fail))

#t)

(test-check "sktests.tex-has-negation?-1f"
(has-negation? succeed)

#f)

;;; More than one predicate
(test-check "sktests.tex-has-negation?-2t"
(has-negation? (q x) (noto fail))

#t)


(test-check "sktests.tex-has-negation?-2f"
(has-negation? (q x) fail)

#f)

(test-check "sktests.tex-has-negation?-3"
(has-negation? (q x) (noto succeed) fail)

#t)

;;; Combine with conde/fresh
(test-check "sktests.tex-has-negation?-4t"
(has-negation? (fresh (x y) (q x) (noto succeed) fail))

#t)

(test-check "sktests.tex-has-negation?-4f"
(has-negation? (fresh (x y) (q x) succeed fail))

#f)

(test-check "sktests.tex-has-negation?-5t"
(has-negation? (conde [(q x) (noto succeed)] [fail]))

#t)

(test-check "sktests.tex-has-negation?-5f"
(has-negation? (conde [(q x) succeed] [fail]))

#f)

(test-check "sktests.tex-has-negation?-6t"
(has-negation? (fresh (x y) (conde [(q x) (noto succeed)] [fail])))

#t)

(test-check "sktests.tex-has-negation?-6f"
(has-negation? (fresh (x y) (conde [(q x) succeed] [fail])))

#f)

(test-check "sktests.tex-has-negation?-7t"
(has-negation? (conde [(fresh (x) (q x) (noto succeed))] [fail]))

#t)

(test-check "sktests.tex-has-negation?-7f"
(has-negation? (conde [(fresh (x) (q x) succeed)] [fail]))

#f)

;;; ==== Testing ignore-negation ====
(test-check "sktests.tex-ignore-negation-1"
(run* (q) 
  (ignore-negation
    (conde [(fresh (x) (== q 1) (noto succeed) (== x 2))])))

`(1))

(test-check "sktests.tex-ignore-negation-2"
(run* (q)
  (ignore-negation
    (conde [(fresh (x) (== q 1) (noto succeed) (== x 2))]
           [(== q 2) succeed])))

`(2 1))

(test-check "sktests.tex-ignore-negation-3"
(run* (q)
  (ignore-negation
    (conde [(fresh (x) (== q 1) (noto succeed) (== x 2))]
           [(== q 3) succeed])))

`(3 1))

(test-check "sktests.tex-ignore-negation-4"
(run* (q)
  (ignore-negation
    (conde [(fresh (x) (== q 1) (noto succeed) (== x 2))]
           [(noto (== q 3)) succeed])))

`(_.0 1))

(test-check "sktests.tex-ignore-negation-5"
(run* (q)
  (ignore-negation
    (conde [(fresh (x) (== q 1) (noto succeed) (== x 2))]
           [(noto (== q 3)) (== q 4)])))

`(4 1))


;;; ==== Testing positive and negative twins (body) ====
(test-check "sktests.tex-positive-twin-eval-unification"
(run* (q) (positive-twin (== 1 0)))

`(_.0))

(test-check "sktests.tex-positive-twin-expand-unification"
(expand `(positive-twin (== 1 0)))

'succeed)

(test-check "sktests.tex-positive-twin-eval-succeed"
(run* (q) (positive-twin succeed))

`(_.0))

(test-check "sktests.tex-positive-twin-expand-succeed"
(expand `(positive-twin succeed))

'succeed)

(test-check "sktests.tex-positive-twin-eval-fail"
(run* (q) (positive-twin fail))

`())

(test-check "sktests.tex-positive-twin-expand-fail"
(expand `(positive-twin fail))

'fail)

;;; ==== Mock a p+ returns false ====
(define (p+) fail)

(test-check "sktests.tex-positive-twin-eval-goal"
;;; It drops the parameter in (p 1 2), so we get (p), and it appends a "+" to p. 
(run* (q) (positive-twin (p 1 2)))

`())

(test-check "sktests.tex-positive-twin-expand-goal"
(syntax->datum ((top-level-syntax 'positive-twin) #'(positive-twin (p 1 2))))

`(eval `(,(sym-append-str (car `(p 1 2)) "+"))))

(test-check "sktests.tex-positive-twin-eval-expand-goal" 
(run* (q)
      (eval 
        `,(syntax->datum ((top-level-syntax 'positive-twin) #'(positive-twin (p x y))))
))

`())

(test-check "sktests.tex-positive-twin-eval-negation-goal"
;;; It drops the parameter in (p 1 2), so we get (p), and it appends a "+" to p. 
(run* (q) (positive-twin (noto (p 1 2))))

`(_.0))

(test-check "sktests.tex-positive-twin-expand-negation-goal"
(syntax->datum ((top-level-syntax 'positive-twin) #'(positive-twin (noto (p 1 2)))))

`(noto (positive-twin (p 1 2))))

;;; ==== Integration testing (goals + negations + true/false) ====
;;; ==== Mock a q+ r+ returns true ====
(define (q+) succeed)
(define (r+) succeed)

(test-check "sktests.tex-positive-twin-eval-goals-1"
(run* (q) (positive-twin (q 1 2) (r x y)))

`(_.0))

(test-check "sktests.tex-positive-twin-expand-goals-1"
(syntax->datum ((top-level-syntax 'positive-twin) #'(positive-twin (q 1 2) (r x y))))

`(fresh () (positive-twin (q 1 2)) (positive-twin (r x y))))

(test-check "sktests.tex-positive-twin-eval-goals-2"
(run* (q) (positive-twin (q 1 2) succeed))

`(_.0))

(test-check "sktests.tex-positive-twin-expand-goals-2"
(syntax->datum ((top-level-syntax 'positive-twin) #'(positive-twin (q 1 2) fail)))

`(fresh () (positive-twin (q 1 2)) (positive-twin fail)))

(test-check "sktests.tex-positive-twin-eval-goals-3"
(run* (q) (positive-twin (q 1 2) (noto fail)))

`(_.0))

(test-check "sktests.tex-positive-twin-expand-goals-3"
(syntax->datum ((top-level-syntax 'positive-twin) #'(positive-twin (q 1 2) (noto (p x y)))))

`(fresh () (positive-twin (q 1 2)) (positive-twin (noto (p x y)))))


;;; ==== Complex formula (conde/fresh) ====
;;; Special case, all unifications merge into one succeed.
(test-check "sktests.tex-positive-twin-eval-conde-1"
(run* (q) (positive-twin (conde [(== x 1)] [(== x 2)])))

`(_.0))

(test-check "sktests.tex-positive-twin-expand-conde-1"
(syntax->datum ((top-level-syntax 'positive-twin) #'(positive-twin (conde [(== 
  x 1)] [(== x 2)]))))

'succeed)

;;; Two succeeds from different conde clauses didnot merge into one.
(test-check "sktests.tex-positive-twin-eval-conde-2"
(run* (q) (positive-twin (conde [(== x 1)] [succeed])))

`(_.0 _.0))

(test-check "sktests.tex-positive-twin-expand-conde-2"
(syntax->datum ((top-level-syntax 'positive-twin) #'(positive-twin (conde [(==
  x 1)] [succeed]))))

'(conde ((positive-twin (== x 1))) ((positive-twin succeed))))

(test-check "sktests.tex-positive-twin-eval-conde-3"
(run* (q) (positive-twin (conde [(q x 1)] [(r y 2) succeed])))

`(_.0 _.0))

(test-check "sktests.tex-positive-twin-expand-conde-3"
(syntax->datum ((top-level-syntax 'positive-twin) #'(positive-twin (conde [(q 
  x 1)] [(r y 2) succeed]))))

'(conde
  ((positive-twin (q x 1)))
  ((positive-twin (r y 2)) (positive-twin succeed))))


(test-check "sktests.tex-positive-twin-eval-fresh-1"
(run* (q) (positive-twin (fresh (x y) (== x 1) (== y 2))))

`(_.0))

;;; Remove intermediate variables (x y) in fresh.
(test-check "sktests.tex-positive-twin-expand-fresh-1"
(syntax->datum ((top-level-syntax 'positive-twin) #'(positive-twin (fresh (x y)
  (== x 1) (== y 2)))))

'(fresh () (positive-twin (== x 1)) (positive-twin (== y 2))))

(test-check "sktests.tex-positive-twin-eval-fresh-2"
(run* (q) (positive-twin (fresh (x y) (q x) (r y))))

`(_.0))

;;; Remove intermediate variables (x y) in fresh.
(test-check "sktests.tex-positive-twin-expand-fresh-2"
(syntax->datum ((top-level-syntax 'positive-twin) #'(positive-twin (fresh (x y)
  (q x) (r y)))))

'(fresh () (positive-twin (q x)) (positive-twin (r y))))

;;; ==== Negative twin is almost the same as the positive twin ====
(test-check "sktests.tex-negative-twin-eval-unification"
(run* (q) (negative-twin (== 1 0)))

`(_.0))

(test-check "sktests.tex-negative-twin-expand-unification"
(expand `(negative-twin (== 1 0)))

'succeed)

(test-check "sktests.tex-negative-twin-eval-succeed"
(run* (q) (negative-twin succeed))

`(_.0))

(test-check "sktests.tex-negative-twin-expand-succeed"
(expand `(negative-twin succeed))

'succeed)

(test-check "sktests.tex-negative-twin-eval-fail"
(run* (q) (negative-twin fail))

`())

(test-check "sktests.tex-negative-twin-expand-fail"
(expand `(negative-twin fail))

'fail)

;;; ==== Mock a p- returns false ====
(define (p-) fail)

(test-check "sktests.tex-negative-twin-eval-goal"
;;; It drops the parameter in (p 1 2), so we get (p), and it appends a "-" to p. 
(run* (q) (negative-twin (p 1 2)))

`())

(test-check "sktests.tex-negative-twin-expand-goal"
(syntax->datum ((top-level-syntax 'negative-twin) #'(negative-twin (p 1 2))))

`(eval `(,(sym-append-str (car `(p 1 2)) "-"))))

(test-check "sktests.tex-negative-twin-eval-expand-goal" 
(run* (q)
      (eval 
        `,(syntax->datum ((top-level-syntax 'negative-twin) #'(negative-twin (p x y))))
))

`())

(test-check "sktests.tex-negative-twin-eval-negation-goal"
;;; It drops the parameter in (p 1 2), so we get (p), and it appends a "-" to p. 
(run* (q) (negative-twin (noto (p 1 2))))

`(_.0))

(test-check "sktests.tex-negative-twin-expand-negation-goal"
(syntax->datum ((top-level-syntax 'negative-twin) #'(negative-twin (noto (p 1 2)))))

`(noto (negative-twin (p 1 2))))

;;; ==== Integration testing (goals + negations + true/false) ====
;;; ==== Mock a q- r- returns true ====
(define (q-) succeed)
(define (r-) succeed)

(test-check "sktests.tex-negative-twin-eval-goals-1"
(run* (q) (negative-twin (q 1 2) (r x y)))

`(_.0))

(test-check "sktests.tex-negative-twin-expand-goals-1"
(syntax->datum ((top-level-syntax 'negative-twin) #'(negative-twin (q 1 2) (r x y))))

`(fresh () (negative-twin (q 1 2)) (negative-twin (r x y))))

(test-check "sktests.tex-negative-twin-eval-goals-2"
(run* (q) (negative-twin (q 1 2) succeed))

`(_.0))

(test-check "sktests.tex-negative-twin-expand-goals-2"
(syntax->datum ((top-level-syntax 'negative-twin) #'(negative-twin (q 1 2) fail)))

`(fresh () (negative-twin (q 1 2)) (negative-twin fail)))

(test-check "sktests.tex-negative-twin-eval-goals-3"
(run* (q) (negative-twin (q 1 2) (noto fail)))

`(_.0))

(test-check "sktests.tex-negative-twin-expand-goals-3"
(syntax->datum ((top-level-syntax 'negative-twin) #'(negative-twin (q 1 2) (noto (p x y)))))

`(fresh () (negative-twin (q 1 2)) (negative-twin (noto (p x y)))))


;;; ==== Complex formula (conde/fresh) ====
;;; Special case, all unifications merge into one succeed.
(test-check "sktests.tex-negative-twin-eval-conde-1"
(run* (q) (negative-twin (conde [(== x 1)] [(== x 2)])))

`(_.0))

(test-check "sktests.tex-negative-twin-expand-conde-1"
(syntax->datum ((top-level-syntax 'negative-twin) #'(negative-twin (conde [(== 
  x 1)] [(== x 2)]))))

'succeed)

;;; Two succeeds from different conde clauses didnot merge into one.
(test-check "sktests.tex-negative-twin-eval-conde-2"
(run* (q) (negative-twin (conde [(== x 1)] [succeed])))

`(_.0 _.0))

(test-check "sktests.tex-negative-twin-expand-conde-2"
(syntax->datum ((top-level-syntax 'negative-twin) #'(negative-twin (conde [(==
  x 1)] [succeed]))))

'(conde ((negative-twin (== x 1))) ((negative-twin succeed))))

(test-check "sktests.tex-negative-twin-eval-conde-3"
(run* (q) (negative-twin (conde [(q x 1)] [(r y 2) succeed])))

`(_.0 _.0))

(test-check "sktests.tex-negative-twin-expand-conde-3"
(syntax->datum ((top-level-syntax 'negative-twin) #'(negative-twin (conde [(q 
  x 1)] [(r y 2) succeed]))))

'(conde
  ((negative-twin (q x 1)))
  ((negative-twin (r y 2)) (negative-twin succeed))))


(test-check "sktests.tex-negative-twin-eval-fresh-1"
(run* (q) (negative-twin (fresh (x y) (== x 1) (== y 2))))

`(_.0))

;;; Remove intermediate variables (x y) in fresh.
(test-check "sktests.tex-negative-twin-expand-fresh-1"
(syntax->datum ((top-level-syntax 'negative-twin) #'(negative-twin (fresh (x y)
  (== x 1) (== y 2)))))

'(fresh () (negative-twin (== x 1)) (negative-twin (== y 2))))

(test-check "sktests.tex-negative-twin-eval-fresh-2"
(run* (q) (negative-twin (fresh (x y) (q x) (r y))))

`(_.0))

;;; Remove intermediate variables (x y) in fresh.
(test-check "sktests.tex-negative-twin-expand-fresh-2"
(syntax->datum ((top-level-syntax 'negative-twin) #'(negative-twin (fresh (x y)
  (q x) (r y)))))

'(fresh () (negative-twin (q x)) (negative-twin (r y))))


;;; ==== Testing positive and negative twins (head) ====
; Define a goal function (propositional and predicate), query p+ and p-.
(reset-program)
(defineo (p)
  succeed)
(test-check "sktests.tex-positive-twin-definition-propositional"
(run 1 (q) (p+))

`(_.0))

(test-check "sktests.tex-negative-twin-definition-propositional"
(run 1 (q) (p-))

`(_.0))

(defineo (r x)
  (conde
    [(== x 1)]
    [(== x 2)]
    ))

(test-check "sktests.tex-positive-twin-definition-predicate"
(run 1 (q) (r+))

`(_.0))

(test-check "sktests.tex-negative-twin-definition-predicate"
(run 1 (q) (r-))

`(_.0))

; Stratified program's twins produce exactly the same results.
;;; Stratified negation, loop and negation does not mixed together.
(reset-program)
; a :- b.
; b :- a.
; c :- not a.
; c :- d.
; d :- c.
; e :- not d.
(defineo (a) (b))
(defineo (b) (a))
(defineo (c) 
  (conde 
    [(noto (a))]
    [(d)]))
(defineo (d) (c))
(defineo (e) (noto (d)))

(test-check "sktests.tex-stratified-twin-propositional-a"   
(= (length (run* (q) (a+)))
   (length (run* (q) (a-))))

#t)

(test-check "sktests.tex-stratified-twin-propositional-b"   
(= (length (run* (q) (b+)))
   (length (run* (q) (b-))))

#t)

(test-check "sktests.tex-stratified-twin-propositional-c"   
(= (length (run* (q) (c+)))
   (length (run* (q) (c-))))

#t)

(test-check "sktests.tex-stratified-twin-propositional-d"   
(= (length (run* (q) (d+)))
   (length (run* (q) (d-))))

#t)

(test-check "sktests.tex-stratified-twin-propositional-e"   
(= (length (run* (q) (e+)))
   (length (run* (q) (e-))))

#t)


;;; Stratified negation, example taken from 
;;; https://www3.cs.stonybrook.edu/~warren/xsbbook/node59.html
;;; For stratified negation, the loop can't has negation in it. We are using the
;;; loop part of the example to test stable-Kanren's ability to handle positive
;;; loop in the program.
(reset-program)
(defineo (reduce x y)
  (conde
    [(== x 'a) (== y 'b)]
    [(== x 'b) (== y 'c)]
    [(== x 'c) (== y 'd)]
    [(== x 'd) (== y 'e)]
    [(== x 'e) (== y 'c)]
    [(== x 'a) (== y 'f)]
    [(== x 'f) (== y 'h)]
    [(== x 'f) (== y 'g)]
    [(== x 'g) (== y 'f)]
    [(== x 'g) (== y 'k)]
    [(== x 'h) (== y 'i)]
    [(== x 'i) (== y 'h)]))

;reachable(X,Y) :- reduce(X,Y).
;reachable(X,Y) :- reachable(X,Z), reduce(Z,Y).
(defineo (reachable x y)
  (conde
    [(reduce x y)]
    [(fresh (z) (reduce x z) (reachable z y))]))

;reducible(X) :- reachable(X,Y), not reachable(Y,X).
(defineo (reducible x)
  (conde
   [(fresh (y) (reachable x y) (noto (reachable y x)))]))

;fullyReduce(X,Y) :- reachable(X,Y), not reducible(Y).
(defineo (fullyReduce x y)
  (conde
    [(reachable x y) (noto (reducible y))]))

(test-check "sktests.tex-stratified-twin-predicate-reduce"   
(= (length (run* (q) (reduce+)))
   (length (run* (q) (reduce-))))

#t)

(test-check "sktests.tex-stratified-twin-predicate-reachable"   
(= (length (run* (q) (reachable+)))
   (length (run* (q) (reachable-))))

#t)

(test-check "sktests.tex-stratified-twin-predicate-reducible"   
(= (length (run* (q) (reducible+)))
   (length (run* (q) (reducible-))))

#t)

(test-check "sktests.tex-stratified-twin-predicate-fullyReduce"   
(= (length (run* (q) (fullyReduce+)))
   (length (run* (q) (fullyReduce-))))

#t)

(test-check "sktests.tex-stratified-twin-predicate"   
(stratified?)

#t)

; Normal program's twins produce different results.
;;; Testing Two Person Game in stableKanren
(reset-program)
(defineo (edge x y)
  (conde
    [(== x 'b) (== y 'c)]
    [(== x 'a) (== y 'b)]
    [(== x 'b) (== y 'a)]
    [(== x 'c) (== y 'd)]))

(defineo (win x)
  (fresh (y)
    (edge x y)
    (noto (win y))))

; No loop and negation, the result is the same.
(test-check "sktests.tex-normal-twin-predicate-edge"   
(= (length (run* (q) (edge+)))
     (length (run* (q) (edge-))))

#t)

; There is a loop over negation, the result is different.
(test-check "sktests.tex-normal-twin-predicate-win"   
(not (= (length (run* (q) (win+)))
     (length (run* (q) (win-)))))

#t)

(test-check "sktests.tex-normal-twin-predicate"   
(stratified?)

#f)


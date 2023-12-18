;;; This file was generated by writeminikanren.pl
;;; Generated at 2007-10-25 15:24:42
(load "utils.scm")

(define-syntax lambdag@
  (syntax-rules ()
    ((_ (n cfs c) e ...) (lambda (n cfs c) e ...))
    ((_ (n cfs c : S P) e ...)
     (lambda (n cfs c)
      (let ([S (c->S c)]
            [P (c->P c)])
        e ...)))))

(define-syntax lambdaf@
  (syntax-rules ()
    ((_ () e) (lambda () e))))

(define-syntax run*
  (syntax-rules ()
    ((_ (x) g ...) (run #f (x) g ...))))

(define rhs (lambda (pr) (cdr pr)))

(define lhs (lambda (pr) (car pr)))

(define var (lambda (x) (vector x)))

(define var? (lambda (x) (vector? x)))

(define c->S (lambda (c) (car c)))

(define c->P (lambda (c) (cadr c)))

(define empty-s '())

(define empty-c '(() ()))

(define negation-counter 0)

(define ground-program -2)

(define call-frame-stack '())

(define (expand-cfs k v cfs)
  (adjoin-set (make-record k v) cfs))

;;; Record the procedure we produced the result.
(define (ext-p name argv)
  (lambdag@(n cfs c : S P)
    ; At this point, all arguments have a substitution.
    (let ((key (map (lambda (arg)
                    (walk arg S)) argv) ))
    ; So the partial result will record the predicate with actual values.
    (list S (adjoin-set (make-record (list name key) n) P)))))

(define walk
  (lambda (u S)
    (cond
      ((and (var? u) (assq u S)) =>
       (lambda (pr) (walk (rhs pr) S)))
      (else u))))

(define ext-s
  (lambda (x v s)
    (cons `(,x . ,v) s)))

(define unify
  (lambda (u v s)
    (let ((u (walk u s))
          (v (walk v s)))
      (cond
        ((eq? u v) s)
        ((var? u) (ext-s-check u v s))
        ((var? v) (ext-s-check v u s))
        ((and (pair? u) (pair? v))
         (let ((s (unify 
                    (car u) (car v) s)))
           (and s (unify 
                    (cdr u) (cdr v) s))))
        ((equal? u v) s)
        (else #f)))))

(define ext-s-check
  (lambda (x v s)
    (cond
      ((occurs-check x v s) #f)
      (else (ext-s x v s)))))

(define occurs-check
  (lambda (x v s)
    (let ((v (walk v s)))
      (cond
        ((var? v) (eq? v x))
        ((pair? v) 
         (or 
           (occurs-check x (car v) s)
           (occurs-check x (cdr v) s)))
        (else #f)))))

(define walk*
  (lambda (w s)
    (let ((v (walk w s)))
      (cond
        ((var? v) v)
        ((pair? v)
         (cons
           (walk* (car v) s)
           (walk* (cdr v) s)))
        (else v)))))

(define reify-s
  (lambda (v s)
    (let ((v (walk v s)))
      (cond
        ((var? v)
         (ext-s v (reify-name (length s)) s))
        ((pair? v) (reify-s (cdr v)
                     (reify-s (car v) s)))
        (else s)))))

(define reify-name
  (lambda (n)
    (string->symbol
      (string-append "_" "." (number->string n)))))

(define reify
  (lambda (v s)
    (let ((v (walk* v s)))
      (walk* v (reify-s v empty-s)))))

(define mzero (lambda () #f))

(define-syntax inc 
  (syntax-rules () ((_ e) (lambdaf@ () e))))

(define unit (lambda (c) c))

(define choice (lambda (c f) (cons c f)))
 
(define-syntax case-inf
  (syntax-rules ()
    ((_ e (() e0) ((f^) e1) ((a^) e2) ((a f) e3))
     (let ((a-inf e))
       (cond
         ((not a-inf) e0)
         ((procedure? a-inf)  (let ((f^ a-inf)) e1))
         ((not (and (pair? a-inf)
                    (procedure? (cdr a-inf))))
          (let ((a^ a-inf)) e2))
         (else (let ((a (car a-inf)) (f (cdr a-inf))) 
                 e3)))))))

(define-syntax run
  (syntax-rules ()
    ((_ n (x) g0 g ...)
     (take n
       (lambdaf@ ()
         ((fresh (x) g0 g ... 
          ; [ToDo] Performance optimization, stratified programs don't need such
          ; checking, we are still deciding which way we want to choose. If our
          ; priority ordering algorithm can turn the BFS into DFS in a few
          ; iterations on stratified programs, we saved extra computation on
          ; determining whether the input program is stratified.
          (lambdag@ (negation-counter cfs c : S P)
            (if (null? 
                ; `check-all-rules` computes all future answers, but we only
                ; need to find one to make sure the partial answer is good.
                ;
                ; [ToDo] Performance optimization, currently, the computation is
                ; evenly interleaved among different streams (BFS). And we can
                ; use the information we collected from different streams to change
                ; the priority of each stream. Eventually, the 100% one will
                ; dominate (found the answer), and our computation becoming DFS.
                ; Here is where the bottom-up CDNL could be helpful, we will
                ; explore more later.
                ;
                ; Lastly, to show there is no answer, we must iterate through
                ; all streams, but putting the unsatisfiable loop early would
                ; help reduce the fan-out.
                (take 1 
                  (lambdaf@ ()
                    ((check-all-rules program-rules x) negation-counter cfs c))))
              (mzero)
              (cons (reify x S) '()))))
          negation-counter call-frame-stack empty-c))))))
 
(define take
  (lambda (n f)
    (if (and n (zero? n)) 
      '()
      (case-inf (f)
        (() '())
        ((f) (take n f))
        ((a) a)
        ((a f)
         (cons (car a)
           (take (and n (- n 1)) f)))))))

(define ==
  (lambda (u v)
    (lambdag@ (n cfs c : S P)
      (if (even? n)
        (cond
          [(unify u v S) => 
            (lambda (s+) 
              (unit (list s+ P)))]
          [else (mzero)])
        (cond
          [(unify u v S) => 
            (lambda (s+) 
              (mzero))]
          [else (unit c)])))))

(define-syntax fresh
  (syntax-rules ()
    ((_ (x ...) g0 g ...)
     (lambdag@ (n cfs c)
       (inc
         (let ((x (var 'x)) ...)
           (bind* n cfs (g0 n cfs c) g ...)))))))

;;; It's a recursive process that iterates through all values of the bounded
;;; temporary variables and creates an incomplete stream(inc) of 
;;; conjunction(bind*) over the future sub-goals under the current value and 
;;; the future sub-goals under other values.
(define-syntax forall
  (syntax-rules ()
    [(_ (x ...) (g ...) vars)
      ; Removing all vars from (x ...), get the remaining temporary variables.
      (let ([var-list (remove-var-from-list (list x ...) vars)])
        (define (iterate-values values)
          (lambdag@ (n cfs c : S P)
            (if (null? values)
              c
              (inc (bind* n cfs
                  ; The remaining temporary variables need "fresh-t" again.
                ((fresh-t (var-list) g ...) n cfs
                  ; So we can extend vars with all variables by ourselves.
                  (list (ext-s-for-all-vars vars (car values) S) P))
                  (iterate-values (cdr values)))))))
        iterate-values)]))

;;; This macro uses the generator "g0", bounded variables, current CFS, and 
;;; current substitution to construct an internal program to generate all values.
;;; The "take #f" is the underlying implementation of the "run*" interface,
;;; please refer to the "run*"" implementation to learn more details.
;;;
;;; For example,
;;; edge(a, b), edge(b, c), edge(a, d).
;;; 
;;; > (run* (q) (fresh (x y) (edge x y) (== q `(,x ,y))))
;;; ((a b) (b c) (a d))
;;;
;;; If x is bounded in the current substitution, the program will get domain of
;;; y based on that information.
;;; > (run* (q) (fresh (x y) (== x 'a) (edge x y) (== q `(,x ,y))))
;;; ((a b) (a d))
;;; Here, (b c) will not show up.
(define-syntax domain-values
  (syntax-rules ()
    [(_ g0 bounded-vars cfs s)
     (take #f (lambdaf@ ()
        ; Here, (fresh (tmp)) is the same as (q) in the example.
        ((fresh (tmp)
          ; g0 is the actual goal during the runtime (edge x y) in the example.
          g0
          ; bounded-vars is a list of temporary variables we created, like the
          ; (fresh (x y)) in the example.
          ; So, (== tmp bounded-vars) is the same as (== q `(,x ,y)).
          (== tmp bounded-vars)
          ; Eventually, we reify the tmp variable to get all values.
          (lambdag@ (dummy_n dummy_cfs c : S P)
            (cons (reify tmp S) '())))
          negation-counter cfs s)))]))

;;; Our previous implementation of complement and conde-t applies the DeMorgan 
;;; rule on the disjunction of a set of rules in conjunctive normal form (CNF).
;;; The transformation only works for propositional logic. To evolve the
;;; transformer to fully support predicate logic, we need to handle the rule
;;; with a "fresh" (existential quantifier) operator.
(define-syntax complement-fresh
  (syntax-rules (fresh)
    ((_ (fresh (x ...) g0 g ...)) (fresh (x ...)
                                      (fresh-t (x ...) g0 g ...)))
    ;;; For predicate logic, even for the rule without "fresh" can't directly 
    ;;; apply DeMorgan law. The two variables in one predicate are related to 
    ;;; each other. 
    ((_ g0 g ...) (fresh-t () g0 g ...))))

;;; The existential quantifier introduces a new temporary variable in the body 
;;; of the rule. Therefore, we can't simply apply the DeMorgan law as we did for
;;; the propositional program. The temporary variable may or may not bind to a
;;; value during the evaluation process; a predicate can serve as a generator to
;;; assign a value to the temporary variable or as a checker to check the value
;;; of the temporary variable still holds.
;;;
;;; For example,
;;; edge(a, b), edge(b, c), edge(a, d).
;;;
;;; reachable(X, Y) :- edge(X, Y).
;;; reachable(X, Y) :- edge(X, Z), reachable(Z, Y).
;;;
;;; reducible(X) :- reachable(X, Y), not reachable(Y, X).
;;;
;;; The former predicates edge(X, Z), and reachable(X, Y) in rule "reachable" 
;;; and "reducible" respectively, are served as the generator. The latter
;;; predicates edge(Z, Y) and reachable(Y, X) are served as the checker.
;;; The complement of the generator is simple. "There is an edge(X, Z)" to 
;;; "There is *no* edge(X, Z).", but the complement of the checker needs to 
;;; include the mutually exclusive of the first part. "If there is an edge(X, Z),
;;; then it is not reachable(Z, Y)."
;;;
;;; The complement rule of "reachable" is saying that "There is no exist such Z,
;;; that edge(X, Z) and reachable(Z, Y) is true." The equivalent statement is
;;; "For all values of Z, that there is *no* edge(X, Z), or if there is 
;;; an edge(X, Z), then it is not reachable(Z, Y)."
(define-syntax fresh-t
  (syntax-rules ()
    ;;; So the complement of fresh should be a disjunction of the negation to
    ;;; each sub-goal in conjunction with all sub-goals before the current one.
    ;;;
    ;;; Note: fresh-t is working as "not exist", so the negation counter carries
    ;;; an implicit negation with an odd number during the runtime.
    ;;; Hence, "g0" means "not g0", solving the negative goal, and
    ;;;   "noto g0" means "g0", solving the positive goal.
    ((_ (x ...) g0)
     g0)
    ((_ (x ...) g0 g ...)
     (conde 
       [g0] 
       ;;; Before executing "g0", we saved the current context.
       [(lambdag@ (n cfs c : S P)
          ((fresh ()
            ; Run g0
            (noto g0)
            ;;; After executing "g0", we are comparing the two context.
            (lambdag@ (nn ff cc : SS PP)
                     ; Diff the length of two substitutions.
              (let* ([diff (- (length SS) (length S))]
                     ; Use the diff to get difference of the two lists.
                     [extended-s (get-first-n-elements SS diff)]
                     ; Use the list to get bounded temporary variables.
                     [argv (list x ...)]
                     [bounded-vars (find-bound-vars argv extended-s)])
                ; Check if any (x ...) got a value.
                (if (null? bounded-vars)
                  ; if not keep running future sub-goals (g ...).
                  ((fresh-t (x ...) g ...) nn ff cc)
                  ; if so get all values of the variables.
                  ; check all future sub-goals (g ...) can be proven true for 
                  ; ALL values of bounded-vars.
                  (((forall (x ...) (g ...) bounded-vars) 
                    (domain-values g0 bounded-vars cfs c)) n cfs c))))
          ) n cfs c))]))))

;;; Ignore the negative literal in the program to ground the variable.
;;; This gives us a superset of the variable's values.
(define-syntax ignore-negation
  (syntax-rules (conde)
    ((_ (conde (g0 g ...) (g1 g^ ...) ...))
        (conde [(ignore-negation g0 g ...)]
               [(ignore-negation g1 g^ ...)]
               ...))
    ((_ (fresh (x ...) g0 g ...))
        (fresh (x ...) (ignore-negation g0 g ...)))
    ((_ (g0 ...)) 
      (let ((name (car `(g0 ...))))
        (if (equal? name 'noto)
            succeed
            (g0 ...))))
    ((_ (g0 ...) (g1 ...) ...) 
      (let ((name (car `(g0 ...))))
        (fresh () 
          (if (equal? name 'noto)
            succeed
            (g0 ...))
        (ignore-negation (g1 ...) ...))))
    ((_ g) g)))
 
(define-syntax bind*
  (syntax-rules ()
    ((_ n cfs e) e)
    ((_ n cfs e g0 g ...) (bind* n cfs (bind n cfs e g0) g ...))))
 
(define bind
  (lambda (n cfs a-inf g)
    (case-inf a-inf
      (() (mzero))
      ((f) (inc (bind n cfs (f) g)))
      ((a) (g n cfs a))
      ((a f) (mplus (g n cfs a) (lambdaf@ () (bind n cfs (f) g)))))))

(define-syntax conde
  (syntax-rules ()
    ((_ (g0 g ...) (g1 g^ ...) ...)
     (lambdag@ (n cfs c) 
       (inc 
         (mplus* 
           (bind* n cfs (g0 n cfs c) g ...)
           (bind* n cfs (g1 n cfs c) g^ ...) ...))))))

;;; Turns conjunction of goals (g0, g, ...) into disjunction of goals (g0; g; ...).
(define-syntax conde-t
  (syntax-rules ()
    ((_ (g0 g ...) (g1 g^ ...) ...)
     (fresh ()
       (complement-fresh g0 g ...)
       (complement-fresh g1 g^ ...) ...))))

;;; Transform the original rule to the complement form.
(define-syntax complement
  (syntax-rules (conde)
    ((_ (conde (g0 g ...) (g1 g^ ...) ...)) 
     (conde-t (g0 g ...) (g1 g^ ...) ...))
    ((_ g0 g ...)
     (conde-t (g0 g ...)))))
 
(define-syntax mplus*
  (syntax-rules ()
    ((_ e) e)
    ((_ e0 e ...) (mplus e0 
                    (lambdaf@ () (mplus* e ...))))))
 
(define mplus
  (lambda (a-inf f)
    (case-inf a-inf
      (() (f))
      ((f^) (inc (mplus (f) f^)))
      ((a) (choice a f))
      ((a f^) (choice a (lambdaf@ () (mplus (f) f^)))))))

(define-syntax conda
  (syntax-rules ()
    ((_ (g0 g ...) (g1 g^ ...) ...)
     (lambdag@ (n cfs c)
       (inc
         (ifa n cfs ((g0 n cfs c) g ...)
                   ((g1 n cfs c) g^ ...) ...))))))
 
(define-syntax ifa
  (syntax-rules ()
    ((_ n cfs) (mzero))
    ((_ n cfs (e g ...) b ...)
     (let loop ((a-inf e))
       (case-inf a-inf
         (() (ifa n cfs b ...))
         ((f) (inc (loop (f))))
         ((a) (bind* n cfs a-inf g ...))
         ((a f) (bind* n cfs a-inf g ...)))))))

(define-syntax condu
  (syntax-rules ()
    ((_ (g0 g ...) (g1 g^ ...) ...)
     (lambdag@ (n cfs c)
       (inc
         (ifu n cfs ((g0 n cfs c) g ...)
                   ((g1 n cfs c) g^ ...) ...))))))
 
(define-syntax ifu
  (syntax-rules ()
    ((_ n cfs) (mzero))
    ((_ n cfs (e g ...) b ...)
     (let loop ((a-inf e))
       (case-inf a-inf
         (() (ifu n cfs b ...))
         ((f) (inc (loop (f))))
         ((a) (bind* n cfs a-inf g ...))
         ((a f) (bind* n cfs (unit a) g ...)))))))

(define-syntax project
  (syntax-rules ()
    ((_ (x ...) g g* ...)
     (lambdag@ (n cfs c : S P)
       (let ((x (walk* x S)) ...)
         ((fresh () g g* ...) n cfs c))))))

(define succeed (== #f #f))

(define fail (== #f #t))

(define onceo
  (lambda (g)
    (condu
      (g succeed)
      ((== #f #f) fail))))

(define program-rules `())

(define reset-program (lambda () (set! program-rules `())))

;;; Fetch one rule from the program rules set until the set is empty.
(define (fetch-rule rules-set)
  (if (null? rules-set)
      #f
      (car rules-set)))

;;; Construct a list of n temporary variables.
(define (construct-var-list n)
  (if (= n 0)
      `()
      (cons (var (format "temp_~a" n)) (construct-var-list (- n 1)))))

;;; Use the reduct program to get all value sets of a given goal with unbounded
;;; variables. The reduct program is a special program without any negations.
;;; The "take #f" is the underlying implementation of the "run*" interface,
;;; please refer to the "run*"" implementation to learn more details.
;;;
;;; For example,
;;;   A goal function edge(x, y)
;;;   We do "(run* (tmp) (fresh (x y) (edge x y) (== tmp `(,x ,y))))"
;;;
;;; This function is different than the `domain-values` we used for getting
;;; values under context settings. (n is always -2 v.s n = negation counter)
(define (get-values goal vars)
  ; [ToDo] If we get an empty set after filtering, we found an unsafe variable.
  (sort compare-element (remove-duplicates 
  (take #f 
    (lambdaf@ ()
      ((fresh (tmp)
        (apply (eval goal) vars)
        (== tmp vars)
        (lambdag@ (n f c : S P)
          (cons (reify tmp S) '())))
        ground-program call-frame-stack empty-c))))))

;;; For a normal program, we need to check all the rules, especially those with 
;;; negation literals inside. So that we make sure we find a stable model.
(define (check-all-rules rules-set x)
  (lambdag@ (dummy frame final-c : S P)
    (let ((rule (fetch-rule rules-set)))
      (if (and rule #t)
        ; [ToDo] Handle the propositional case here.
        ; If the arity is 0, we don't need to get-values, we can run the
        ; goal directly.
        (let* ([goal (get-key rule)]
               [arity (get-value rule)]
               [vals (get-values goal (construct-var-list arity))])
          (bind* dummy frame
            ((check-rule-with-all-values goal vals) dummy frame final-c)
            (check-all-rules (cdr rules-set) x)))
        (cons (reify x S) '())))))

;;; For each rule, we need to check all possible values of head variables. 
(define (check-rule-with-all-values rule values)
  (lambdag@(_ cfs c)
    (if (null? values)
      (unit c)
      (inc
        (mplus*
          (bind* 0 cfs 
            ((apply (eval rule) (car values)) 0 cfs c)
            (check-rule-with-all-values rule (cdr values)))
          (bind* 1 cfs 
            ((apply (eval rule) (car values)) 1 cfs c)
            (check-rule-with-all-values rule (cdr values)))
        )))))

(define-syntax noto
  (syntax-rules ()
    ((noto (name params ...))
      (lambdag@ (n cfs s)
        ((name params ...) (+ 1 n) cfs s)))))

(define-syntax defineo
  (syntax-rules ()
    ((_ (name params ...) exp ...)
      (begin
      ;;; Add rule to program-rules set.
      (set! program-rules (adjoin-set (make-record `name 
                                        (length (list `params ...)))
                            program-rules))
      ;;; Define a goal function with the original rules "exp ...", and the 
      ;;; complement rules "complement exp ..."
      (define name (lambda (params ...)
        ;;; Obtain a list of argument variables.
        (let ([argv (list params ...)])
        (lambdag@ (n cfs c : S P)
          ;;; Concrete the variables to values.
          ;;; If the variable has a substitution it will be replaced with a 
          ;;; value, otherwise it will be the parameter's name.
          (let* ([args (map (lambda (arg)
                             (walk* arg S))
                           argv)]
                 [signature (list `name args)]
                 [result (element-of-set? signature P)]
                 [record (element-of-set? signature cfs)])
          ;;; Before the execution, check if we have computed the partial result.
          (cond
            ;;; If the partial result has the same parity as n, returning true.
            ;;; Otherwise, returning false.
            ;;; Since we only save the successfully proved result, for example,
            ;;; we have proved "not a(5)" is true, the partial result would be
            ;;; ( ((a 5) 1) ), the next time we are sovling "a(5)", we should
            ;;; return false.
            [(and result (even? (+ n (get-value result)))) (unit c)]
            [(and result (odd? (+ n (get-value result)))) (mzero)]
            (else
          ;;; Before the execution, check if the goal we have encountered during
          ;;; the solving process.
          (if (and record #t)
            (let ([diff (- n (get-value record))])
            (cond
              ;;; Positive loop. Minimal model semantics specified the positive
              ;;; loop should return false.
              [(and (= 0 diff) (even? n)) (mzero)]
              [(and (= 0 diff) (odd? n)) (unit c)]
              ;;; Negative loop. Stable model semantics specified the odd loop
              ;;; should return false and the even loop should return choice of
              ;;; true or false.
              ;;; [ToDo] To make the solver fully declarative top-down, it is 
              ;;; supposed to add a complementary version of the current goal
              ;;; into the resolution process. We are using some bottom-up 
              ;;; ideas in the global constraint checking `check-all-rules.`
              [(and (not (= 0 diff)) (odd? diff)) (mzero)]
              [(and (not (= 0 diff)) (even? diff)) (choice c mzero)]))
            ;;; During the execution, the goal function picks the corresponding
            ;;; rule set based on the value of the negation counter.
            ;;;   n >= 0 and even, use original rules
            ;;;   n >= 0 and odd, use complement rules
            ;;; After the execution, we memorize the partial result. We can't 
            ;;; use the signature for ext-p here, as the signature was obtained
            ;;; before the execution of the goal function.
            ((cond ((= n ground-program) (fresh () (ignore-negation exp ...)))
                   ((even? n) (fresh () exp ... (ext-p `name argv)))
                   ((odd? n) (fresh () (complement exp ...) (ext-p `name argv)))
                   (else fail))
              n (expand-cfs signature n cfs) c)))))))))))))

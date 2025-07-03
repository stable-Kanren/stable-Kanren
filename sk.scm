(load "mk.scm")


;;; Syntax analysis to find any negation (noto) in the program.
(define-syntax has-negation?
  (syntax-rules (noto conde fresh)
    ((_ (noto g)) #t)
    ((_ (conde (g0 g ...) (g1 g^ ...) ...))
        (or (has-negation? g0 g ...)
            (has-negation? g1 g^ ...)
            ...))
    ((_ (fresh (x ...) g0 g ...))
        (has-negation? g0 g ...))
    ((_ g) #f)
    ((_ g0 g1 ...) 
        (or (has-negation? g0)
            (has-negation? g1)
            ...))
))

;;; Ignore the negative literal in the program to ground the variable.
;;; This gives us a superset of the variable's values.
(define-syntax ignore-negation
  (syntax-rules (noto conde fresh)
    ((_ (conde (g0 g ...) (g1 g^ ...) ...))
        (conde [(ignore-negation g0 g ...)]
               [(ignore-negation g1 g^ ...)]
               ...))
    ((_ (fresh (x ...) g0 g ...))
        (fresh (x ...) (ignore-negation g0 g ...)))
    ((_ (noto g)) succeed)
    ((_ g) g)
    ((_ g0 g1 ...)
      (fresh ()
    	(ignore-negation g0)
    	(ignore-negation g1)
    	...))
    ((_ g) g)))

;;; ==== self-aware program analysis twins (body) ====
;;;
;;; Syntax analysis to find stratified negations (noto + loop) in the program.
;;; This is the first part, body translation, where the body of each clause is
;;; rewritten. The head definition happens with `defineo`, where we assign
;;; different semantics to the loops. In the body translation, we remove the
;;; variables and append a suffix (+/-) to the goal's name to create twins.
;;; 
;;; Refer to the stratified negation definition for the justification.
;;; A stratified negation means the negation (noto) and the loop in the program
;;; do not mix. There are two levels of stratification: compilation time and
;;; execution time. Compilation time means the stratification can be identified
;;; by analyzing the input program with little effort, through simulation. 
;;; We identify the compilation time here by removing the variables in the
;;; program and creating two twins.
;;; 
;;; [ToDo] This works at the syntax level only; add runtime level analysis later.
(define-syntax positive-twin
  (syntax-rules (conde fresh noto == succeed fail)
    ;;; [ToDo] It seems like the macro can not transform the program twice, or
    ;;; we do not know how to do this properly yet. It is supposed to convert
    ;;; unifications(==) to succeed, then merge all successes under the same
    ;;; clause into one. So, we can reduce the number of successes during the
    ;;; evaluation. We handle the special case, which contains all unifications.
    ((_ (conde [(== a ...) ...] [(== b ...) ...] ...))
        succeed)
    ((_ (fresh (x ...) g g0 ...))
        (fresh () (positive-twin g) (positive-twin g0) ...))
    ((_ (conde [g g0 ...] [g1 g^ ...] ...))
        (conde [(positive-twin g) (positive-twin g0) ...] [(positive-twin g1) (positive-twin g^) ...] ...))
    ((_ (noto g))
        (noto (positive-twin g)))
    ;;; Here, unification is always replaced with success, no matter what
    ;;; unification returns (success or failure). The failure at runtime will
    ;;; cut off the loop. We assume the unification did not break the loop here,
    ;;; so we are conservatively determined it is not stratified. If this false
    ;;; positive case mistakenly interprets the program as non-stratified during
    ;;; the syntax analysis, the runtime analysis will capture it. 
    ((_ (== u v))
        succeed)
    ((_ succeed) succeed)
    ((_ fail) fail)
    ((_ (p ...))
        (eval `(,(sym-append-str (car `(p ...)) "+"))))
    ((_ g g0 ...) (fresh () (positive-twin g) (positive-twin g0) ...))
    ))

(define-syntax negative-twin
  (syntax-rules (conde fresh noto == succeed fail)
    ;;; Ditto positive-twin comment.
    ((_ (conde [(== a ...) ...] [(== b ...) ...] ...))
        succeed)
    ((_ (fresh (x ...) g g0 ...))
        (fresh () (negative-twin g) (negative-twin g0) ...))
    ((_ (conde [g g0 ...] [g1 g^ ...] ...))
        (conde [(negative-twin g) (negative-twin g0) ...] [(negative-twin g1) (negative-twin g^) ...] ...))
    ((_ (noto g))
        (noto (negative-twin g)))
    ;;; Ditto positive-twin comment.
    ((_ (== u v))
        succeed)
    ((_ succeed) succeed)
    ((_ fail) fail)
    ((_ (p ...))
        (eval `(,(sym-append-str (car `(p ...)) "-"))))
    ((_ g g0 ...) (fresh () (negative-twin g) (negative-twin g0) ...))
    ))
;;; ---- self-aware program analysis twins (body) ----

;;; ==== predicate constraint ====
;;; Compile emitters and verifier as our internal constraint rule representation.
;;; It is a key-value pair of <emitter, [emitters list, verifier]>.
;;;
;;; The emitter list tracks all emitters to ensure the verifier receives 
;;; sufficient values from the emitter. Every time an emitter emits values,
;;; it is removed from the list (through constraint-updater); when the list is
;;; empty, the verifier has all values and is ready to verify the constraint 
;;; through constraint-checker.
;;;
;;; We use the predicate (goal function) name + 0 or 1 + predicate's parameters
;;; as the emitter name.
;;; (p x)           ---> '(p0 x)
;;; (noto (q y z))  ---> '(q1 y z)
;;; 0 or 1 depends on the emitter coming from a positive(0) or negative (1) goal.
;;;
;;; We can only keep a unique emitter name as the key to save space. To speed up
;;; the remove operation on the list, we put the emitter used as key at the first. 
;;;
(define (constraint-compiler emitters expr)
  (remove-duplicates 
  (map (lambda (emitter)
        `(,(car emitter) 
         (,(move-to-first emitter emitters
              (lambda (l r) (eq? (car l) (car r))))
          ,expr)))
  emitters)))

;;; There are two types of emitters: a negative one "(noto (p x))" and
;;; a positive one "(p x)." We append a 1 to the negative predicate's name;
;;; and a 0 to the positive predicate's name.
;;;
;;; [ToDo] Handle the nested negative emitter like "(noto (noto (noto (p x))))".
(define-syntax constraint-emitter
  (syntax-rules (noto)
    [(_ (noto (g x ...)))
        `(,(sym-append-str `g "1") x ...)]
    [(_ (g x ...))
        `(,(sym-append-str `g "0") x ...)]))

;;; The emitters (goal functions) are controlled by the constraintos. In this
;;; case, they become a global constraint that requires checking no matter they
;;; have been reached or not.
(define (emitter-global-checking emitters)
  (map (lambda (row)
         ; This is not thread safe, same as other exclamation mark operators.
         (add-global-checking-rules! (car row) (cadr row)))
       (filter (lambda (row)
                 (not (get-global-checking-rules (car row))))
               (remove-duplicates emitters))))

;;; It extracts the emitter name and its arity.
;;; (noto (p x y))  --->  '(p 2)
;;; (q x y z)       --->  '(q 3)
(define-syntax emitter-signature
  (syntax-rules (noto)
    [(_ (noto (g x ...)))
        `((g ,(length `(x ...))))]
    [(_ (g x ...))
        `((g, (length `(x ...))))]
    [(_ g ...)
        `(,(car (emitter-signature g)) ...)]))

;;; A constrainto interface for users to define constraints. The constraint has
;;; a list of emitters and a list of verifiers.
;;;
;;; [ToDo] Sanity checking to ensure the verifier gets sufficient values from
;;; the emitter and returns a boolean result. A syntax sugar to simplify encoding.
;;; For example,
;;;   ((q x))        ---> ((q x)) (())
;;;   ((noto (p 1))) ---> ((noto (p x))) ((= x 1))
;;;   ((p x) (q x))  ---> ((p y) (q z)) ((= y z))
(define-syntax constrainto
  (syntax-rules ()
    [(_ () (expr ...))
      (display "[Warning] At least one emitter is needed in constrainto!\n")]
    [(_ (g ...) (expr ...))
      (begin
      (emitter-global-checking (emitter-signature g ...))
      (set! constraint-rules
        (append constraint-rules
          (constraint-compiler
            `(,(constraint-emitter g) ...)
            '(and expr ...)))))]))

;;; Add a quote to a list of symbols. So, it can be evaluated as data, not code.
;;; (eval (eq? a a)) ---> (eval (eq? 'a 'a))
;;;
;;; It has to be a macro to modify code as data, and it can not be a function.
;;; It works for a list of string, number, and symbol only.
;;; [ToDo] Add support for complex data structure.
(define-syntax quote-symbol
  (syntax-rules ()
    [(_ (syms ...))
      `('syms ...)]))

;;; To wrap verifier `expr` around with values from the emitter. (Metaprogramming)
;;; Verifer like (and (= x y) (> a b)) receives values from the emitter.
;;; We are constructing a lambda to provide values to the expression.
;;; [ToDo] Sanity checking to ensure (length (params ...)) = (length (values ...))
(define-syntax constraint-constructor
  (syntax-rules ()
    [(_ (params ...) (values ...) expr)
      `((lambda (params ...) expr) values ...)]))

;;; Match the constants in emitter's parameters.
;;; emitter: ('s sv), values: ('s 0) ---> matched 's
;;; emitter: ('e ev), values: ('s 0) ---> unmatched
;;;
;;; Assume the length of the emitter's parameters and values are the same. The
;;; built-in `map` will throw an error for different lengths.
;;;
;;; The internal representation of value is a list of `quote-symbol`s, so the
;;; variables can be represented as symbols. The `define-syntax` also converts
;;; values (symbol only) into the similar representation, so the variables will
;;; be symbols.
;;;
;;; For example, the parameter of an emitter in
;;; (constrainto [(emitter 's sv)] [])
;;; will be compiled into ((quote s) 'sv), the constant 's turns into (quote s),
;;; the variable sv turns into 'sv.
;;;
;;; Therefore, during the runtime, we will have:
;;; emitter: ((quote s) 'sv), values: ((quote s) (quote 0)).
;;;
;;; Currently, this function serves two purposes: matching constants or variables.
;;; If the emitter has no constants, this function always returns true.
;;; [ToDo] The constant emitters and variable emitters are mixed in the global
;;; and local constraint sets (`constraint-rules` and `L` in `lambdag@`).
;;; Modifying this data structure into two sets, we may have a better algorithm.
(define (constraint-emitter-matched-constants? params vals)
  ; Filter out the emitter that has matched constants or all variables.
  (fold-left (lambda (l r) (and l r)) #t
    (map (lambda (p v)
           ; If the parameter is a symbol, it is a variable.
           (or (symbol? p)
               ; Or it is not a variable; we try to match constants.
               (and (not (symbol? p))
                    ; [ToDo] (equal? p v) is faster, but produces the wrong
                    ; answer for some problems. The reason is `quote-symbol`
                    ; quote everything, including numbers and strings, but the 
                    ; `define-syntax` stores numbers without a quote. If we
                    ; modify `quote-symbol` to actually only quote symbols, the
                    ; (equal? p v) became slower. There is more work needed to
                    ; investigate and refactor these internal representations.
                    (equal? (eval p) (eval v)))))
    params vals)))

;;; Remove the constants in emitter's parameters and corresponding values.
;;; emitter: ('s sv), values: ('s 0) ---> emitter: (sv), values: (0)
;;; It always removes the constants no matter it matches the values or not.
;;; emitter: ('e ev), values: ('s 0) ---> emitter: (ev), values: (0)
;;; 
;;; Assume they are matched by the `constraint-emitter-matched-constants?`, and
;;; the length of the emitter's parameters and values are the same. The built-in
;;; `map` will throw an error for different lengths.
;;;
;;; The internal representation of variables is symbol, and the emitters are
;;; emitting values to the variables. So, we can use `symbol?` to filter out all
;;; variables in the emitter, and the corresponding values.
;;;
;;; For example, the parameter of an emitter in
;;; (constrainto [(emitter 's sv)] [])
;;; will be compiled into ((quote s) 'sv), the constant 's turns into (quote s),
;;; the variable sv turns into 'sv.
;;;
;;; Therefore, during the runtime, we will have:
;;; emitter: ((quote s) 'sv), values: ((quote s) (quote 0)).
;;; We need to remove all constants (numbers, symbols, strings, lists), only
;;; keep the variables. Ater removal, we will have:
;;; emitter: ('sv), values: ((quote 0))
;;;
;;; Note: The ordering of params and vals are reversed, and it does not matter.
;;; As long as the value is bind to the correct variable during constraint
;;; handler construction (building lambda).
(define (constraint-emitter-remove-constants params vals)
  (fold-left
    (lambda (l r)
      `(,(cons (car r) (car l)) ,(cons (cadr r) (cadr l))))
    `(() ())
    (filter
      (lambda (pair)
        (symbol? (car pair)))
      (map
        (lambda (p v)
          `(,p ,v))
        params vals))))

;;; Reorder the emitters in the list, so the first one will be the right one we
;;; use to construct the constraint handler (lambda).
;;; emitters: (('s sv) ('e ev) (p pv)), values: ('e '1)
;;; After reordering:
;;; emitters: (('e ev) ('s sv) (p pv))
;;;
;;; emitters: (('s sv) ('e ev) (p pv) (q qv)), values: ('r '0)
;;; After reordering:
;;; emitters: ((p pv) ('e ev) ('s sv) (q qv))
;;;
;;; Assume the constant constraints are placed before variable constraints, as
;;; we sorted in `constrainto` and the ordering is maintained in place.
;;; The emitter reordered to the first can be either constant or variable, as we
;;; showed in the above examples. This emitter will be consumed later by 
;;; `constraint-updater` and `constraint-checker`, so the rest of the emitters
;;; list remains the same property.
(define (constraint-emitter-reorder emitter_name emitters vals)
  (move-to-first vals emitters
    (lambda (values emitter)
      (and (eq? emitter_name (car emitter))
           (constraint-emitter-matched-constants?
             (cdr emitter) vals)))))

;;; Filter out the emitters that have only variables or matched constants.
;;; name: assign emitters: ((assign s sv) (assign e ev)) values: ('s '0) ---> #t
;;; name: apple  emitters: ((assign s sv) (assign e ev)) values: ('s '0) ---> #f
;;; name: assign emitters: ((assign 's sv) (assign e ev)) values: ('s '0) ---> #t
;;; name: assign emitters: ((assign 's sv) (assign e ev)) values: ('e '0) ---> #f
;;;
;;; If the emitters list has any matched emitter, the emitters list can be used
;;; for `constraint-updater` or `constraint-checker`.
;;;
;;; [ToDo] This is very similar to `constraint-emitter-reorder`, there may be a
;;; better computation order to combine the two processes into one. We tried a
;;; few, but the performance dropped if we reordered the emitters before filtering.
(define (constraint-emitter-filter emitter_name emitters vals)
  (fold-left (lambda (l r) (or l r)) #f
    (map
      (lambda (emitter)
        (and
          (eq? emitter_name (car emitter))
          (constraint-emitter-matched-constants?
            (cdr emitter) vals)))
    emitters)))

;;; To propagate constraints using the values from the emitter. It selects an
;;; emitter and produces a proper parameter list (`params`) for the values (`quote-s`)
;;; to wrap the constraint handler (`exprs`). Returning a list of values,
;;; parameters, constraint handler, and remaining constraints (`remains`).
(define (constraint-propagator emitter row vals)
  (let* ([quote-s (eval `(quote-symbol ,vals))]
         [params (cdr (caaadr row))]
         [exprs (cadadr row)]
         [remains (cdaadr row)])
  `(,quote-s ,params ,exprs ,remains)))

;;; The constraint is ready to check when the verifier receives the values from
;;; the last emitter. The verifier accumulates the previous values, which are
;;; stored in L. If the verifier only needs one emitter, it stores in constraint-rules.
;;;
;;; Therefore, we first combine constraint rules with L to filter out those verifiers
;;; that are ready to update after receiving the final values from the emitter.
;;; We use constraint-constructor to complete the verifier's continuation.
;;; Then, the verifier is ready to use eval to get the constraint checking outcome.
(define (constraint-checker emitter vals L)
  (fold-left (lambda (l r) (or l r)) #f
    (map (lambda (row)
           (let* ([result (constraint-propagator emitter row vals)]
                  [quote-s (car result)]
                  [params (cadr result)]
                  [exprs (caddr result)])
           (eval (constraint-constructor ,params ,quote-s ,exprs))))
         (filter (lambda (row)
                   (and (eq? emitter (car row))
                        (= (length (cdaadr row)) 0)))
                 (append constraint-rules L)))))


;;; The constraint gets updated when the verifier receives the values from the
;;; emitter but is not yet ready to evaluate. So, the partial verifier is stored
;;; as a continuation in L. The update will happen for both constraint-rule and L.
;;;
;;; Therefore, we first combine constraint rules with L to filter out those
;;; verifiers that are not ready to evaluate after receiving the values from the
;;; emitter. We use a constraint constructor to complete the verifier's continuation.
;;; Then, the remaining emitters are compiled with the update verifier via
;;; constraint compiler.
;;;
;;; [ToDo] The process is almost identical to a constraint-checker.
;;; A higher-level abstraction can refactor it.
(define (constraint-updater emitter vals L)
  (fold-left append `()
    (map (lambda (row)
           (let* ([result (constraint-propagator emitter row vals)]
                  [quote-s (car result)]
                  [params (cadr result)]
                  [exprs (caddr result)]
                  [remains (cadddr result)])
           (constraint-compiler 
             remains
             (constraint-constructor ,params ,quote-s ,exprs))))
         (filter (lambda (row)
                   (and (eq? emitter (car row))
                        (> (length (cdaadr row)) 0)))
                 (append constraint-rules L)))))

;;; ---- predicate constraint ----

;;; Record the procedure we produced the result.
(define (ext-p name argv)
  (lambdag@(n cfs c : S P L)
    ; At this point, all arguments have a substitution.
    (let* ([key (map (lambda (arg)
                     (walk* arg S)) argv)]
           [result (element-of-set? (list name key) P)]
           [emitter (sym-append-str name
                (number->string (modulo n 2)))])
    ; The query interface will also query the same goal multiple times with
    ; different variables. We use "<" to distinguish different variables,
    ; if it is "<=" we are allowing different variables to have the same values.
    ;
    ; [ToDo] This semantics is debatable. Using "<=" is closer to the nature of
    ; relational programming, where if the query variables didn't distinguish
    ; from each other, they should be allowed to have the same values.
    ; Currently, allowing the same values broadens the search scope and takes
    ; longer to produce results. So, we use "<" for now and will come back and
    ; adjust it after we have a heuristic search.
    (if (and result (< n (get-value result)))
      ; We do not check constraints if we had the truth value.
      (list S (adjoin-set (make-record (list name key) n) P) L)
      ; Ideally, these emitter should "attach" to the goal function in the "run"
      ; interface, so that we don't have to look it up here again and again.
      (if (constraint-checker emitter key L)
        ; Violated constraint terminates the search.
        (mzero)
        ; Otherwise, record predicate with truth value.
        (list S (adjoin-set (make-record (list name key) n) P) 
          (append L (constraint-updater emitter key L))))))))

(define-syntax noto
  (syntax-rules ()
    ((noto (name params ...))
      (lambdag@ (n cfs s)
        ((name params ...) (+ 1 n) cfs s)))))

;;; ==== self-aware program analysis twins (head) ====
;;;
;;; Syntax analysis to find stratified negations (noto + loop) in the program. 
;;; This is the second part, where the head definition of each clause is provided.
;;; The body translation happens with `positive/negative-twin`, where we remove
;;; the variables and append a suffix (+/-) to the goal's name to create twins.
;;; In the head definition, we assign different semantics to the loops.
;;;
;;; Refer to the stratified negation definition for the justification.
;;; A stratified negation means the negation (noto) and the loop in the program
;;; do not mix. There are two levels of stratification: compilation time and
;;; execution time. Compilation time refers to the stratification that can be
;;; identified by analyzing the input program with minimal effort through
;;; simulation.  We identify the compilation time here by dividing the twins 
;;; into different semantics. The positive twin returns true on a negative loop,
;;; but the negative twin returns false. Therefore, the twins produce the same
;;; results for stratified programs and produce different results for normal programs.
;;;
;;; [ToDo] This works at the syntax level only; add runtime level analysis later.
(define-syntax define-positive-twin
  (syntax-rules ()
    ((_ name exp ...)
      (eval 
       `(define (,(sym-append-str `name "+"))
          (lambdag@ (n cfs c : S P L)
            (let* ([name+ (sym-append-str `name "+")]
                   [signature (list name+ `())]
                   [result (element-of-set? signature P)]
                   [record (element-of-set? signature cfs)])
              ; Before the execution, check if the node we have encountered
              ; during the checking process.
              (if (and result #t) 
                (unit c)
                (if (and record #t)
                  (let ([diff (- n (get-value record))])
                    (if (= 0 diff)
                      ; Positive loop (stratified negation)
                      (unit c)
                      ; Negative loop (normal program)
                      (mzero)))
                  ((fresh ()
                     (positive-twin exp ...) (ext-p name+ `()))
                     n (expand-cfs signature n cfs) c))))))))))

(define-syntax define-negative-twin
  (syntax-rules ()
    ((_ name exp ...)
      (eval
        `(define (,(sym-append-str `name "-"))
          (lambdag@ (n cfs c : S P L)
            (let* ([name- (sym-append-str `name "-")]
                   [signature (list name- `())]
                   [result (element-of-set? signature P)]
                   [record (element-of-set? signature cfs)])
              (if (or (and result #t) (and record #t))
                ; Always succeed for positive and negative loop.
                (unit c)
                ((fresh ()
                   (negative-twin exp ...) (ext-p name- `()))
                   n (expand-cfs signature n cfs) c)))))))))

;;; ---- self-aware program analysis twins (head) ----

(define-syntax defineo
  (syntax-rules ()
    ((_ (name params ...) exp ...)
      (begin
      ;;; If a rule has a negation in it and hasn't been added by `constrainto,`
      ;;; add it to the global-checking-rules set.
      (if (and (has-negation? exp ...) (not (get-global-checking-rules `name)))
        (add-global-checking-rules! `name (length (list `params ...))))
      ;;; Define a propositional version of the original program for dependency
      ;;; graph analysis.
      (define-positive-twin name exp ...)
      (define-negative-twin name exp ...)
      ;;; Define a goal function with the original rules "exp ...", and the 
      ;;; complement rules "complement exp ..."
      (define name (lambda (params ...)
        ;;; Obtain a list of argument variables.
        (let ([argv (list params ...)])
        (lambdag@ (n cfs c : S P L)
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

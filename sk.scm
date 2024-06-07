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
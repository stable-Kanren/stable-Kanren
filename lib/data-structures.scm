(load "utils.scm")

;;; Getter and Setter of the checking rules.
;;; Store goal function signatures.
;;; Format: [(name, arity) ...]
;;; [ToDo] Add test cases.
(define (make-checking-rules)
  ; A list of rules to be checked.
  (define checking-rules `())

  ; Operations.
  (define (add-checking-rule! k v)
    (set! checking-rules
      (adjoin-set (make-record k v) checking-rules)))

  (define (get-checking-rule k)
    (element-of-set? k checking-rules))

  ; Interface.
  (define (ops m)
    (cond [(eq? m 'how-many-rules?) checking-rules]
          [(eq? m 'reset-rules!) (set! checking-rules `())]
          [(eq? m 'add-rule!) add-checking-rule!]
          [(eq? m 'get-rule) get-checking-rule]
          [else (error "Unknown request -- " m)]))
  ops)

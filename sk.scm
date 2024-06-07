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

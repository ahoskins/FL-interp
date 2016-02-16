(defun fl-interp (E P)
  (cond
    ((atom E) E)
    (t
      (let ((f (car E)) (arg (cdr E)))
        (cond
          ;;;;;; built-in functions

          ; first and rest
          ((eq f 'first) (car (fl-interp (car arg) P)))
          ((eq f 'rest) (cdr (fl-interp (car arg) P)))

          ; math functions
          ((eq f '+) (+ (fl-interp (car arg) P) (fl-interp (cadr arg) P)))
          ((eq f '-) (- (fl-interp (car arg) P) (fl-interp (cadr arg) P)))
          ((eq f '*) (* (fl-interp (car arg) P) (fl-interp (cadr arg) P)))

          ; greater than, less than, equal
          ((eq f '<) (< (fl-interp (car arg) P) (fl-interp (cadr arg) P)))
          ((eq f '>) (> (fl-interp (car arg) P) (fl-interp (cadr arg) P)))
          ((eq f '=) (= (fl-interp (car arg) P) (fl-interp (cadr arg) P)))

          ; and
          ((eq f 'and)
            (if (fl-interp (car arg) P)
              (if (fl-interp (cadr arg) P) t)
              nil
            )
          )

          ; or
          ((eq f 'or)
            (if (fl-interp (car arg) P)
              t
              (if (fl-interp (cadr arg) P) t nil)
            )
          )

          ; not
          ((eq f 'not)
            (not (fl-interp (car arg) P))
          )

          ; number
          ((eq f 'number)
            (numberp (fl-interp (car arg) P))
          )

          ; equal
          ((eq f 'equal)
            (equal (fl-interp (car arg) P) (fl-interp (cadr arg) P))
          )

          ; cons
          ((eq f 'cons)
            (cons (fl-interp (car arg) P) (fl-interp (cadr arg) P))
          )

          ; eq
          ((eq f 'eq)
            (eq (fl-interp (car arg) P) (fl-interp (cadr arg) P))
          )

          ; atom
          ((eq f 'atom)
            (atom (fl-interp (car arg) P))
          )

          ; null
          ((eq f 'null)
            (null (fl-interp (car arg) P))
          )

          ; if
          ((eq f 'if)
            (if (fl-interp (car arg) P)
              (fl-interp (cadr arg) P)
              (fl-interp (caddr arg) P)
            )
          )

          ; last case ::: f is not a function, return it all
          (t
            (cons f arg)
          )
        )
      )
    )
  )
)

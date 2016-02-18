; CMPUT 325 Assignment 2
; Andrew Hoskins, 1358383


; function invoked from command line to start it all
; @param E: FL expression to evaluate
; @param P: FL program (list of function definitions)
(defun fl-interp (E P)
  (fl-interp2 E P nil)
)

; main FL interpretation function
; @param E: FL expression to evaluate
; @param P: program (a list of function defs)
; @param vars: variable bindings for expression
(defun fl-interp2 (E P vars)
  (cond
    ((not (null (get-value E vars))) (car (get-value E vars))) ; return bindings value
    ((atom E) E)
    (t
      (let* ((f (car E)) (arg (cdr E)) (udf (get-value f P)))
        (cond
          ;;;;;; Built-in functions

          ; basic operations
          ((contains f '(+ - * < > = equal eq not atom cons null)) (apply f (interp-each arg P vars)))

          ; number
          ((eq f 'number) (numberp (fl-interp2 (car arg) P vars)))

          ; first and rest
          ((eq f 'first) (caar (interp-each arg P vars)))
          ((eq f 'rest) (cdar (interp-each arg P vars)))

          ; and, with shortcircuit
          ((eq f 'and)
            (if (fl-interp2 (car arg) P vars)
              (if (fl-interp2 (cadr arg) P vars) t nil)
              nil
            )
          )

          ; or, with shortcircuit
          ((eq f 'or)
            (if (fl-interp2 (car arg) P vars)
              t
              (if (fl-interp2 (cadr arg) P vars) t nil)
            )
          )

          ; if, only eval the appropriate clause
          ((eq f 'if)
            (if (fl-interp2 (car arg) P vars)
              (fl-interp2 (cadr arg) P vars)
              (fl-interp2 (caddr arg) P vars)
            )
          )

          ;;;;;; User defined functions

          ((not (null udf))
            (fl-interp2
              (car (get-body udf))
              P
              (append (associate (get-args udf) (interp-each arg P vars)) vars)
            )
          )

          ; not a function, atom, or bound to a value, return as data
          (t E)
        )
      )
    )
  )
)

; Check if key in list
; @param k: data to look for
; @param L: list to check in
; @return boolean
(defun contains (k L)
  (cond
    ((null L) nil)
    ((eq k (car L)) t)
    (t (contains k (cdr L)))
  )
)

; Interpret each in arg list
; @param arg: list of expressions
; @param P: list of user defined functions
; @param vars: bindings for current interpretation
(defun interp-each (arg P vars)
  (mapcar #'(lambda (x) (fl-interp2 x P vars)) arg)
)

; Get value from key-value mapping list
; @param k: key to look for
; @param L: list (key value)
; @return value from list at key
(defun get-value (k L)
	(cond
		((null L) nil)
		((eq k (caar L)) (cdar L))
		(t (get-value k (cdr L)))
	)
)

; Get body of FL function
; @param func: full FL function def
; @return function body
(defun get-body (func)
  (if (eq '= (car func))
    (cdr func)
    (get-body (cdr func))
  )
)

; Get arguments from FL function
; @param func: full FL function def
; @return list of function args
(defun get-args (func)
  (if (eq '= (car func))
    ()
    (cons (car func) (get-args (cdr func)))
  )
)

; Make list of (key value) for each
; @param keys: list of argument names
; @param vals: list of argument values
; @return list of lists containing all pairings
(defun associate (keys vals)
  (mapcar #'(lambda (x y) (list x y)) keys vals)
)

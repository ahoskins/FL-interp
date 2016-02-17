(defun fl-interp (E P)
  (fl-interp2 E P nil)
)

(defun fl-interp2 (E P vars)
  (cond
    ((atom E) E)
    ((not (null (get-value E vars))) (get-value E vars)) ; return bindings value if exists
    (t
      (let* ((f (car E)) (arg (cdr E)) (udf (get-value f P)))
        (cond
          ;;;;;; built-in functions

          ; basic operation
          ((contains f '(+ - * < > = equal eq not number atom cons null)) (apply f (interp-each arg P vars)))

          ; first and rest
          ((eq f 'first) (caar (interp-each arg P vars)))
          ((eq f 'rest) (cdar (interp-each arg P vars)))

          ; and
          ((eq f 'and)
            (if (fl-interp2 (car arg) P vars)
              (if (fl-interp2 (cadr arg) P vars) t nil)
              nil
            )
          )

          ; or
          ((eq f 'or)
            (if (fl-interp2 (car arg) P vars)
              t
              (if (fl-interp2 (cadr arg) P vars) t nil)
            )
          )

          ; if
          ((eq f 'if)
            (if (fl-interp2 (car arg) P vars)
              (fl-interp2 (cadr arg) P vars)
              (fl-interp2 (caddr arg) P vars)
            )
          )

          ;;;;;;; user defined functions

          ((not (null udf))
            (fl-interp2
              (get-body udf)
              P
              (append (associate (get-args udf) (interp-each arg P vars)) vars)
            )
          )

          ; not a function or bound to a value, return as data
          (t
            (cons f arg)
          )
        )
      )
    )
  )
)

(defun contains (f L)
  (cond
    ((null L) nil)
    ((eq f (car L)) t)
    (t (contains f (cdr L)))
  )
)

(defun interp-each (arg P vars)
  (mapcar #'(lambda (x) (fl-interp2 x P vars)) arg)
)

(defun get-value (k L)
	(cond
		((null L) nil)
		((eq k (caar L)) (cdar L))
		(t (get-value k (cdr L)))
	)
)

(defun get-body (func)
  (if (eq '= (car func))
    (cdr func)
    (get-body (cdr func))
  )
)

(defun get-args (func)
  (if (eq '= (car func))
    ()
    (cons (car func) (get-args (cdr func)))
  )
)

(defun associate (keys vals)
  (mapcar #'(lambda (x y) (list x y)) keys vals)
)

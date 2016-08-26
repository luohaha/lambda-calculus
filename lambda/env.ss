(define tags (make-eq-hashtable 32))

(define Tag
  (lambda (k v)
    (hashtable-set! tags k v)))

(define find-tag
  (lambda (k)
    (hashtable-ref tags k k)))

(define the-empty-env '())

(define add-to-env
  (lambda (k v env)
    (cons (cons k v) env)))

(define find-env
  (lambda (k env)
    (define (loop rest)
      (if (null? rest)
	  (begin (display "variable ")
		 (display k)
		 (display " not bound!\n"))
	  (if (eq? (caar rest) k)
	      (cdr (car rest))
	      (loop (cdr rest)))))
    (loop env)))

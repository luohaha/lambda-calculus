;;if x is the member of s
(define set-member?
  (lambda (x s)
    (cond [(null? s) #f]
	  [(eq? x (car s)) #t]
	  [else (set-member? x (cdr s))])))

(define set-cons
  (lambda (x s)
    (if (set-member? x s)
	s
	(cons x s))))

(define set-union
  (lambda (s1 s2)
    (if (null? s1)
	s2
	(set-union (cdr s1) (set-cons (car s1) s2)))))

(define set-minus
  (lambda (s1 s2)
    (if (null? s1)
	'()
	(if (set-member? (car s1) s2)
	    (set-minus (cdr s1) s2)
	    (cons (car s1) (set-minus (cdr s1) s2))))))

(define set-intersect
  (lambda (s1 s2)
    (if (null? s1)
	'()
	(if (set-member? (car s1) s2)
	    (cons (car s1) (set-intersect (cdr s1) s2))
	    (set-intersect (cdr s1) s2)))))



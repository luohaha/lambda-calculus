(define-syntax record
  (syntax-rules ()
    [(_ (var ...) val exp ...)
     (apply (lambda (var ...) exp ...) val)]
    [(_ (var . var2) val exp ...)
     (apply (lambda (var . var2) exp ...) val)]))

(define-syntax record-case
  (syntax-rules (else)
    [(_ exp1 (key vars exp2 ...) next ... (else exp3 ...))
     (let ((r exp1))
       (cond [(eq? (car r) 'key)
	      (record vars (cdr r) exp2 ...)]
	     [else (record-case exp1 next ... (else exp3 ...))]))]
    [(_ exp1 (else exp3 ...))
     (begin exp3 ...)]))

(define line 1)

(define (debug-line s)
  (let ((c line))
    (set! line (+ 1 line))
    (display c)
    (display " : ")
    (display s)
    (newline)))

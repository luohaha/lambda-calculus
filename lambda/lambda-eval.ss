(load "set.ss")

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

;;lambda形式变换
(define lambda-change
  (lambda (old)
    (cond [(pair? old)
	   (record-case
	    old
	    [proc (var body env)
		  `(lambda (,(lambda-change var)) ,(lambda-change body))]
	    [lambda (var body)
	      `(lambda (,(lambda-change var)) ,(lambda-change body))]
	    [else
	     `(,(lambda-change (car old)) ,(lambda-change (cadr old)))])]
	  [else old])))

(define tags (make-eq-hashtable 32))

(define Tag
  (lambda (k v)
    (hashtable-set! tags k v)))

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

(define make-procedure
  (lambda (var body env)
    `(proc ,var ,body ,env)))

(define execute
  (lambda (proc val)
    (lambda-analyze (caddr proc) (add-to-env (cadr proc) val (cadddr proc)))))

;;第一遍规约
(define lambda-analyze
  (lambda (x env)
    ;(debug-line x)
    (cond [(pair? x)
	   (record-case
	    x
	    [lambda (var body)
	      (make-procedure var body env)]
	    [else
	     (let ([proc (lambda-analyze (car x) env)]
		   [val (lambda-analyze (cadr x) env)])
	       (execute proc val))])]
	  [else (find-env x env)])))

(define post-execute
  (lambda (proc val bound)
    (post-analyze (caddr proc) (add-to-env (cadr proc) val (cadddr proc)) (set-cons (cadr proc) bound))))

;;后续的规约
(define post-analyze
  (lambda (x env bound)
    (cond [(pair? x)
	   (record-case
	    x
	    [lambda (var body)
	      `(lambda ,var ,(post-analyze body env (set-cons var bound)))]
	    [else (let ([proc (post-analyze (car x) env bound)]
			[val (post-analyze (cadr x) env bound)])
		    (if (and (pair? proc)
			     (eq? (car proc) 'proc))
			(post-execute proc val bound)
			`(,proc ,val)))])]
	  [else (if (set-member? x bound)
		    x
		    (find-env x env))])))

(define pre-analyze
  (lambda (x)
    (cond [(pair? x)
	   (record-case
	    x
	    [lambda (var body)
	      `(lambda ,(pre-analyze var) ,(pre-analyze body))]
	    [else
	     `(,(pre-analyze (car x)) ,(pre-analyze (cadr x)))])]
	  [else (hashtable-ref tags x x)])))

(define lambda-eval
  (lambda (x)
    (let ([proc (lambda-analyze (pre-analyze x) the-empty-env)])
      (post-analyze `(lambda ,(cadr proc) ,(caddr proc))
		    (cadddr proc) '()))))

;;将丘奇编码转化为数字
(define to-integer
  (lambda (proc)
    (((eval (lambda-change proc)) (lambda (x) (+ x 1))) 0)))

(define display-integer
  (lambda (proc)
    (display (to-integer proc))))

;;将丘奇编码转化为boolean
(define to-boolean
  (lambda (proc)
    (((eval (lambda-change proc)) #t) #f)))

(define display-boolean
  (lambda (proc)
    (display (to-boolean proc))))

(define analyze
  (lambda (x)
    (cond [(pair? x)
	   (record-case
	    x
	    [Tag (k v) (Tag k (pre-analyze v))]
	    [display (v) (display (analyze v))]
	    [display-integer (v) (display-integer (analyze v))]
	    [display-boolean (v) (display-boolean (analyze v))]
	    [eval (v) (lambda-eval v)]
	    [else (display "syntax error!\n")])]
	  [else (display "syntax error!\n")])))

;;读取文件
(define (read-file filename)
  (with-input-from-file filename
    (lambda ()
      (let loop ((ls '())
		 (s (read)))
	(if (eof-object? s)
	    (reverse ls)
	    (loop (cons s ls) (read)))))))

(define (eval-file filename)
  (define (loop line)
    (if (null? (cdr line))
	(analyze (car line))
	(begin (analyze (car line))
	       (loop (cdr line)))))
  (loop (read-file filename)))

(eval-file "../example/example.ss")


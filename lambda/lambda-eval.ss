(load "set.ss")
(load "utils.ss")
(load "env.ss")
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

;;对Tag定义的缩写进行替换
(define pre-analyze
  (lambda (x)
    (cond [(pair? x)
	   (record-case
	    x
	    [lambda (var body)
	      `(lambda ,(pre-analyze var) ,(pre-analyze body))]
	    [else
	     `(,(pre-analyze (car x)) ,(pre-analyze (cadr x)))])]
	  [else (find-tag x)])))

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


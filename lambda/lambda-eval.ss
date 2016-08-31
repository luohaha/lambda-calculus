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
    (beta-analyze (alpha-analyze (pre-analyze x)))))

;;beta规约中的替换
(define beta-replace
  (lambda (exp old new)
    (cond [(pair? exp)
	   (record-case
	    exp
	    [lambda (var body) `(lambda ,var ,(beta-replace body old new))]
	    [else `(,(beta-replace (car exp) old new) ,(beta-replace (cadr exp) old new))])]
	  [else (if (eq? exp old)
		    new
		    exp)])))

;;beta规约
(define beta-analyze
  (lambda (exp)
    ;(debug-line exp)
    (cond [(pair? exp)
	   (record-case
	    exp
	    [lambda (var body) `(lambda ,var ,(beta-analyze body))]
	    [else
	     (let ([left (beta-analyze (car exp))]
		   [right (cadr exp)])
	       (if (and (pair? left)
			(eq? 'lambda (car left)))
		   (beta-analyze (beta-replace (caddr left) (cadr left) right))
		   `(,left ,(beta-analyze right))))])]
	  [else exp])))

(define alpha-count 0)

(define alpha-replace
  (lambda (exp new old)
    (cond [(pair? exp)
	   (record-case
	    exp
	    [lambda (var body)
	      (if (eq? var old)
		  `(lambda ,var ,body)
		  `(lambda ,var ,(alpha-replace body new old)))]
	    [else `(,(alpha-replace (car exp) new old)
		    ,(alpha-replace (cadr exp) new old))])]
	  [else (if (eq? exp old)
		    new
		    exp)])))

(define alpha-new-var
  (lambda (var)
    (set! alpha-count (+ 1 alpha-count))
    (string->symbol (string-append (symbol->string var)
				   (number->string alpha-count)))))

;;alpha规约
(define alpha-analyze
  (lambda (exp)
    (cond [(pair? exp)
	   (record-case
	    exp
	    [lambda (var body)
	      (if (set-member? var alpha-set)
		  (let ([new-var (alpha-new-var var)])
		    (set! alpha-set (set-cons new-var alpha-set))
		    `(lambda ,new-var ,(alpha-analyze (alpha-replace body new-var var))))
		  (begin (set! alpha-set (set-cons var alpha-set))
			 `(lambda ,var ,(alpha-analyze body))))]
	    [else `(,(alpha-analyze (car exp)) ,(alpha-analyze (cadr exp)))])]
	  [else exp])))

;;将丘奇编码转化为数字
(define to-integer
  (lambda (proc)
    (((eval (lambda-change proc)) (lambda (x) (+ x 1))) 0)))

(define display-integer
   (lambda (proc)
    (display (to-integer proc))
    (newline)))

;;将丘奇编码转化为boolean
(define to-boolean
  (lambda (proc)
    (((eval (lambda-change proc)) #t) #f)))

(define display-boolean
  (lambda (proc)
    (display (to-boolean proc))
    (newline)))

(define analyze
  (lambda (x)
    (cond [(pair? x)
	   (record-case
	    x
	    [Tag (k v) (Tag k (pre-analyze v))]
	    [display (v) (display (analyze v)) (newline)]
	    [display-integer (v) (display-integer (analyze v))]
	    [display-boolean (v) (display-boolean (analyze v))]
	    [else (lambda-eval x)])]
	  [else (lambda-eval x)])))

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


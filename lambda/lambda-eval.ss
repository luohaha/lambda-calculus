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
    (beta-analyze-loop (pre-analyze x))))

(define beta-analyze-loop
  (lambda (exp)
    (debug-line exp)
    (cond [(pair? exp)
	   (record-case
	    exp
	    [lambda (var body) `(lambda ,var ,(beta-analyze-loop body))]
	    [else (let ([left (beta-analyze (car exp))]
			[right (beta-analyze (cadr exp))])
		    (if (and (pair? left)
			     (eq? 'lambda (car left)))
			(beta-analyze-loop (beta-analyze `(,left ,right)))
			`(,left ,(beta-analyze-loop right))))])]
	  [else exp])))

(define deep-analyze
  (lambda (exp bound exchan)
    (cond [(pair? exp)
	   (record-case
	    exp
	    [lambda (var body) `(lambda ,var ,(deep-analyze body
							    (set-cons var bound)
							    exchan))]
	    [else
	     (let ([left (deep-analyze (car exp) bound exchan)]
		   [right (deep-analyze (cadr exp) bound exchan)])
	       `(,left ,right))])]
	  [else (if (set-member? exp bound)
		    exp
		    (if (eq? (car exchan) exp)
			(cdr exchan)
			(begin (display "lambda syntax error ")
			       (display exchan)
			       (newline)
			       exp)))])))
;;beta规约
(define beta-analyze
  (lambda (exp)
    ;(debug-line exp)
    (cond [(pair? exp)
	   (record-case
	    exp
	    [lambda (var body) `(lambda ,var ,body)]
	    [else
	     (let ([left (beta-analyze (car exp))]
		   [right (beta-analyze (cadr exp))])
	       (if (and (pair? left)
			(eq? 'lambda (car left)))
		   (deep-analyze (caddr left) '() (cons (cadr left) right))
		   `(,left ,right)))])]
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


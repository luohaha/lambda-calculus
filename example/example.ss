
;;integer
(Tag 0 (lambda p (lambda x x)))
(Tag 1 (lambda p (lambda x (p x))))
(Tag 2 (lambda p (lambda x (p (p x)))))
(Tag 3 (lambda p (lambda x (p (p (p x))))))

;;boolean
(Tag true (lambda x (lambda y x)))
(Tag false (lambda x (lambda y y)))

;;condition
(Tag if (lambda x x))
(Tag zero? (lambda x ((x (lambda y false)) true)))

;;data structure
(Tag cons (lambda x (lambda y (lambda f ((f x) y)))))
(Tag car (lambda f (f (lambda x (lambda y x)))))
(Tag cdr (lambda f (f (lambda x (lambda y y)))))

;;computer
(Tag increment (lambda n1 (lambda p (lambda x (p ((n1 p) x))))))

;(display-integer (eval (increment 2)))

(display-integer (eval (((if (zero? (increment 0))) (car ((cons (increment 3)) 1))) (increment 0))))




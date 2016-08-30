
;;Y combination
(Tag Y (lambda f ((lambda x (f (x x))) (lambda x (f (x x))))))
(Tag Z (lambda f ((lambda x (f (lambda y ((x x) y))))
		  (lambda x (f (lambda y ((x x) y)))))))
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
(Tag slide (lambda p ((cons (cdr p)) (increment (cdr p)))))
(Tag decrement (lambda n (car ((n slide) ((cons 0) 0)))))
(Tag + (lambda x (lambda y ((y increment) x))))
(Tag - (lambda m (lambda n ((n decrement) m))))
(Tag * (lambda m (lambda n ((n (+ m)) 0))))
(Tag pow (lambda m (lambda n ((n (* m)) 1))))
(Tag >= (lambda m (lambda n (zero? ((- n) m)))))
(Tag <= (lambda m (lambda n (zero? ((- m) n)))))
(Tag and (lambda m (lambda n ((m n) false))))
(Tag or (lambda m (lambda n ((m true) n))))
(Tag not (lambda m ((m false) true)))
(Tag test (lambda f (lambda n (((if (zero? n)) 0) (lambda x ((f (decrement n)) x))))))
(Tag mod (Z (lambda f (lambda m (lambda n (((if ((<= n) m))
					    (lambda x (((f ((- m) n)) n) x)))
					   m))))))

(display ((+ 3) 3))




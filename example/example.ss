
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
(Tag if (lambda f (lambda x (lambda y ((f x) y)))))
(Tag zero? (lambda x ((x (lambda y false)) true)))

;;data structure
(Tag cons (lambda x (lambda y (lambda f ((f x) y)))))
(Tag car (lambda f (f (lambda x (lambda y x)))))
(Tag cdr (lambda f (f (lambda x (lambda y y)))))

;;computer
(Tag increment (lambda n (lambda p (lambda x (p ((n p) x))))))
(Tag slide (lambda p ((cons (cdr p)) (increment (cdr p)))))
(Tag decrement (lambda n (lambda f (lambda x (((n (lambda g (lambda h (h (g f))))) (lambda u x)) (lambda u u))))))
(Tag + (lambda x (lambda y ((y increment) x))))
(Tag - (lambda m (lambda n ((n decrement) m))))
(Tag * (lambda m (lambda n (lambda f (m (n f))))))
(Tag pow (lambda m (lambda n ((n (* m)) 1))))
(Tag >= (lambda m (lambda n (zero? ((- n) m)))))
(Tag <= (lambda m (lambda n (zero? ((- m) n)))))
(Tag and (lambda m (lambda n ((m n) false))))
(Tag or (lambda m (lambda n ((m true) n))))
(Tag not (lambda m ((m false) true)))

(Tag mod (Z (lambda f (lambda m (lambda n (((if ((<= n) m))
					    (lambda x (((f ((- m) n)) n) x)))
					   m))))))
(Tag test (lambda f (lambda n (((if (zero? n)) 1) ((* n) (f (decrement n)))))))

(Tag test2 (Z (lambda f (lambda n (((if (zero? n)) 1) (lambda x (((* n) (f (decrement n))) x)))))))

(display ((pow (car ((cons 2) 3))) 3))
;(display ((test (Y test)) 1))
;(display (test2 1))

;(display "==============\n")
;(display Y)


;(display ((mod 4) 3))











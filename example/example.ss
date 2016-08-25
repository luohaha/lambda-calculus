
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

;;(display (pre-analyze '(((if true) 1) 2)))

(display-boolean (eval (((if false) true) false)))



# lambda-calculus

This is a lambda calculus interpreter.

## Usage

```
cd lambda/
./run [filename]
```
> Need chezscheme

## Grammar

```
<expression> ::= <id>
<expression> ::= (lambda <id> <expression>)
<expression> ::= (<expression> <expression>)
```

## 辅助函数

```scheme
(Tag <id> <expression>)
```
> id为expression的缩写。

```scheme
(display <expression>)
```
> 打印规约之后的结果。

```scheme
(display-integer <expression>)
```
> 打印规约之后结果的整数值。

```scheme
(display-boolean <expression>)
```
> 打印规约之后结果的布尔值。

## 例子

```scheme
;;Y combination
(Tag Y (lambda f ((lambda x (f (x x))) (lambda x (f (x x))))))
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

;;operator
(Tag increment (lambda n (lambda p (lambda x (p ((n p) x))))))
(Tag decrement (lambda n (lambda f (lambda x (((n (lambda g (lambda h (h (g f))))) (lambda u x)) (lambda u u))))))
(Tag + (lambda m (lambda n (lambda f (lambda x ((m f) ((n f) x)))))))
(Tag - (lambda m (lambda n ((n decrement) m))))
(Tag * (lambda m (lambda n (lambda f (m (n f))))))
(Tag pow (lambda m (lambda n ((n (* m)) 1))))
(Tag >= (lambda m (lambda n (zero? ((- n) m)))))
(Tag <= (lambda m (lambda n (zero? ((- m) n)))))
(Tag and (lambda m (lambda n ((m n) false))))
(Tag or (lambda m (lambda n ((m true) n))))
(Tag not (lambda m ((m false) true)))

(Tag mod (lambda f (lambda m (lambda n (((if ((<= n) m))
					 ((f ((- m) n)) n))
					m)))))
(Tag add-list (lambda f (lambda n (((if (zero? n)) 0) ((+ (f (decrement n))) n)))))

;;求规约之后的结果
(display ((pow 3) (cdr ((cons 2) 3))))
;; => (lambda f (lambda x4 (f (f (f (f (f (f (f (f (f (f (f (f (f (f (f (f (f (f (f (f (f (f (f (f (f (f (f x4)))))))))))))))))))))))))))))

;;求规约之后的结果，转化为integer
(display-integer ((add-list (Y add-list)) (increment 3)))
;; => 10

;;求规约后的结果
(display (((mod (Y mod)) (increment (increment 3))) 3))
;; => (lambda f1793 (lambda x1894 (f1793 (f1793 x1894))))

;;求规约之后的结果，转化为boolean
(display-boolean (((if ((and true) true)) ((or false) false)) true))
;; => #f
```
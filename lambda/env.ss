(define tags (make-eq-hashtable 32))

(define Tag
  (lambda (k v)
    (hashtable-set! tags k v)))

(define find-tag
  (lambda (k)
    (hashtable-ref tags k k)))

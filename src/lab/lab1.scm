(define (my-even n)
  (= 0 (remainder n 2)))

(define (my-odd n)
  (= 1 (remainder n 2)))

(display (my-odd 5))
(display (my-odd 6))
(display (my-even 5))
(display (my-even 6))

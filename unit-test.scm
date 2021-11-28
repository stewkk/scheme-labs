(define-syntax test
  (syntax-rules ()
    ((test expr res)
     `(expr res))))

(define (run-test test)
  (let ((expr (car test))
        (res_exp (cadr test)))
    (begin
      (write expr)
      (let* ((res_got (eval expr (interaction-environment)))
             (is_passed (equal? res_exp res_got)))
        (begin (if is_passed
                   (display " ok\n")
                   (begin (display " FAIL\n")
                          (display "  Expected: ")
                          (write res_exp)
                          (display "\n  Got: ")
                          (write res_got)
                          (newline)))
               is_passed)))))

(define (run-tests tests)
  (let loop ((res #t)
             (counter 1)
             (tests tests))
    (if (null? tests)
        res
        (begin (display "Test ")
               (display counter)
               (display ": ")
               (loop (and (run-test (car tests)) res)
                     (+ 1 counter)
                     (cdr tests))))))

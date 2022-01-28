(define-syntax trace-ex
  (syntax-rules ()
    ((trace-ex expr)
     (begin
       (write 'expr)
       (let ((res expr))
         (begin
           (display " => ")
           (write res)
           (newline)
           res))))))

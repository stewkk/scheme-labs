
(define (derivative expr)
  (cond ((not (list? expr)) (cond
                             ((number? expr) 0)
                             ((symbol? expr) 1)))
        ((null? (cdr expr)) (derivative (car expr)))
        ((and (symbol? (cadr expr)) (equal? '- (car expr))) -1)
        ((equal? '+ (car expr)) `(+ ,@(map derivative (cdr expr))))
        ((equal? '- (car expr)) `(- ,@(map derivative (cdr expr))))
        ((equal? '* (car expr))
         (if (null? (cddr expr))
             (derivative (cadr expr))
             (let ((u (cadr expr))
                   (v (if (null? (cdddr expr))
                          (caddr expr)
                          (cons '* (cddr expr)))))
               `(+ (* ,(derivative u) ,v)
                   (* ,u ,(derivative v))))))
        ((equal? '/ (car expr))
         (let ((numerator (cadr expr))
               (denominator (caddr expr)))
           `(/ (- (* ,(derivative numerator) ,denominator)
                  (* ,(derivative denominator) ,numerator))
               (* ,denominator ,denominator))))
        ((equal? 'expt (car expr))
         (let ((base (cadr expr))
               (exponent (caddr expr)))
           (if (symbol? base)
               `(* ,exponent (expt ,base (- ,exponent 1)))
               `(* ,expr (log ,base) ,(derivative exponent)))))
        ((equal? 'exp (car expr))
         (let ((d (cadr expr)))
           `(* (exp ,d) ,(derivative d))))
        ((equal? 'cos (car expr)) `(* (- (sin ,(cadr expr))) ,(derivative (cadr expr))))
        ((equal? 'sin (car expr)) `(* (cos ,(cadr expr)) ,(derivative (cadr expr))))
        ((equal? 'log (car expr)) `(/ ,(derivative (cadr expr)) ,(cadr expr)))
        (else expr)))

(define (simplify expr)
  (cond ((not (list? expr))
         expr)
        ((equal? '+ (car expr))
         (let loop ((expr (cdr expr))
                    (res '()))
           (if (null? expr)
               (cond ((null? res)
                      0)
                     ((null? (cdr res))
                      (car res))
                     (else (cons '+ (reverse res))))
               (let ((cur (simplify (car expr))))
                 (if (equal? cur 0)
                     (loop (cdr expr) res)
                     (loop (cdr expr) (cons cur res)))))))
        ((equal? '* (car expr))
         (let loop ((expr (cdr expr))
                    (res '()))
           (if (null? expr)
               (cond ((null? res)
                      1)
                     ((null? (cdr res))
                      (car res))
                     (else (cons '* (reverse res))))
               (let ((cur (simplify (car expr))))
                 (cond ((equal? cur 0)
                        0)
                       ((equal? cur 1)
                        (loop (cdr expr) res))
                       (else (loop (cdr expr) (cons cur res))))))))
        (else (let loop ((expr expr)
                         (res '()))
                (if (null? expr)
                    (reverse res)
                    (loop (cdr expr) (cons (simplify (car expr)) res)))))))

(define-syntax extract
  (syntax-rules ()
    ((extract (first . others))
     (let ((extract-first (extract first))
           (extract-others (extract others)))
       (cond ((and (symbol? 'first) (not (procedure? first))) first)
             ((not (equal? 'none extract-first)) extract-first)
             ((not (equal? 'none extract-others)) extract-others)
             (else 0))))
    ((extract x)
     'none)))

(define-syntax mderivative
  (syntax-rules ()
    ((mderivative expr)
     (eval `(let ((x ',(extract expr)))
              ,(derivative 'expr))
           (interaction-environment)))))

(define-syntax flatten
  (syntax-rules ()
    ((_ done ... ((nested ...) todo ...))
     (flatten done ... (nested ... todo ...)))
    ((_ done ... (first others ...))
     (flatten done ... first (others ...)))
    ((_ done ... ())
     (done ...))))


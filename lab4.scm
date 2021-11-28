(define (exit) (display "please call (use-assertions) before using (assert ...)"))

(define-syntax use-assertions
  (syntax-rules ()
    ((use-assertions)
     (call-with-current-continuation
       (lambda (cont)
         (set! exit cont))))))

(define-syntax assert
  (syntax-rules ()
    ((assert expr)
     (if (not expr)
         (begin
           (display "FAILED: ")
           (write 'expr)
           (newline)
           (exit))))))

(define (1/x x)
  (assert (not (zero? x))) ; Утверждение: x ДОЛЖЕН БЫТЬ ≠ 0
  (/ 1 x))

(use-assertions)

(map 1/x '(1 2 3 4 5)) ; ВЕРНЕТ список значений в программу

(map 1/x '(-2 -1 0 1 2)) ; ВЫВЕДЕТ в консоль сообщение и завершит работу программы

(define (save-data data path)
(with-output-to-file path (lambda ()
                            (write data))))

(define (load-data path)
(with-input-from-file path (lambda ()
                            (read))))

(define (file-nonempty-lines-count path)
  (with-input-from-file path (lambda ()
                               (let loop ((prev #\newline)
                                          (k 0))
                                 (let ((cur (read-char)))
                                   (if (eof-object? cur)
                                       (if (equal? #\newline prev)
                                           k
                                           (+ k 1))
                                       (if (and (equal? #\newline cur)
                                                (not (equal? #\newline prev)))
                                           (loop cur (+ k 1))
                                           (loop cur k))))))))

(display (file-nonempty-lines-count "./lab4.org"))

(define (tribonacci n)
  (cond ((= n 0) 0)
        ((<= n 2) 1)
        (else (let loop ((n (- n 2))
                         (first 0)
                         (second 1)
                         (third 1))
                (if (= n 0)
                    third
                    (loop (- n 1) second third (+ first second third)))))))

(load "./unit-test.scm")

(define tests
  (list (test (tribonacci 0) 0)
        (test (tribonacci 1) 1)
        (test (tribonacci 2) 1)
        (test (tribonacci 3) 2)
        (test (tribonacci 4) 4)
        (test (tribonacci 4) 4)
        (test (tribonacci 5) 7)))

(run-tests tests)
(use-modules (ice-9 time))
(time (tribonacci 9000))
(time (tribonacci 90000))
(time (tribonacci 90050))

(define tribonacci-memo
  (let ((known-results '()))
    (lambda (n)
      (let* ((args n)
             (res (assoc args known-results)))
        (if res
            (cadr res)
            (let ((res (cond ((= n 0) 0)
                             ((<= n 2) 1)
                             (else (+ (tribonacci-memo (- n 3))
                                      (tribonacci-memo (- n 2))
                                      (tribonacci-memo (- n 1)))))))
              (set! known-results (cons (list args res) known-results))
              res))))))

(load "./unit-test.scm")

(define tests
  (list (test (tribonacci-memo 0) 0)
        (test (tribonacci-memo 1) 1)
        (test (tribonacci-memo 2) 1)
        (test (tribonacci-memo 3) 2)
        (test (tribonacci-memo 4) 4)
        (test (tribonacci-memo 4) 4)
        (test (tribonacci-memo 5) 7)))

(run-tests tests)
(use-modules (ice-9 time))
(time (tribonacci-memo 9000))
(time (tribonacci-memo 90000))
(time (tribonacci-memo 90050))

(define-syntax my-if
  (syntax-rules ()
    ((my-if condition statement1 statement2)
     (let ((promise1 (delay statement1))
           (promise2 (delay statement2)))
       (force (or (and condition promise1) promise2))))))

(load "./unit-test.scm")
(define tests
  (list (test (my-if #t 1 (/ 1 0)) 1)
        (test (my-if #f (/ 1 0) 1) 1)
        (test (my-if (= (+ 1 1) 2) 2 (/ 1 0)) 2)))
(run-tests tests)

(define-syntax my-let
  (syntax-rules ()
    ((my-let ()
             expr)
     expr)
    ((my-let ((var1 expr1) (varn exprn) ...)
             expr)
     ((lambda (var1)
        (my-let ((varn exprn) ...)
                expr))
      expr1))))

(define-syntax my-let
  (syntax-rules ()
    ((my-let ((var val) ...)
             expr)
     ((lambda (var ...)
        expr)
      val ...))))

(define-syntax my-let*
  (syntax-rules ()
    ((my-let* ()
             expr)
     expr)
    ((my-let* ((var1 expr1) (varn exprn) ...)
             expr)
     ((lambda (var1)
        (my-let* ((varn exprn) ...)
                expr))
      expr1))))

(define tests
  (list
   (test (my-let ((x 5) (y 7))
                 (+ x 1 y))
         13)
   (test (my-let ((=> #f))
           (cond (#t => 'ok)))
         ok)))

(run-tests tests)

(define tests
  (list
   (test (my-let* ((x 5) (y (+ x 7)))
                  y) 12)))

(run-tests tests)

(define-syntax when
  (syntax-rules ()
    ((when test expr ...)
     (if test
         (begin expr ...)))))

(define-syntax unless
  (syntax-rules ()
    ((unless test expr ...)
     (if (not test)
         (begin expr ...)))))

(define x 1)
(when   (> x 0) (display "x > 0")  (newline))
(unless (= x 0) (display "x != 0") (newline))

(define-syntax for
  (syntax-rules (in as)
    ((for x in xs expr ...)
     (let loop ((values xs))
       (if (not (null? values))
           (let ((x (car values)))
             (begin expr ...)
             (loop (cdr values))))))
    ((for xs as x expr ...)
     (for x in xs expr ...))))

(for i in '(1 2 3)
(for j in '(4 5 6)
    (display (list i j))
    (newline)))

(for '(1 2 3) as i
(for '(4 5 6) as j
    (display (list i j))
    (newline)))

(define-syntax while
  (syntax-rules ()
    ((while cond? expr ...)
     (let loop ()
       (if cond?
           (begin expr ...
                  (loop)))))))

(let ((p 0)
      (q 0))
  (while (< p 3)
    (set! q 0)
    (while (< q 3)
      (display (list p q))
      (newline)
      (set! q (+ q 1)))
    (set! p (+ p 1))))

(define-syntax repeat
  (syntax-rules (until)
    ((repeat (expr ...) until cond?)
     (let loop ()
       (begin expr ...
              (if (not cond?) (loop)))))))

(let ((i 0)
      (j 0))
  (repeat ((set! j 0)
           (repeat ((display (list i j))
                    (set! j (+ j 1)))
                   until (= j 3))
           (set! i (+ i 1))
           (newline))
          until (= i 3)))

(define-syntax repeat
  (syntax-rules (until)
    ((repeat expr ... until cond?)
     (let loop ()
       (begin expr ...
              (if (not cond?) (loop)))))))

(let ((i 0)
      (j 0))
  (repeat (set! j 0)
           (repeat (display (list i j))
                    (set! j (+ j 1))
                   until (= j 3))
           (set! i (+ i 1))
           (newline)
          until (= i 3)))

(define-syntax cout
  (syntax-rules (<< endl)
    ((cout << endl)
     (newline))
    ((cout << elem)
     (display elem))
    ((cout << endl others ...)
     (begin (newline)
            (cout others ...)))
    ((cout << elem others ...)
     (begin (display elem)
            (cout others ...)))))

(cout << "a = " << 1 << endl << "b = " << 2 << endl)

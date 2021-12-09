(define memoized-factorial
  (let ((known-results '()))
    (lambda (n)
      (cond ((= n 0) 1)
            ((assoc n known-results) -> (lambda (res) res))
            (else (let ((res (* n (memoized-factorial (- n 1)))))
                    (begin (cons '(n res) known-results)
                           res)))))))

(begin
  (display (memoized-factorial 10)) (newline)
  (display (memoized-factorial 20)) (newline)
  (display (memoized-factorial 50)) (newline))

(define-syntax lazy-cons
  (syntax-rules ()
    ((lazy-cons a b)
     (delay (cons a b)))))

(define (lazy-car p)
  (car (force p)))

(define (lazy-cdr p)
  (cdr (force p)))

(define (lazy-head xs k)
  (let loop ((xs xs) (k k) (res '()))
    (if (= k 0)
        (reverse res)
        (loop (lazy-cdr xs) (- k 1) (cons (lazy-car xs) res)))))

(define (lazy-ref xs k)
  (let loop ((xs xs) (k k))
    (if (= k 0)
        (lazy-car xs)
        (loop (lazy-cdr xs) (- k 1)))))

(define (naturals start)
  (lazy-cons start (naturals (+ start 1))))

(display (lazy-head (naturals 10) 12))

(define (factorials start val)
  (lazy-cons val (factorials (+ start 1) (* val (+ start 1)))))

(define (lazy-factorial n)
  (lazy-ref (factorials 0 1) n))

(begin
  (display (lazy-factorial 10)) (newline)
  (display (lazy-factorial 50)) (newline)
  (display (lazy-factorial  1)) (newline)
  (display (lazy-factorial  2)) (newline)
  (display (lazy-factorial  0)) (newline))

(define (read-words)
  (let loop ((res '())
             (word '()))
    (let ((cur (read-char)))
      (cond ((eof-object? cur)
             (reverse res))
            ((char-whitespace? cur)
             (if (null? word)
                 (loop res word)
                 (loop (cons (list->string (reverse word)) res)
                       '())))
            (else (loop res (cons cur word)))))))

(with-output-to-file "home4.test" (lambda ()
                                   (display "  one two three\n four five  six  \n")))
(with-input-from-file "home4.test" (lambda ()
                                    (write (read-words))))

(define-syntax define-struct
  (syntax-rules ()
    ((_ sym-name sym-fields)
     (let loop ((name (symbol->string 'sym-name))
                (fields (map symbol->string 'sym-fields))
                (i 2))
       (if (null? fields)
           (eval `(begin (define (,(string->symbol (string-append "make-"
                                                                  name))
                                  . vals)
                           (list->vector (cons '_struct (cons 'sym-name vals))))
                         (define (,(string->symbol (string-append name
                                                                  "?"))
                                  obj)
                           (and (vector? obj)
                                (eqv? '_struct (vector-ref obj 0))
                                (eqv? 'sym-name (vector-ref obj 1)))))
                 (interaction-environment))
           (begin (eval `(begin (define (,(string->symbol (string-append name
                                                                         "-"
                                                                         (car fields)))
                                         obj)
                                  (vector-ref obj ,i))
                                (define (,(string->symbol (string-append "set-"
                                                                         name
                                                                         "-"
                                                                         (car fields)
                                                                         "!"))
                                         obj
                                         val)
                                  (vector-set! obj ,i val)))
                        (interaction-environment))
                  (loop name (cdr fields) (+ i 1))))))))

(load "./unit-test.scm")

(define-struct pos (row col)) ; Объявление типа pos
(define p (make-pos 1 2))     ; Создание значения типа pos

(define struct-tests
  (list (test (pos? p) #t)
        (test (pos-row p) 1)
        (test (pos-col p) 2)
        (test (begin
                (set-pos-row! p 3)
                (set-pos-col! p 4)
                (pos-row p))
              3)
        (test (pos-col p) 4)))

(run-tests struct-tests)

(define-syntax define-data
  (syntax-rules ()
    ((_ name _constructors)
     (let loop ((constructors '_constructors))
       (if (null? constructors)
           ;; определим предикат
           (eval `(define (,(string->symbol (string-append (symbol->string 'name)
                                                           "?"))
                           obj)
                    (and (list? obj)
                         (eqv? '_data (car obj))
                         (eqv? 'name (cadr obj))))
                 (interaction-environment))
           ;; определим конструктор
           (begin (eval `(define (,(caar constructors)
                                  . params)
                           (append (list '_data
                                         'name
                                         ',(caar constructors))
                                   params))
                        (interaction-environment))
                  (loop (cdr constructors))))))))

(define-syntax match
  (syntax-rules ()
    ((_ val ((name params ...) expr))
     (apply (lambda (params ...)
              expr)
            (cdddr val)))
    ((_ val ((name params ...) expr) patterns ...)
     (if (eqv? 'name (caddr val))
         (apply (lambda (params ...)
                  expr)
                (cdddr val))
         (match val patterns ...)))))

;; Определяем тип
(define-data figure ((square a)
                     (rectangle a b)
                     (triangle a b c)
                     (circle r)))

;; Определяем значения типа
(define s (square 10))
(define r (rectangle 10 20))
(define t (triangle 10 20 30))
(define c (circle 10))

(display (and (figure? s)
              (figure? r)
              (figure? t)
              (figure? c)))
(newline)

(define pi (acos -1)) ;; Для окружности

(define (perim f)
  (match f
         ((square a)       (* 4 a))
         ((rectangle a b)  (* 2 (+ a b)))
         ((triangle a b c) (+ a b c))
         ((circle r)       (* 2 pi r))))

(display (perim s))
(newline)
(display (perim r))
(newline)
(display (perim t))
(newline)
(display (perim c))
(newline)

(define-syntax my-let
  (syntax-rules ()
    ((_ ((var val)) expr)
     ((lambda (var)
        expr) val))
    ((_ ((var val) . others) expr)
     ((lambda (var)
        (my-let others
                 expr)) val))))

(define-syntax my-let*
  (syntax-rules ()
    ((_ ((var val)) expr)
     ((lambda (var)
        expr) val))
    ((_ ((var val) . others) expr)
     ((lambda (var)
        (my-let* others
                 expr)) val))))

(load "./unit-test.scm")

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

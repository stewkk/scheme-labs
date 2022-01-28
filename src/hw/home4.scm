
(define memoized-factorial
  (let ((known-results '()))
    (lambda (n)
      (cond ((= n 0) 1)
            ((assoc n known-results) -> (lambda (res) res))
            (else (let ((res (* n (memoized-factorial (- n 1)))))
                    (begin (cons '(n res) known-results)
                           res)))))))

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

(define (factorials start val)
  (lazy-cons val (factorials (+ start 1) (* val (+ start 1)))))

(define (lazy-factorial n)
  (lazy-ref (factorials 0 1) n))

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
                                (> (vector-length obj) 2)
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
                         (not (null? obj))
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


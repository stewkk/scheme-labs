
(define-syntax use-assertions
  (syntax-rules ()
    ((use-assertions)
     (eval `(define exit
              (call-with-current-continuation
               (lambda (cont)
                 cont)))
           (interaction-environment)))))

(define-syntax assert
  (syntax-rules ()
    ((assert expr)
     (if (not expr)
         (begin
           (display "FAILED: ")
           (write 'expr)
           (exit 1))))))


;; (use-assertions) ; Инициализация вашего каркаса перед использованием

; Определение процедуры, требующей верификации переданного ей значения:

(define (1/x x)
  (assert (not (zero? x))) ; Утверждение: x ДОЛЖЕН БЫТЬ ≠ 0
  (/ 1 x))

; Применение процедуры с утверждением:

;; (map 1/x '(1 2 3 4 5)) ; ВЕРНЕТ список значений в программу

(map 1/x '(-2 -1 0 1 2)) ; ВЫВЕДЕТ в консоль сообщение и завершит работу программы


;; 2
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

(display (file-nonempty-lines-count "./lab4.scm"))


;; 3

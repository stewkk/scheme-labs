# Лабораторная работа №3

## Цели работы

-   На практике ознакомиться с системой типов языка Scheme.
-   На практике ознакомиться с юнит-тестированием.
-   Разработать свои средства отладки программ на языке Scheme.
-   На практике ознакомиться со средствами метапрограммирования языка
    Scheme.

## Задания

1.  Реализуйте макрос `trace` для трассировки. Трассировка — способ
    отладки, при котором отслеживаются значения переменных или выражений
    на каждом шаге выполнения программы. Необходимость и вывести
    значение в консоль, и вернуть его в программу нередко требует
    существенной модификации кода, что может стать источником
    дополнительных ошибок. Реализуйте макрос, который позволяет ценой
    небольшой вставки, не нарушающей декларативность кода, выполнить и
    вывод значения в консоль с комментарием в виде текста выражения,
    которое было вычислено, и возврат его значения в программу.

    Код без трассировки:

    ``` scheme
    (define (zip . xss)
      (if (or (null? xss)
              (null? (car xss))) ; Надо отслеживать значение (car xss) здесь...
          '()
          (cons (map car xss)
                (apply zip (map cdr xss))))) ; ...и значение xss здесь.
    ```

    Код с трассировкой:

    ``` scheme
    (load "trace.scm")

    (define (zip . xss)
      (if (or (null? xss)
              (null? (trace-ex (car xss)))) ; Здесь...
          '()
          (cons (map car xss)
                (apply zip (map cdr (trace-ex xss)))))) ; ... и здесь
    ```

    Консоль:

    ``` example
    > (zip '(1 2 3) '(one two three))
    (car xss) => (1 2 3)
    xss => ((1 2 3) (one two three))
    (car xss) => (2 3)
    xss => ((2 3) (two three))
    (car xss) => (3)
    xss => ((3) (three))
    (car xss) => ()
    ((1 one) (2 two) (3 three))
    ```

    Вычисление значения выражения осуществляется после вывода цитаты
    этого выражения в консоль. Таким образом, в случае аварийного
    завершения программы из-за невозможности вычисления значения, вы
    всегда сможете определить, в каком выражении возникает ошибка.

    **Проследите, чтобы выражение вычислялось ровно один раз**, в
    противном случае можно получить неверный результат работы программы.

    В дальнейшем используйте этот макрос при отладке своих программ на
    языке Scheme.

    ``` scheme
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
    ```

2.  Юнит-тестирование — способ проверки корректности отдельных
    относительно независимых частей программы. При таком подходе для
    каждой функции (процедуры) пишется набор тестов — пар "выражение —
    значение, которое должно получиться". Процесс тестирования
    заключается в вычислении выражений тестов и автоматизированном
    сопоставлении результата вычислений с ожидаемым результатом. При
    несовпадении выдается сообщение об ошибках.

    Реализуйте свой каркас для юнит-тестирования. Пусть каркас включает
    следующие компоненты:

    -   Макрос `test` — конструктор теста вида
        `(выражение ожидаемый-результат)`.

    -   Процедуру `run-test`, выполняющую отдельный тест. Если
        вычисленный результат совпадает с ожидаемым, то в консоль
        выводятся выражение и признак того, что тест пройден. В
        противном случае выводится выражение, признак того, что тест не
        пройден, а также ожидаемый и фактический результаты. Функция
        возвращает `#t`, если тест пройден и `#f` в противном случае.
        Вывод цитаты выражения в консоль должен выполняться до
        вычисления его значения, чтобы при аварийном завершении
        программы последним в консоль было бы выведено выражение, в
        котором произошла ошибка.

    -   Процедуру `run-tests`, выполняющую серию тестов, переданную ей в
        виде списка. Эта процедура должна выполнять все тесты в списке и
        возвращает `#t`, если все они были успешными, в противном случае
        процедура возвращает `#f`.

    Какой предикат вы будете использовать для сравнения ожидаемого
    результата с фактическим? Почему?

    Пример:

    ``` scheme
    ; Пример процедуры с ошибкой
    ; 
    (define (signum x)
      (cond
        ((< x 0) -1)
        ((= x 0)  1) ; Ошибка здесь!
        (else     1)))

    ; Загружаем каркас
    ;
    (load "unit-test.scm")

    ; Определяем список тестов
    ;
    (define the-tests
      (list (test (signum -2) -1)
            (test (signum  0)  0)
            (test (signum  2)  1)))

    ; Выполняем тесты
    ;
    (run-tests the-tests)
    ```

    Пример результата в консоли:

    ``` example
    (signum -2) ok
    (signum 0) FAIL
      Expected: 0
      Returned: 1
    (signum 2) ok
    #f
    ```

    Используйте разработанные вами средства отладки для выполнения
    следующих заданий этой лабораторной работы и последующих домашних
    заданий.

    ``` scheme
    (define-syntax test
      (syntax-rules ()
        ((test expr res)
         (list expr res 'expr))))

    (define (run-test test)
      (let ((expr (car test))
            (res_exp (cadr test))
            (expr_literal (caddr test)))
        (begin
          (write expr_literal)
          (let* ((res_got expr)
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
    ```

3.  Реализуйте процедуру доступа к произвольному элементу
    последовательности (правильного списка, вектора или строки) по
    индексу. Пусть процедура возвращает `#f` если получение элемента не
    возможно. Примеры применения процедуры:

    ``` scheme
    (ref '(1 2 3) 1) ⇒ 2
    (ref #(1 2 3) 1) ⇒ 2
    (ref "123" 1)    ⇒ #\2
    (ref "123" 3)    ⇒ #f
    ```

    Реализуйте процедуру "вставки" произвольного элемента в
    последовательность, в позицию с заданным индексом (процедура
    возвращает новую последовательность). Пусть процедура возвращает
    `#f` если вставка не может быть выполнена. Примеры применения
    процедуры:

    ``` scheme
    (ref '(1 2 3) 1 0)   ⇒ (1 0 2 3)
    (ref #(1 2 3) 1 0)   ⇒ #(1 0 2 3)
    (ref #(1 2 3) 1 #\0) ⇒ #(1 #\0 2 3)
    (ref "123" 1 #\0)    ⇒ "1023"
    (ref "123" 1 0)      ⇒ #f
    (ref "123" 3 #\4)    ⇒ "1234"
    (ref "123" 5 #\4)    ⇒ #f
    ```

    Попробуйте предусмотреть все возможные варианты.

    **Примечание.** Результатом выполнения задания должно быть **одно**
    определение процедуры `ref`. Алгоритм её работы должен определяться
    числом аргументов и их типами.

    ``` scheme
    (define (list-insert! list index value)
      `(,@(list-tail (reverse list) (+ index 1)) ,(car value) ,@(list-tail list index)))

    (define (ref object index . value)
      (and (>= index  0)
           (if (null? value)
               (cond ((list? object)
                      (and (< index (length object)) (list-ref object index)))
                     ((string? object)
                      (and (< index (string-length object)) (string-ref object index)))
                     ((vector? object)
                      (and (< index (vector-length object)) (vector-ref object index)))
                     (else #f))
               (cond ((list? object)
                      (and (<= index (length object)) (list-insert! object index value)))
                     ((string? object)
                      (and (<= index (string-length object))
                           (char? (car value))
                           (string-append (substring object 0 index) (string (car value)) (substring object index))))
                     ((vector? object)
                      (and (<= index (vector-length object)) (list->vector (list-insert! (vector->list object) index value))))
                     (else #f)))))

    (define tests
      (list
       (test (ref '(1 2 3) 1)  2)
       (test (ref #(1 2 3) 1)  2)
       (test (ref "123" 1)     #\2)
       (test (ref "123" 3)     #f)
       (test (ref '(1 2 3) 1 0)    (1 0 2 3))
       (test (ref #(1 2 3) 1 0)    #(1 0 2 3))
       (test (ref #(1 2 3) 1 #\0)  #(1 #\0 2 3))
       (test (ref "123" 1 #\0)     "1023")
       (test (ref "123" 1 0)       #f)
       (test (ref "123" 3 #\4)     "1234")
       (test (ref "123" 5 #\4)     #f)
       (test (ref "123" -1)        #f)))

    (run-tests tests)
    (newline)
    ```

4.  Разработайте наборы юнит-тестов и используйте эти тесты для
    разработки процедуры, выполняющей разложение на множители.

    Реализуйте процедуру `factorize`, выполняющую разложение многочленов
    вида a2−b2, a3−b3 и a3+b3 по формулам.

    Пусть процедура принимает единственный аргумент — выражение на языке
    Scheme, которое следует разложить на множители, и возвращает
    преобразованное выражение. Возведение в степень в исходных
    выражениях пусть будет реализовано с помощью встроенной процедуры
    expt. Получаемое выражение должно быть пригодно для выполнения в
    среде интерпретатора с помощью встроенной процедуры eval. Упрощение
    выражений не требуется.

    Примеры вызова процедуры:

    ``` example
    (factorize '(- (expt x 2) (expt y 2))) 
      ⇒ (* (- x y) (+ x y))

    (factorize '(- (expt (+ first 1) 2) (expt (- second 1) 2)))
      ⇒ (* (- (+ first 1) (- second 1))
             (+ (+ first 1) (- second 1)))

    (eval (list (list 'lambda 
                          '(x y) 
                          (factorize '(- (expt x 2) (expt y 2))))
                    1 2)
              (interaction-environment))
      ⇒ -3
    ```

    ``` scheme
    (define (factorize polynom)
      (let ((is_+ (equal? '+ (car polynom)))
            (is_expt2 (= 2 (car (reverse (cadr polynom)))))
            (a (cadadr polynom))
            (b (car (cdaddr polynom))))
        (cond ((and (not is_+) is_expt2)
               `(* (- ,a ,b) (+ ,a ,b)))
              ((and is_+ (not is_expt2))
               `(* (+ ,a ,b) (+ (expt ,a 2) (- (* ,a ,b)) (expt ,b 2))))
              ((and (not is_+) (not is_expt2))
               `(* (- ,a ,b) (+ (expt ,a 2) (* ,a ,b) (expt ,b 2)))))))

    (define factorize-tests
      (list
       (test (factorize '(- (expt x 2) (expt y 2))) (* (- x y) (+ x y)))
       (test (factorize '(- (expt (+ first 1) 2) (expt (- second 1) 2)))
             (* (- (+ first 1) (- second 1))
                (+ (+ first 1) (- second 1))))
       (test (eval (list (list 'lambda
                               '(x y)
                               (factorize '(- (expt x 2) (expt y 2))))
                         1 2)
                   (interaction-environment))
             -3)
       (test (eval (list (list 'lambda
                               '(x y)
                               (factorize '(- (expt x 3) (expt y 3))))
                         1 2)
                   (interaction-environment))
             -7)
       (test (eval (list (list 'lambda
                               '(x y)
                               (factorize '(+ (expt x 3) (expt y 3))))
                         2 1)
                   (interaction-environment))
             9)))

    (run-tests factorize-tests)
    (newline)
    ```

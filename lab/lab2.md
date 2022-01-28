# Лабораторная работа №2. Рекурсия, процедуры высшего порядка, обработка

списков

## Цель работы

Приобретение навыков работы с основами программирования на языке Scheme:
использование рекурсии, процедур высшего порядка, списков.

## Задания

При выполнении заданий **не используйте** присваивание, циклы и
обращение к элементам последовательности по индексу. Избегайте возврата
логических значений из условных конструкций. Продемонстрируйте
работоспособность процедур на примерах.

1.  Реализуйте процедуру `(count x xs)`, подсчитывающую, сколько раз
    встречается элемент `x` в списке `xs`. Примеры применения процедуры:

    ``` example
    (count 'a '(a b c a)) ⇒ 2
    (count 'b '(a c d))   ⇒ 0
    (count 'a '())        ⇒ 0
    ```

    ``` scheme
    (define (count x xs)
      (if (null? xs)
          0
          (if (equal? x (car xs))
              (+ 1 (count x (cdr xs)))
              (count x (cdr xs)))))


    (display (count 'a '(a b c a)))
    (newline)
    (display (count 'b '(a c d)))
    (newline)
    (display (count 'a '()))
    (newline)
    ```

    ``` example
    2
    0
    0
    ```

2.  Реализуйте процедуру `(delete pred? xs)`, которая "удаляет" из
    списка `xs` все элементы, удовлетворяющие предикату `pred?`. Примеры
    применения процедуры:

    ``` example
    (delete even? '(0 1 2 3)) ⇒ (1 3)
    (delete even? '(0 2 4 6)) ⇒ ()
    (delete even? '(1 3 5 7)) ⇒ (1 3 5 7)
    (delete even? '()) ⇒ ()
    ```

    ``` scheme
    (define (delete pred? xs)
      (if (null? xs)
          '()
          (if (pred? (car xs))
              (delete pred? (cdr xs))
              (cons (car xs) (delete pred? (cdr xs))))))

    (newline)
    (newline)
    (display (delete even? '(0 1 2 3)))
    (newline)
    (display (delete even? '(0 2 4 6)))
    (newline)
    (display (delete even? '(1 3 5 7)))
    (newline)
    (display (delete even? '()))
    (newline)
    ```

    : :

    ``` example
    (1 3)
    ()
    (1 3 5 7)
    ()
    ```

3.  Реализуйте процедуру `(iterate f x n)`, которая возвращает список из
    `n` элементов вида `(x, f(x), f(f(x)), f(f(f(x))), …)`, где `f` —
    процедура (функция) одного аргумента. Примеры применения процедуры:

    ``` example
    (iterate (lambda (x) (* 2 x)) 1 6) ⇒ (1 2 4 8 16 32)
    (iterate (lambda (x) (* 2 x)) 1 1) ⇒ (1)
    (iterate (lambda (x) (* 2 x)) 1 0) ⇒ ()
    ```

    ``` scheme
    (define (iterate f x n)
      (if (= n 0)
          '()
          (iterate-list f (list x) n)))

    (define (iterate-list f x n)
      (if (= n 1)
          x
          (iterate-list f (cons (car x) (map f x)) (- n 1))))

    (newline)
    (newline)
    (display (iterate (lambda (x) (* 2 x)) 1 6))
    (newline)
    (display (iterate (lambda (x) (* 2 x)) 1 1))
    (newline)
    (display (iterate (lambda (x) (* 2 x)) 1 0))
    (newline)
    ```

    : :

    ``` example
    (1 2 4 8 16 32)
    (1)
    ()
    ```

4.  Реализуйте процедуру `(intersperse e xs)`, которая возвращает
    список, полученный путем вставки элемента `е` между элементами
    списка `xs`. Примеры применения процедуры:

    ``` example
    (intersperse 'x '(1 2 3 4)) ⇒ (1 x 2 x 3 x 4)
    (intersperse 'x '(1 2))     ⇒ (1 x 2)
    (intersperse 'x '(1))       ⇒ (1)
    (intersperse 'x '())        ⇒ ()
    ```

    ``` scheme
    (define (intersperse e xs)
      (if (<= (length xs) 1)
          xs
          (cons (car xs) (cons e (intersperse e (cdr xs))))))

    (newline)
    (newline)
    (display (intersperse 'x '(1 2 3 4)))
    (newline)
    (display (intersperse 'x '(1 2)))
    (newline)
    (display (intersperse 'x '(1)))
    (newline)
    (display (intersperse 'x '()))
    (newline)
    ```

    : :

    ``` example
    (1 x 2 x 3 x 4)
    (1 x 2)
    (1)
    ()
    ```

5.  Реализуйте предикаты `(any? pred? xs)`, который возвращает `#t`,
    если хотя бы один из элементов списка `xs` удовлетворяет предуикату
    `pred?`, и `(all? pred? xs)`, который возвращает `#t`, если все
    элементы списка `xs` удовлетворяет предуикату `pred?`. **Не
    используйте** условные конструкции, вместо них используйте
    особенности встроенных `and` и `or`. Примеры применения:

    ``` example
    (any? odd? '(1 3 5 7)) ⇒ #t
    (any? odd? '(0 1 2 3)) ⇒ #t
    (any? odd? '(0 2 4 6)) ⇒ #f
    (any? odd? '()) ⇒ #f

    (all? odd? '(1 3 5 7)) ⇒ #t
    (all? odd? '(0 1 2 3)) ⇒ #f
    (all? odd? '(0 2 4 6)) ⇒ #f
    (all? odd? '()) ⇒ #t ; Это - особенность, реализуйте её
    ```

    ``` scheme
    (define (contains? x xs)
      (and (not (null? xs))
           (or (equal? (car xs) x)
               (contains? x (cdr xs)))))

    (define (any? pred? xs)
      (contains? #t (map pred? xs)))

    (define (all? pred? xs)
      (not (contains? #f (map pred? xs))))

    (newline)
    (newline)
    (display (any? odd? '(1 3 5 7)))
    (newline)
    (display (any? odd? '(0 1 2 3)))
    (newline)
    (display (any? odd? '(0 2 4 6)))
    (newline)
    (display (any? odd? '()))
    (newline)
    (newline)
    (display (all? odd? '(1 3 5 7)))
    (newline)
    (display (all? odd? '(0 1 2 3)))
    (newline)
    (display (all? odd? '(0 2 4 6)))
    (newline)
    (display (all? odd? '()))
    (newline)
    ```

    ``` example

    #t
    #t
    #f
    #f

    #t
    #f
    #f
    #t
    ```

6.  Реализуйте композицию функций (процедур) одного аргумента, для чего
    напишите процедуру `o`, принимающую произвольное число процедур
    одного аргумента и возвращающую процедуру, являющуюся композицией
    этих процедур. Примеры применения процедуры:

    ``` example
    (define (f x) (+ x 2))
    (define (g x) (* x 3))
    (define (h x) (- x))

    ((o f g h) 1) ⇒ -1
    ((o f g) 1)   ⇒ 5
    ((o h) 1)     ⇒ -1
    ((o) 1)       ⇒ 1
    ```

    ``` scheme
    (define (o . fs)
      (if (null? fs)
          (lambda (x) x)
          (lambda (x) ((car fs)
                       ((apply o (cdr fs)) x)))))

    (define (o . fs)
      (lambda (x)
        (if (null? fs)
            x
            ((car fs)
              ((apply o (cdr fs)) x)))))

    (define (f x) (+ x 2))
    (define (g x) (* x 3))
    (define (h x) (- x))

    (newline)
    (newline)
    (display ((o f g h) 1))
    (newline)
    (display ((o f g) 1))
    (newline)
    (display ((o h) 1))
    (newline)
    (display ((o) 1))
    (newline)
    ```

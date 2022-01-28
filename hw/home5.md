# Домашнее задание №5

Нужно дополнить интерпретатор как минимум тремя из описанных ниже
конструкций на выбор студента. За каждое выполненное расширение
(с отдельным подзаголовком) ставится по одному баллу.

Все расширения интерпретатора опциональны. Чтобы тестирующий бот смог
проверить корректность расширения, в исходный текст программы
(в произвольное место, кроме комментария) нужно добавить символ с именем
`feature-***`. Это можно сделать например так:

``` scheme
(define feature-nested-if #t)
```

или так:

``` scheme
'feature-nested-if
```

или даже так:

``` scheme
(define feature-nested-if
  (list (test (interpret #(0 if 1 if 2 endif 3 endif 4) '()) '(4))
        (test (interpret #(1 if 2 if 3 endif 4 endif 5) '()) '(5 4 3))))

(run-tests feature-nested-if)
```

Имена расширений указаны в скобках в подзаголовках.

В комментариях символы `feature-***` будут проигнорированы.

## `if` с альтернативной веткой (`feature-if-else`)

Предлагается добавить ветку `else` к оператору `if`. Примеры:

``` scheme
(interpret #(1 if 100 else 200 endif) '())       →  '(100)
(interpret #(0 if 100 else 200 endif) '())       →  '(200)
```

## Вложенные `if` (`feature-nested-if`)

Внутри оператора `if … endif` допустимы вложенные операторы
`if … endif`. Примеры:

``` scheme
(interpret #(0 if 1 if 2 endif 3 endif 4) '())   →  '(4)
(interpret #(1 if 2 if 3 endif 4 endif 5) '())   →  '(5 4 3)
(interpret #(1 if 0 if 2 endif 3 endif 4) '())   →  '(4 3)
```

## Цикл с предусловием `while … wend` (`feature-while-loop`)

Слово `while` работает аналогично слову `if`:

-   снимается со стека число,
-   если снятое число `0= --- передаёт управление на оператор, следующий
     за =wend`,
-   иначе — передаёт управление внутрь тела цикла.

Слово `wend` передаёт управление на предшествующее слово `while`.

Таким образом, цикл продолжается до тех пор, пока слово `while`
не снимет со стека `0`.

Примеры:

``` scheme
(interpret #(while wend) '(3 7 4 0 5 9))         → '(5 9)

(interpret #(define sum
               dup
               while + swap dup wend
               drop
             end
             1 2 3 0 4 5 6 sum)
           '())                                  → '(15 3 2 1)

(interpret #(define power2
               1 swap dup
               while
                 swap 2 * swap 1 - dup
               wend
               drop
             end
             5 power2 3 power2 power2) '())      → '(256 32)
```

Цикл должен допускать вложение, если реализован вложенный `if`.

## Цикл с постусловием `repeat … until` (`feature-repeat-loop`)

Слово `repeat` ничего не делает.

Слово `until` снимает со стека число. Если оно нулевое, управление
передаётся на предшествующее слово `repeat`, иначе — на следующую
инструкцию.

Таким образом, цикл делает всегда как минимум одну итерацию.

Если реализован вложенный `if`, цикл `repeat … until` также должен
допускать вложение.

## Цикл с параметром `for … next` (`feature-for-loop`)

Цикл `for` в FORTH вызывается, как правило, так:

``` example
for … next : ... ‹от› ‹до›  →  ...
```

Т.е. цикл снимает со стека два числа `‹от›` и =‹до›= и повторяет тело
цикла для всех чисел в диапазоне `‹от›`…=‹до›= включительно, т.е. =‹до›
− ‹от› + 1= раз.

Внутри цикла можно пользоваться словом `i`, которое кладёт на стек
текущее значение счётчика цикла. (Вне цикла результат работы этого слова
не определён.)

Текущее и конечное значение счётчика цикла рекомендуется хранить
на стеке возвратов (см. книжку [Баранова
и Ноздрунова](https://archive.org/details/Baranov.Forth.language.and.its.implementation/mode/2up)).
Таким образом, внутри цикла `for … next` нельзя будет использовать слово
`exit`.

Слово `for` снимает со стека данных и кладёт на стек возвратов значения
`‹до›` (подвершина стека возвратов) и =‹от›= (вершина стека возвратов).

Слово `i` кладёт на стек данных содержимое верхушки стека возвратов,
стек возвратов не меняется.

Слово `next` декрементирует вершину стека возвратов и сравнивает её
с подвершиной:

-   если вершина меньше подвершины, то оба значения удаляются из стека
    возвратов, управление передаётся слову, следующему за =next=,
-   иначе управление передаётся на слово, следующее за предшествующим
    `for`.

Цикл `for … next` вложенным можно не реализовывать. (В реализациях FORTH
во вложенных циклах со счётчиком слово `j` позволяет получить значение
счётчика внешнего цикла.)

Пример.

``` scheme
(interpret #(define fact
               1 1 rot for i * next
             end
             6 fact 10 fact)
           '())                                  →  (3628800 720)
```

Вместо стека возвратов можно создать третий стек специально для цикла
`for … next`.

## Операторы `break` и =continue= (`feature-break-continue`)

(Один балл за оба.)

Слово `break` прерывает выполнение цикла — выполняет переход на слово,
следующее за словом-окончанием цикла (`wend`, `repeat` или =next=).

Слово `continue` завершает текущую итерацию цикла — выполняет переход
на слово-окончание цикла (`wend`, `repeat` или `next`).

## Конструкция `switch`-`case` (`feature-switch-case`)

**Синтаксис:**

``` example
switch
…
case ‹КОНСТ1›  … exitcase …
…
case ‹КОНСТn›  … exitcase …
…
endswitch
```

После слова `case` должна располагаться целочисленная константа.

**Семантика** идентична семантике `switch` в Си.

-   Слово `switch` снимает со стека число, ищет метку `case` с заданной
    константой (если нашлось несколько меток с одинаковой константой,
    поведение не определено) и переходит на неё. Если константа
    не найдена, осуществляется переход на слово после `endswitch`.
-   Слово `case` осуществляет переход на слово после метки.
-   Слово `exitcase` осуществляет переход на слово после `endswitch`.
-   Слово `endswitch` ничего не делает.

Таким образом, слово `exitcase` эквивалентно `break` внутри `switch`
в Си, через метки, как и в Си, можно «проваливаться».

Аналог метки `default` можно не реализовывать. Вложенные `switch` тоже
можно не реализовывать.

## Статьи высшего порядка — косвенный вызов и лямбды

(`feature-hi-level`)

Предлагается добавить в интерпретатор поддержку статей высшего порядка,
аналог функций/процедур высшего порядка в других языках
программирования.

**Синтаксис и семантика.**

-   Слово `& ‹имя›` требует после себя имя статьи, определённой
    пользователем, при выполнении оставляет на стеке данных адрес
    статьи — номер слова, на который выполнился бы переход при обычном
    вызове слова. Адрес встроенной статьи получить нельзя.

-   `lam … endlam` определяет безымянную статью:

    -   `lam` помещает на стек данных адрес слова, следующего за словом
        `lam` и осуществляет переход на слово, следующее за =endlam=,
    -   `endlam` снимает адрес со стека возвратов и осуществляет на него
        переход — аналогично словам `end` и =exit=.

-   `apply= --- снимает со стека данных адрес статьи и осуществляет её
     вызов --- кладёт на стек возвратов номер слова, следующего за =apply`
    и осуществляет переход на слово, снятое со стека данных.

Пример. Слово `power` применяет функцию указанное количество раз:

``` scheme
(interpret #(define power
               ; power : x λ n ≡ λ(λ(λ…λ(x)…)) (n раз)
               dup 0 = if drop drop exit endif
               rot                               ; n  λ  x
               over                              ; n  λ  x  λ
               apply                             ; n  λ  x′
               over                              ; x′ λ  n
               1 -                               ; x′ λ  n−1
               power                             ; рекурсивный вызов
             end
             define square dup * end
             3 & square 3 power                  ; ((3²)²)² = 6561
             2 lam dup dup * * endlam 2 power    ; (2³)³ = 512
            )
           '())                                  →  (6561 512)
```

Безымянные статьи `lam … endlam` могут быть вложенными.

## Хвостовая рекурсия (`feature-tail-call`)

Слово `tail ‹имя›` осуществляет вызов определённого пользователем слова
`‹имя›` без помещения адреса следующего слова на стек возвратов. Таким
образом, остаток предыдущей статьи игнорируется (на него возврата
не будет), вызов `tail ‹имя›` в некотором смысле эквивалентен `goto`,
где роль метки играет определение статьи.

Поведение `tail ‹имя›` эквивалентно `‹имя› exit` с единственным
отличием, что первое не заполняет стек возвратов.

Пример.

``` scheme
(interpret #(define F 11 22 33 tail G 44 55 end
             define G 77 88 99 end
             F)
           '())                                  → (99 88 77 33 22 11)
(interpret #(define =0? dup 0 = end
             define gcd
                 =0? if drop exit endif
                 swap over mod
                 tail gcd
             end
             90 99 gcd
             234 8100 gcd) '())                  → (18 9)
```

## Глобальные переменные (`feature-global`)

-   Определение переменной выглядит как
    `defvar ‹имя› ‹начальное значение›`, при выполнении `defvar`
    определяется слово `‹имя›`, которое кладёт на стек текущее значение
    переменной.
-   Запись в переменную осуществляется словом `set ‹имя›`, слово `set`
    снимает со стека число и присваивает его переменной с заданным
    именем.

Пример.

``` scheme
(interpret #(defvar counter 0
             define next
               counter dup 1 + set counter
             end
             counter counter
             counter counter +
             counter counter *)
           '())                                  → (42 5 1 0)
```

## Решение

``` scheme
(define feature-if-else #t)
(define feature-nested-if #t)
(define feature-while-loop #t)
(define feature-repeat-loop #t)
(define feature-for-loop #t)
(define feature-break-continue #t)
(define feature-switch-case #t)
(define feature-hi-level #t)
(define feature-tail-call #t)
(define feature-global #t)

;; -> stack после выполнения program
(define (interpret program stack)
  (let ((jmps (make-vector (vector-length program))))
    (begin
      ;; предподсчитаем за O(len(program)) индексы соответствий:
      ;; if else endif: if -> else + 1, else -> endif + 1
      ;; if endif: if -> endif + 1
      ;; while wend: while -> wend + 1, wend -> while
      ;; repeat until: repeat + 1 <- until
      ;; for next: for -> next + 1, next -> for + 1
      ;; lam endlam: lam -> endlam + 1
      ;; и сохраним их в вектор jmps[i] = индекс соответствующего слова
      (let loop ((index 0)
                 (stack '()))
        (if (< index (vector-length program))
            (let ((command (vector-ref program index)))
              (case command
                (if (loop (+ index 1) (cons index stack)))
                (endif (begin (vector-set! jmps (car stack) (+ 1 index))
                              (loop (+ index 1) (cdr stack))))
                (while (loop (+ index 1) (cons index stack)))
                (wend (begin (vector-set! jmps (car stack) (+ 1 index))
                             (vector-set! jmps index (car stack))
                             (loop (+ index 1) (cdr stack))))
                (repeat (loop (+ index 1) (cons index stack)))
                (until (begin (vector-set! jmps index (car stack))
                              (loop (+ index 1) (cdr stack))))
                (for (loop (+ index 1) (cons index stack)))
                (next (begin (vector-set! jmps index (+ 1 (car stack)))
                             (vector-set! jmps (car stack) (+ index 1))
                             (loop (+ index 1) (cdr stack))))
                (lam (loop (+ index 1) (cons index stack)))
                (endlam (begin (vector-set! jmps (car stack) (+ 1 index))
                               (loop (+ index 1) (cdr stack))))
                (else (if (eqv? command 'else)
                          (begin (vector-set! jmps (car stack) (+ 1 index))
                                 (loop (+ index 1) (cons index (cdr stack))))
                          (loop (+ index 1) stack)))))))
      (let interpret-internal ((stack stack)
                               (index 0)
                               (dictionary '())
                               (for-stack '()))
        (if (= index (vector-length program))
            stack
            (let ((command (vector-ref program index)))
              ;; выполнить операции со стеком, перейти к выполнению следующего слова
              (let-syntax ((call-next (syntax-rules ()
                                        ((_ new-stack)
                                         (interpret-internal new-stack
                                                             (+ index 1)
                                                             dictionary
                                                             for-stack)))))
                (if (number? command)
                    (call-next (cons command stack))
                    (case command
                      (+ (call-next (cons (+ (cadr stack) (car stack))
                                          (cddr stack))))
                      (- (call-next (cons (- (cadr stack) (car stack))
                                          (cddr stack))))
                      (* (call-next (cons (* (cadr stack) (car stack))
                                          (cddr stack))))
                      (/ (call-next (cons (quotient (cadr stack) (car stack))
                                          (cddr stack))))
                      (mod (call-next (cons (remainder (cadr stack) (car stack))
                                            (cddr stack))))
                      (neg (call-next (cons (- (car stack))
                                            (cdr stack))))
                      (= (call-next (cons (if (= (cadr stack) (car stack))
                                              -1
                                              0)
                                          (cddr stack))))
                      (< (call-next (cons (if (< (cadr stack) (car stack))
                                              -1
                                              0)
                                          (cddr stack))))
                      (> (call-next (cons (if (> (cadr stack) (car stack))
                                              -1
                                              0)
                                          (cddr stack))))
                      (not (call-next (cons (if (equal? (car stack) 0)
                                                -1
                                                0)
                                            (cdr stack))))
                      (and (call-next (cons (if (and (not (equal? (car stack) 0))
                                                     (not (equal? (cadr stack) 0)))
                                                -1
                                                0)
                                            (cddr stack))))
                      (or (call-next (cons (if (or (not (equal? (car stack) 0))
                                                   (not (equal? (cadr stack) 0)))
                                               -1
                                               0)
                                           (cddr stack))))
                      (drop (call-next (cdr stack)))
                      (swap (call-next (cons (cadr stack)
                                             (cons (car stack) (cddr stack)))))
                      (dup (call-next (cons (car stack) stack)))
                      (over (call-next (cons (cadr stack) stack)))
                      (rot (call-next (cons (caddr stack)
                                            (cons (cadr stack)
                                                  (cons (car stack) (cdddr stack))))))
                      (& (interpret-internal (cons (cadr (assoc (vector-ref program (+ index 1)) dictionary))
                                                   stack)
                                             (+ index 2)
                                             dictionary
                                             for-stack))
                      (apply (let ((jmp-index (car stack)))
                               (call-next (interpret-internal (cdr stack)
                                                              jmp-index
                                                              dictionary
                                                              for-stack))))
                      (depth (call-next (cons (length stack) stack)))
                      (define (interpret-internal stack
                                                  (+ 1 ;; следующее слово за end
                                                     (let loop ((index (+ index 2))) ;; вернет индекс следующего end
                                                       (if (eqv? 'end (vector-ref program index))
                                                           index
                                                           (loop (+ index 1)))))
                                                  (cons (list
                                                         (vector-ref program (+ index 1))
                                                         (+ index 2)) ;; (название-статьи индекс-первого-слова-статьи)
                                                        dictionary)
                                                  for-stack))
                      (defvar (interpret-internal stack
                                                  (+ index 3)
                                                  (cons (list (vector-ref program (+ index 1))
                                                              'var
                                                              (vector-ref program (+ index 2)))
                                                        dictionary)
                                                  for-stack))
                      (set (interpret-internal (cdr stack)
                                               (+ index 2)
                                               (set-cdr! (cdr (assoc (vector-ref program (+ index 1)) dictionary)) (list (car stack)))
                                               for-stack))
                      (end stack)
                      (exit stack)
                      (endlam stack)
                      (lam (interpret-internal (cons (+ index 1) stack)
                                               (vector-ref jmps index)
                                               dictionary
                                               for-stack))
                      (if (if (= 0 (car stack))
                              ;; выполняем вторую ветку, если она есть
                              (interpret-internal (cdr stack)
                                                  (vector-ref jmps index)
                                                  dictionary
                                                  for-stack)
                              ;; выполняем первую ветку
                              ;; если встретится else - скипнется вторая ветка
                              ;; если endif - выполняем следующее слово
                              (call-next (cdr stack))))
                      (endif (call-next stack))
                      (while (if (= 0 (car stack))
                                 ;; скипаем тело while
                                 (interpret-internal (cdr stack)
                                                     (vector-ref jmps index)
                                                     dictionary
                                                     for-stack)
                                 ;; выполняем тело while
                                 (call-next (cdr stack))))
                      ;; вернемся до соответствующего while
                      (wend (interpret-internal stack
                                                (vector-ref jmps index)
                                                dictionary
                                                for-stack))
                      (repeat (call-next stack))
                      (until (if (not (= 0 (car stack)))
                                 (call-next (cdr stack))
                                 (interpret-internal (cdr stack)
                                                     (vector-ref jmps index)
                                                     dictionary
                                                     for-stack)))
                      (for (let ((from (cadr stack))
                                 (to (car stack)))
                             (if (> from to)
                                 (interpret-internal (cddr stack)
                                                     (vector-ref jmps index)
                                                     dictionary
                                                     for-stack)
                                 (interpret-internal (cddr stack)
                                                     (+ index 1)
                                                     dictionary
                                                     (cons from (cons to for-stack))))))
                      (next (let ((i (+ 1 (car for-stack))))
                              (if (> i (cadr for-stack))
                                  (interpret-internal stack
                                                      (+ index 1)
                                                      dictionary
                                                      (cddr for-stack))
                                  (interpret-internal stack
                                                      (vector-ref jmps index)
                                                      dictionary
                                                      (cons i (cdr for-stack))))))
                      (tail (let ((jmp-index (cadr (assoc (vector-ref program (+ index 1)) dictionary))))
                              (interpret-internal stack
                                                  jmp-index
                                                  dictionary
                                                  for-stack)))
                      (i (call-next (cons (car for-stack) stack)))
                      ;; наивно найдем ближайший wend/until/next и выполним следующую за ним команду
                      ;; если найден next уберем с for-stack 2 элемента
                      (break (let ((jmp-index (let loop ((index (+ index 1)))
                                                (if (member (vector-ref program index) '(wend until next))
                                                    index
                                                    (loop (+ index 1))))))
                               (if (eqv? 'next (vector-ref program jmp-index))
                                   (interpret-internal stack
                                                       (+ jmp-index 1)
                                                       dictionary
                                                       (cddr for-stack))
                                   (interpret-internal stack
                                                       (+ jmp-index 1)
                                                       dictionary
                                                       for-stack))))
                      ;; наивно найдем ближайший wend/until/next и выполним его
                      (continue (let ((jmp-index (let loop ((index (+ index 1)))
                                                   (if (member (vector-ref program index) '(wend until next))
                                                       index
                                                       (loop (+ index 1))))))
                                  (interpret-internal stack
                                                      jmp-index
                                                      dictionary
                                                      for-stack)))
                      (switch (let ((jmp-index (let loop ((index (+ index 1)))
                                                 (case (vector-ref program index)
                                                   (case (if (= (vector-ref program (+ index 1))
                                                                (car stack))
                                                             (+ index 2)
                                                             (loop (+ index 2))))
                                                   (endswitch (+ index 1))
                                                   (else (loop (+ index 1)))))))
                                (interpret-internal (cdr stack)
                                                    jmp-index
                                                    dictionary
                                                    for-stack)))
                      (case (interpret-internal stack
                                                (+ index 2)
                                                dictionary
                                                for-stack))
                      ;; переход на слово за endswitch
                      ;; endswitch ищем наивно
                      (exitcase (let ((jmp-index (let loop ((index (+ index 1)))
                                                   (if (eqv? 'endswitch (vector-ref program index))
                                                       (+ index 1)
                                                       (loop (+ index 1))))))
                                  (interpret-internal stack
                                                      jmp-index
                                                      dictionary
                                                      for-stack)))
                      (endswitch (call-next stack))
                      ;; в case нельзя использовать else, поэтому обработаю его тут
                      (else (if (eqv? command 'else)
                                (interpret-internal stack
                                                    (vector-ref jmps index)
                                                    dictionary
                                                    for-stack)
                                ;; ищем статью в словаре
                                (if (eqv? (cadr (assoc command dictionary)) 'var)
                                    (call-next (cons (caddr (assoc command dictionary)) stack))
                                    (let ((jmp-index (cadr (assoc command dictionary))))
                                      (call-next (interpret-internal stack
                                                                     jmp-index
                                                                     dictionary
                                                                     for-stack)))))))))))))))
```

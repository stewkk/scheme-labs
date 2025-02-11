Лекция 5. Императивное программирование на языке Scheme
=======================================================

Сведения ко второй части домашнего задания
==========================================

Тип данных `vector`
-------------------

Списки — основные структуры данных в языках семейства Lisp. В Scheme
они не примитивный тип, а надстройка над cons-ячейками.

Списки по своей сути однонаправленны — можем их читать слева-направо
при помощи `car` и `cdr` и наращивать справа-налево при помощи `cons`.

Недостаток списков — это производительность при доступе по номеру.

Есть встроенная функция `(list-ref xs n)`, возвращающая n-й элемент:

    (define xs '(a b c d))
    (list-ref xs 2)                    →  c

(элементы нумеруются с нуля)

Но сложность той же `list-ref` — `O(n)`, где `n` — номер элемента.

Для преодоления этого недостатка в Scheme есть встроенный тип данных
`vector`, допускающий произвольный доступ к элементам для чтения и записи
за константное время.

Нужно помнить, что `vector` — ссылочный тип, в том смысле, что если
мы в две переменные положим один и тот же вектор, то изменения вектора через
одну переменную будут видны через другую.

    (define v #(1 2 3 4))
    (define w v)

    (vector-set! v 2 77)
    w                                  → #(1 2 77 4)

Создаётся вектор при помощи литерала `#(…)`, при этом его содержимое неявно
цитируется, также как и при `'(…)`.

    (define a 100)
    (define v #(1 2 3 a 4 5 6))
    a                                  → #(1 2 3 a 4 5 6)

Т.е. `a` внутри вектора будет не переменной, а процитированным символом.

Функция `make-vector` создаёт новый вектор:

    (make-vector size)
    (make-vector size init)

где `size` — размер вектора, а `init` начальное значение элементов. Т.к. вектора
используются чаще для расчётов, инициализация по умолчанию — `0`.

    (make-vector 10)                   → #(0 0 0 0 0 0 0 0 0 0)
    (make-vector 10 'a)                → #(a a a a a a a a a a)

Предикат типа — `vector?`.

    (vector? #(1 2 3))                 → #t
    (vector? '(1 2 3))                 → #f

Обращения к элементам вектора:

    (vector-ref v n)                   → n-й элемент вектора (начиная с 0)
    (vector-set! v n x)                ; присваивает n-му элементу
                                       ; новое значение x

    (define v (make-vector 5))
    v                                  → #(0 0 0 0 0)
    (vector-ref v 2)                   → 0
    (vector-set! v 2 100)
    v                                  → #(0 0 100 0 0)
    (vector-ref v 2)                   → 100

Что будет?

    (define m (make-vector 4 (make-vector 4)))

На первый взгляд, мы создаём квадратную матрицу. На самом деле, мы создаём
два вектора, все элементы одного вектора содержат `0`, все элементы второго —
ссылку на первый.

    m              → #(#(0 0 0 0) #(0 0 0 0) #(0 0 0 0) #(0 0 0 0))
    (vector-set! (vector-ref m 0) 0 1)
    m              → #(#(1 0 0 0) #(1 0 0 0) #(1 0 0 0) #(1 0 0 0))

Вектор можно преобразовать в список и наоборот

    (vector->list #(a b c))            → (a b c)
    (list->vector '(a b c))            → #(a b c)


Строки
------
Тип данных `string` хранит в себе последовательность литер (characters).
Литерал для строки — текст, записанный внутри двойных кавычек: `"Hello!"`.

Внутри строк допустимы стандартные escape-последовательности языка Си:

    "one line\ntwo lines"              ; строка со знаком перевода строки
    "I say: \"Hello!\""                ; заэкранированная кавычка

Операции над строками:

    (make-string 10 #\a)               → "aaaaaaaaaa"
    (string-ref "abcdef" 3)            → #\d               ; счёт тоже с 0
    (string->list "abcdef")            → (#\a #\b #\c #\d #\e #\f)
    (list->string '(#\H #\e #\l #\l #\o)) → "Hello"
    (string? "hello")                  → #t
    (string? 'hello)                   → #f
    (string-append "штука" "турка")    → "штукатурка"

Литеры задаются так:

    #\x            ; буква «икс»
    #\7            ; цифра «семь»
    #\(            ; литера «круглая скобка»
    #\space        ; пробел
    #\newline      ; \n в Си
    #\return       ; \r в Си
    #\tab          ; \t в Си
    #\             ; хотели пробел, но получили ошибку синтаксиса

В ДЗ потребуется функция `(whitespace? char)`, возвращающая истину, если литера —
пробельная (пробел, табуляция, новая строка, возврат каретки).

    (whitespace? #\space)              → #t
    (whitespace? #\z)                  → #f
    (whitespace? (string-ref "a b" 1)) → #t

Выбор подстрок `(substring …)` изучить самостоятельно.

Императивное программирование на языке Scheme
=============================================
До этого мы рассматривали декларативное программирование, в котором у нас не было:

* присваиваний,
* циклов,
* процедур с побочными эффектами,
* недетерминированных процедур — процедур, результат которых определяется
  не только значениями аргументов.

В Scheme есть средства не только декларативного программирования,
но и императивного. Т.е. можно и присваивать переменным новые значения,
и пользоваться процедурами, которые вызываются не только ради возвращаемого
значения, но и дополнительных действий (побочного эффекта).

В Scheme не определён порядок вычисления аргументов в вызове процедуры.
Но в императивном программировании порядок вычисления (а вернее, выполнения)
операций существенен. Поэтому в первую очередь нам нужно средство упорядочивания
выполнения операций.

## 1. `begin`

Если мы имеем вызов вида

    (f (g …))

то в Scheme гарантируется, что сначала вычислится `(g …)`, а потом `(f …)`.
(В Haskell не гарантируется.)

Но если мы имеем вызов вида

    (f (g …) (h …))

то, что выполнится раньше — `g` или `h` — зависит от реализации. Разные
реализации Scheme могут вычислять аргументы справа налево или слева направо.

Но если нужно вывести на печать несколько значений, то порядок вызова будет
существенен: функции должны вызваться в правильном порядке. Можно извратиться,
например, конструкцией `let*`:

    (let* ((x (display "Hello, "))
           (y (display "World!")))
      #f)

Но это избыточно, т.к. в Scheme уже есть особая форма `(begin …)`, гарантирующая
порядок вычисления:

    (begin
      (display "Hello, ")
      (display "World!"))

(На самом деле `begin` может быть библиотечным макросом, который неявно
трансформируется в тот же `let*`).

`begin` выполняет действия в том порядке, в котором они записаны.

Результатом `begin`’а является результат последнего действия.

    (begin (* 7 3) (+ 6 4))            → 10

Результат умножения будет отброшен, умножение тут вообще бессмысленно.

### Неявный `begin`

Некоторые конструкции Scheme позволяют записывать несколько действий подряд,
например `lambda`, `define`, определяющий процедуру, `cond`, `let`, `let*`,
`letrec`.

    ; синтаксический сахар             ; эквивалентен
    (lambda (x y)                      (lambda (x y)
      (display x)                         (begin
      (display y))                           (display x)
                                             (display y)))

    (define (f x y)                    (define (f x y)
      (display x)                         (begin
      (display y)                            (display x)
      (+ x y))                               (display y)
                                             (+ x y)))

    (let ((x 100)                      (let ((x 100)
          (y 200))                           (y 200))
      (display x)                        (begin
      (display y)                          (display x) 
      (* x y))                             (display y) 
                                           (* x y)))

    (cond ((> x y)  (display x) (- x y))
          …)

    (cond ((> x y)  (begin (display x) (- x y)))
         …)


## 2. Присваивания, `set!`

Синтаксис:

     (set! ‹имя переменной› ‹выражение›)

Переменной может быть как имя, объявленное при помощи `define`, так и параметр
процедуры или имя, определённое `let`, `let*`, `letrec`.

Например

     (define counter 0)
     counter                           → 0
     (set! counter 100)
     counter                           → 100
     (set! counter 0)

     (define (next)
       (set! counter (+ counter 1))
       counter)

     (next)                            → 1
     (next)                            → 2
     (next)                            → 3
     counter                           → 3
     (set! counter 7)
     (next)                            → 8


### Статические переменные в Scheme

В языке Си есть понятие **статическая переменная** — глобальная переменная,
видимость которой ограничена одной функцией. Объявляется она с использованием
ключевого слова `static`:

    void f() {
      int x = 0;
      static int y = 0;

      x = x + 1;
      y = y + 1;

      printf("x = %d\n", x);
      printf("y = %d\n", y);
    }

    int main(int argc, char **argv) {
      f();
      f();
      f();

      return 0;
    }

Напечатается:

    x = 1
    y = 1
    x = 1
    y = 2
    x = 1
    y = 3

Значение статической переменной сохраняется между вызовами функции (сравните
выше поведение `x` и `y`).

В языке Scheme статических переменных нет, но есть идиома (приём программирования),
позволяющая их имитировать: т.е. создавать переменные, видимые только внутри
функции, но при этом сохраняющие значение между вызовами.

Вспомним, что конструкция

    (define (f x y)
      ‹тело процедуры›)

есть синтаксический сахар для

    (define f
      (lambda (x y)
        ‹тело процедуры›))

Что будет, если мы эту лямбду обернём в let-конструкцию?

    (define f
      (let (‹объявления каких-то переменных›)
        (lambda (x y)
          ‹тело процедуры›)))

Let-конструкция свяжет с переменными значения и вернёт лямбду как свой
результат. Переменная `f` будет связана с лямбдой. Что же будет с переменными?

Эти переменные будут видимы внутри лямбды, не будут видимы вне конструкции let,
их значения будут сохраняться между вызовами.

Эти переменные будут вести себя как статические переменные в Си.

Перепишем пример с `(next)`, чтобы переменная `counter` была статической.

    (define next
      (let ((counter 0))
        (lambda ()
          (set! counter (+ counter 1))
          counter)))

    (next)                             → 1
    (next)                             → 2
    (next)                             → 3


## 3. Цикл `do`

Цикл `do` используется редко, выглядит он вот так:

    (do ((‹перем› ‹нач› ‹модиф [необ.]›)       ; почти как в let
         ...
         (‹перем› ‹нач› ‹модиф [необ.]›))
       (‹усл. выраж.› ‹возврат [необ.]›)
       ‹выраж›
       ...
       ‹выраж›)

Пример:

    (do ((vec (make-vector 5))
         (i 0 (+ i 1)))
       ((= i 5) vec)
     (vector-set! vec i i))            → #(0 1 2 3 4)

Две переменные цикла: `vec` и `i`. `vec` присваивается новый вектор, `i` — `0`,
`vec` не меняется (модификация переменной отсутствует), `i` увеличиваетя на `1`,
условие выхода — `(= i 5)`, возвращаемое значение — `vec`. В теле цикла в `i`-ю
позицию вектора присваивается число `i`.

## 4. Изменяемые структуры данных

В Scheme некоторые значения в памяти можно менять. Прежде всего это вектор — его
элементам можно присваивать новые значения при помощи `vector-set!`. Но можно
менять и cons-ячейки.

Есть такие функции:

    (set-car! ‹cons-ячейка› ‹значение›)
    (set-cdr! ‹cons-ячейка› ‹значение›)

Например, можно создать кольцевой список:

    (define loop-xs '(a b c))
    (set-cdr (cdr loop-xs) loop-xs)

Получится кольцевой список вида `(a b a b a b …)`.

    (list-ref loop-xs 0)               → a
    (list-ref loop-xs 37)              → b
    (length loop-xs)                   → зависло

Вообще, рекомендуется работать со списками как с неизменяемыми данными. Если
содержимое списков менять на месте при помощи `set-car!` или `set-cdr!`,
то можно сильно запутать программу, поскольку разные списки могут разделять
общий хвост.

    (define xs '(a b c d))
    (define ys (append '(1 2 3) xs))
    (define zs (cons 'x xs))
    (define us (append xs xs))

    (set-car! xs 'hello)

    ys                                 → (1 2 3 hello b c d)
    zs                                 → (x hello b c d)
    us                                 → (a b c d hello b c d)

Наиболее ожидаемым было изменение `zs`. Наиболее неожиданным — `us`.

<details><summary>my-append</summary>


    (define (my-append xs ys)
      (if (null xs)
          ys
          (cons (car xs) (my-append (cdr xs) ys))))


</details>










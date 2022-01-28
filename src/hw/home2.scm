;; 1. Обработка списков
;; Определите следующие процедуры для обработки списков:

;; Процедуру (my-range a b d), возвращающую список чисел в интервале [a, b) с шагом d.
;; Процедуру my-flatten, раскрывающую вложенные списки.
;; Предикат (my-element? x xs), проверяющий наличие элемента x в списке xs. Рекомендация: для проверки равенства элементов используйте встроенный предикат equal?.
;; Предикат (my-filter pred? xs), возвращающий список только тех элементов списка xs, которые удовлетворяют предикату pred?.
;; Процедуру (my-fold-left op xs) для левоассоциативной свертки списка xs с помощью оператора (процедуры двух аргументов) op.
;; Процедуру (my-fold-right op xs) для правоассоциативной свертки списка xs с помощью оператора (процедуры двух аргументов) op.
;; Примеры вызова процедур:

;; (my-range  0 11 3) ⇒ (0 3 6 9)

;; (my-flatten '((1) 2 (3 (4 5)) 6)) ⇒ (1 2 3 4 5 6)

;; (my-element? 1 '(3 2 1)) ⇒ #t
;; (my-element? 4 '(3 2 1)) ⇒ #f

;; (my-filter odd? (my-range 0 10 1))
;;   ⇒ (1 3 5 7 9)
;; (my-filter (lambda (x) (= (remainder x 3) 0)) (my-range 0 13 1))
;;   ⇒ (0 3 6 9 12)

;; (my-fold-left  quotient '(16 2 2 2 2)) ⇒ 1
;; (my-fold-left  quotient '(1))          ⇒ 1
;; (my-fold-right expt     '(2 3 4))      ⇒ 2417851639229258349412352
;; (my-fold-right expt     '(2))          ⇒ 2

(define (my-range a b d)
  (if (< a b)
      (cons a (my-range (+ a d) b d))
      '()))

(define (my-flatten l)
  (if (null? l)
      '()
      (if (list? l)
          (append (my-flatten (car l)) (my-flatten (cdr l)))
          (list l))))

(define (my-flatten l)
  (define (loop res l)
    (if (null? l)
        res
        (if (list? l)
            (loop (loop res (cdr l)) (car l))
            (cons l res))))
  (loop '() l))

(define (my-flatten l)
  (define (loop res l)
    (if (null? l)
        res
        (if (list? l)
            (loop (loop res (car l)) (cdr l))
            (cons l res))))
  (reverse (loop '() l)))

;; Написать функцию flatten без использование функции append
;; (или её аналога, написанного вручную), с хвостовой рекурсией — +2 балла.
;; (my-flatten '((1) 2 (3 (4 5)) 6)) ⇒ (1 2 3 4 5 6)

(define (my-flatten l)
  (define (loop res l)
    (if (null? l)
        (reverse res)
        (if (list? (car l))
            (if (null? (car l))
                (loop res (cdr l))
                (loop res (cons (caar l) (cons (cdar l) (cdr l)))))
            (loop (cons (car l) res) (cdr l)))))
  (if (list? l)
      (loop '() l)
      (list l)))

(define (my-element? el l)
  (and (not (null? l))
       (or (equal? el (car l))
           (my-element? el (cdr l)))))

(define (my-filter pred? l)
  (if (null? l)
      '()
      (if (pred? (car l))
          (cons (car l) (my-filter pred? (cdr l)))
          (my-filter pred? (cdr l)))))

(define (my-fold-left op xs)
  (if (null? (cdr xs))
      (car xs)
      (my-fold-left op (cons (op (car xs) (cadr xs)) (cddr xs)))))

(define (my-fold-right op xs)
  (define (my-fold-right-reversed op xs)
    (if (null? (cdr xs))
        (car xs)
        (my-fold-right-reversed op (cons (op (cadr xs) (car xs)) (cddr xs)))))
  (my-fold-right-reversed op (reverse xs)))

(newline)
(display (my-range 0 11 3))
(newline)
(display (my-range (- 10) 10 1))
(newline)
(newline)

(display (my-flatten '((1) 2 (3 (4 5)) 6)))
(newline)
(display (my-flatten '()))
(newline)
(display (my-flatten 1))
(newline)
(display (my-flatten '(1 2 (3))))
(newline)
(display (my-flatten '(() 1 () 3)))
(newline)
(newline)

(display (my-element? 1 '(3 2 1)))
(newline)
(display (my-element? 4 '(3 2 1)))
(newline)
(newline)

(display (my-filter odd? (my-range 0 10 1)))
(newline)
(display (my-filter (lambda (x) (= (remainder x 3) 0)) (my-range 0 13 1)))
(newline)
(newline)

(display (my-fold-left  quotient '(16 2 2 2 2)))
(newline)
(display (my-fold-left  quotient '(1)))
(newline)
(newline)

(display (my-fold-right expt '(2 3 4)))
(newline)
(display (my-fold-right expt '(2)))
(newline)


;; 2. Множества
;; Реализуйте библиотеку процедур для работы со множествами (для хранения множеств используйте списки):

;; Процедуру (list->set xs), преобразующую список xs в множество.
;; Предикат (set? xs), проверяющий, является ли список xs множеством.
;; Процедуру (union xs ys), возвращающую объединение множеств xs и ys.
;; Процедуру (intersection xs ys), возвращающую пересечение множеств xs и ys.
;; Процедуру (difference xs ys), возвращающую разность множеств xs и ys.
;; Процедуру (symmetric-difference xs ys), возвращающую симметричную разность множеств xs и ys.
;; Предикат (set-eq? xs ys), проверяющий множества xs и ys на равенство друг другу.
;; Примеры вызова процедур (порядок элементов множества не существенен):
;; (list->set '(1 1 2 3))                       ⇒ (3 2 1)
;; (set? '(1 2 3))                              ⇒ #t
;; (set? '(1 2 3 3))                            ⇒ #f
;; (set? '())                                   ⇒ #t
;; (union '(1 2 3) '(2 3 4))                    ⇒ (4 3 2 1)
;; (intersection '(1 2 3) '(2 3 4))             ⇒ (2 3)
;; (difference '(1 2 3 4 5) '(2 3))             ⇒ (1 4 5)
;; (symmetric-difference '(1 2 3 4) '(3 4 5 6)) ⇒ (6 5 2 1)
;; (set-eq? '(1 2 3) '(3 2 1))                  ⇒ #t
;; (set-eq? '(1 2) '(1 3))                      ⇒ #f

;; load my contains? procedure
(load "../../labs/lab2.scm")

(define (list->set xs)
  (define (loop res xs)
    (if (null? xs)
        (reverse res)
        (if (contains? (car xs) res)
            (loop res (cdr xs))
            (loop (cons (car xs) res) (cdr xs)))))
  (loop '() xs))

(define (set? xs)
  (or (null? xs)
      (and (not (contains? (car xs) (cdr xs)))
           (set? (cdr xs)))))

(define (union xs ys)
  (if (null? ys)
      xs
      (if (contains? (car ys) xs)
          (union xs (cdr ys))
          (union (cons (car ys) xs) (cdr ys)))))

(define (intersection xs ys)
  (define (loop res xs)
    (if (null? xs)
        res
        (if (contains? (car xs) ys)
            (loop (cons (car xs) res) (cdr xs))
            (loop res (cdr xs)))))
  (loop '() xs))

(define (difference xs ys)
  (define (loop res xs)
    (if (null? xs)
        res
        (if (contains? (car xs) ys)
            (loop res (cdr xs))
            (loop (cons (car xs) res) (cdr xs)))))
  (loop '() xs))

(define (symmetric-difference xs ys)
  (append (difference xs ys) (difference ys xs)))

(define (set-eq? xs ys)
  (define (loop xs)
    (or (null? xs)
        (and (contains? (car xs) ys)
             (loop (cdr xs)))))
  (and (= (length xs) (length ys)) (loop xs)))

(display "=====HW2 TESTS=====")
(newline)
(newline)
(display (list->set '(1 1 2 3)))
(newline)

(newline)
(display (set? '(1 2 3)))
(newline)
(display (set? '(1 2 3 3)))
(newline)
(display (set? '()))
(newline)

(newline)
(display (union '(1 2 3) '(2 3 4)))
(newline)
(newline)
(display (intersection '(1 2 3) '(2 3 4)))
(newline)
(newline)
(display (difference '(1 2 3 4 5) '(2 3)))
(newline)
(newline)
(display (symmetric-difference '(1 2 3 4) '(3 4 5 6)))
(newline)
(newline)
(display (set-eq? '(1 2 3) '(3 2 1)))
(newline)
(display (set-eq? '(1 2) '(1 3)))
(newline)
(display (set-eq? '(1 2 3) '(1 2 3 4)))
(newline)
(display (set-eq? '() '()))

;; 3. Работа со строками
;; Реализуйте библиотеку процедур для работы со строками. Реализуйте следующие процедуры:

;; Процедуры string-trim-left, string-trim-right и string-trim,
;; удаляющие все пробельные символы в начале, конце и с обеих сторон строки соответственно.
;; Предикаты (string-prefix? a b), (string-suffix? a b) и (string-infix? a b),
;; соответственно, проверяющие, является ли строка a началом строки b,
;; окончанием строки b или строка a где-либо встречается в строке b.
;; Процедуру (string-split str sep), возвращающую список подстрок строки str,
;; разделённых в строке str разделителями sep, где sep — непустая строка.
;; Т.е. процедура (string-split str sep) должна разбивать строку на подстроки по строке-разделителю sep.
;; Рекомендуется преобразовывать входные строки к спискам символов и анализировать уже эти списки.

;; Примеры вызова процедур:

;; (string-trim-left  "\t\tabc def")   ⇒ "abc def"
;; (string-trim-right "abc def\t")     ⇒ "abc def"
;; (string-trim       "\t abc def \n") ⇒ "abc def"

;; (string-prefix? "abc" "abcdef")  ⇒ #t
;; (string-prefix? "bcd" "abcdef")  ⇒ #f
;; (string-prefix? "abcdef" "abc")  ⇒ #f

;; (string-suffix? "def" "abcdef")  ⇒ #t
;; (string-suffix? "bcd" "abcdef")  ⇒ #f

;; (string-infix? "def" "abcdefgh") ⇒ #t
;; (string-infix? "abc" "abcdefgh") ⇒ #t
;; (string-infix? "fgh" "abcdefgh") ⇒ #t
;; (string-infix? "ijk" "abcdefgh") ⇒ #f
;; (string-infix? "bcd" "abc")      ⇒ #f

;; (string-split "x;y;z" ";")       ⇒ ("x" "y" "z")
;; (string-split "x-->y-->z" "-->") ⇒ ("x" "y" "z")

;; Написать функцию list-trim-right, удаляющую пробельные символы на конце списка,
;; без реверса этого списка (встроенной функции reverse или её аналога, написанного вручную) — +1 балл.
;; Написать функцию list-trim-right, удаляющую пробельные символы на конце списка,
;; без реверса этого списка (встроенной функции reverse или её аналога, написанного вручную)
;; и работающую со сложностью O(len(xs)) — +2 балла.

(define (string-trim-left s)
  (define (loop s)
    (if (and (not (null? s)) (char-whitespace? (car s)))
        (loop (cdr s))
        s))
  (list->string (loop (string->list s))))

;; тоже O(n), но с меньшим коэффициентом
(define (string-trim-left s)
  (define (loop s i)
    (if (= i (string-length s)) ;; TODO поменять вложенный if на and
        ""
        (if (char-whitespace? (string-ref s i))
            (loop s (+ i 1))
            (substring s i))))
  (loop s 0))

(define (string-trim-right s)
  (define (loop s i)
    (if (= i 0) ;; TODO так же поменять вложенный if на and
        ""
        (if (char-whitespace? (string-ref s (- i 1)))
            (loop s (- i 1))
            (substring s 0 i))))
  (loop s (string-length s)))

;; O(n)
(define (string-trim s)
  (string-trim-left (string-trim-right s)))

(define (string-prefix? a b)
  (define (loop i)
    (or (>= i (string-length a))
        (and (equal? (string-ref a i) (string-ref b i))
             (loop (+ i 1)))))
  (and (<= (string-length a) (string-length b)) (loop 0)))

(define (string-suffix? a b)
  (define (loop k) ;; k - кол-во рассмотренных символов
    (let ((i (- (string-length a) k 1))
          (j (- (string-length b) k 1)))
      (or (< i 0)
          (< j 0)
          (and (equal? (string-ref a i) (string-ref b j))
               (loop (+ k 1))))))
  (and (<= (string-length a) (string-length b)) (loop 0)))

;; TODO хочу префикс-функцией (Кнутт-Моррис-Пратт) =(
;; аааааааа ЗАБАНЬТЕ МЕНЯ
(define (string-infix? a b)
  (and (> (string-length b) 0)
       (or (string-prefix? a b)
           (string-infix? a (substring b 1))))) ;; TODO переписать с list-prefix?, т.к. тут лишнее копирование в substring

(define (list-prefix? a b)
  (or (null? a)
      (and (not (null? b))
           (equal? (car a) (car b))
           (list-prefix? (cdr a) (cdr b)))))

(define (list-skip l n)
  (if (> n 0)
      (list-skip (cdr l) (- n 1))
      l))

;; ну и ну! вы написали говнокод: -2 балла основы информатики!
(define (string-split str sep)
  (let ((sep-len (string-length sep)))
    (define (loop str sep res temp)
      (if (null? str)
              (reverse (cons (list->string (reverse temp)) res)) ;; TODO УБРАТЬ ДУБЛИРОВАНИЕ КОДА
          (if (list-prefix? sep str)
              (loop (list-skip str sep-len) sep (cons (list->string (reverse temp)) res) '()) ;; тут дублируется
              (loop (cdr str) sep res (cons (car str) temp)))))
      (loop (string->list str) (string->list sep) '() '())))

(display (string-trim-left "\t\tabc def"))
(newline)
(display (string-trim-right "abc def\t"))
(newline)
(display (string-trim "\t abc def \n"))
(newline)
(newline)

(display (string-prefix? "abc" "abcdef"))
(newline)
(display (string-prefix? "bcd" "abcdef"))
(newline)
(display (string-prefix? "abcdef" "abc"))
(newline)
(display (string-prefix? "" ""))
(newline)
(newline)

(display (string-suffix? "def" "abcdef"))
(newline)
(display (string-suffix? "bcd" "abcdef"))
(newline)
(display (string-suffix? "" "abcdef"))
(newline)
(display (string-suffix? "abcdef" "def"))
(newline)
(newline)

(display (string-infix? "def" "abcdefgh"))
(newline)
(display (string-infix? "abc" "abcdefgh"))
(newline)
(display (string-infix? "fgh" "abcdefgh"))
(newline)
(display (string-infix? "ijk" "abcdefgh"))
(newline)
(display (string-infix? "bcd" "abc"))
(newline)
(display (string-infix? "abcd" "abc"))
(newline)
(newline)

(display (string-split "x;y;z" ";"))
(newline)
(display (string-split "x-->y-->z" "-->"))
(newline)
(display (string-split "xyz-->yx-->z-->" "-->"))
(newline)
(display (string-split "-->" "-->"))
(newline)
(display (string-split "-->xyz-->x-->abc" "-->"))
(newline)
(newline)

(define (calc-last-whitespaces l)
  (define (loop l res k)
    (if (null? l)
        (list res k)
        (loop (cdr l)
              (cons (car l) res)
              (if (and (char? (car l)) (char-whitespace? (car l)))
                  (+ k 1)
                  0))))
  (loop l '() 0))

(define (list-trim-right l)
  (define (loop res l k)
    (if (null? l)
        res
        (if (= 0 k)
            (loop (cons (car l) res) (cdr l) 0)
            (loop res (cdr l) (- k 1)))))
  (apply loop (cons '() (calc-last-whitespaces l))))

(display (list-trim-right '((1) 2 3 #\space 5 #\space #\tab)))

;; TODO: переделать без reverse

;; 4. Многомерные вектора
;; Реализуйте поддержку типа «многомерный вектор» — вектор произвольной размерности (1 и более).
;; Пусть элементы такого вектора хранятся не во вложенных векторах, а в едином одномерном
;; векторе встроенного типа.

;; Реализуйте следующие процедуры:

;; (make-multi-vector sizes) и (make-multi-vector sizes fill) для создания многомерного вектора.
;; Число элементов в каждой размерности задается списком sizes.
;; Второй вариант вызова процедуры позволяет заполнить все элементы значением fill.
;; (multi-vector? m) для определения, является ли m многомерным вектором.
;; Для вектора в общем случае (т.е. для такого, который не является представлением многомерного вектора)
;; должна возвращать #f.
;; (multi-vector-ref m indices) для получения значения элемента с индексами,
;; перечисленными в списке indices.
;; (multi-vector-set! m indices x) для присваивания значения x элементу с индексами,
;; перечисленными в списке indices.
;; Примеры вызова процедур:

;; (define m (make-multi-vector '(11 12 9 16)))
;; (multi-vector? m)
;; (multi-vector-set! m '(10 7 6 12) 'test)
;; (multi-vector-ref m '(10 7 6 12)) ⇒ test

;; ; Индексы '(1 2 1 1) и '(2 1 1 1) — разные индексы
;; (multi-vector-set! m '(1 2 1 1) 'X)
;; (multi-vector-set! m '(2 1 1 1) 'Y)
;; (multi-vector-ref m '(1 2 1 1)) ⇒ X
;; (multi-vector-ref m '(2 1 1 1)) ⇒ Y

;; (define m (make-multi-vector '(3 5 7) -1))
;; (multi-vector-ref m '(0 0 0)) ⇒ -1

(define (count-multipliers sizes)
  (define (loop sizes res)
    (if (null? (cdr sizes))
        res
        (loop (cdr sizes)
              (cons (* (car sizes) (car res)) res))))
  (loop (reverse sizes) '(1)))

(define (make-multi-vector sizes . fill)
  (list 'my-multi-vector
        (list->vector (count-multipliers sizes))
        (if (null? fill)
            (make-vector (apply * sizes) 0)
            (make-vector (apply * sizes) (car fill)))))

(define (multi-vector? m)
  (and
   (list? m)
   (equal? 'my-multi-vector (car m))))

(define (multi-vector-calc-index multipliers indices i res)
  (if (null? indices)
      res
      (multi-vector-calc-index multipliers
                               (cdr indices)
                               (+ i 1)
                               (+ res (* (car indices) (vector-ref multipliers i))))))

(define (multi-vector-set! m indices x)
  (let ((multipliers (cadr m))
        (data (caddr m)))
    (vector-set! data (multi-vector-calc-index multipliers indices 0 0) x)))

(define (multi-vector-ref m indices)
  (let ((multipliers (cadr m))
        (data (caddr m)))
    (vector-ref data (multi-vector-calc-index multipliers indices 0 0))))

(define m (make-multi-vector '(11 12 9 16)))
(display (multi-vector? m))
(newline)
(display (multi-vector? '((1 2) (1 2 3))))
(newline)
(multi-vector-set! m '(10 7 6 12) 'test)
(display (multi-vector-ref m '(10 7 6 12)))
(newline)

(multi-vector-set! m '(1 2 1 1) 'X)
(multi-vector-set! m '(2 1 1 1) 'Y)
(display (multi-vector-ref m '(1 2 1 1)))
(newline)
(display (multi-vector-ref m '(2 1 1 1)))
(newline)

(define m (make-multi-vector '(3 5 7) -1))
(display (multi-vector-ref m '(0 0 0)))
(newline)
(define m3 (make-multi-vector '(2 2 2)))
(multi-vector-set! m3 '(0 0 0) 1000)
(multi-vector-set! m3 '(0 0 1) 1001)
(multi-vector-set! m3 '(0 1 0) 1010)
(multi-vector-set! m3 '(1 0 0) 1100)
(display (map (lambda (idx)
       (multi-vector-ref m3 idx))
     '((0 0 0) (0 0 1) (0 1 0) (1 0 0))))

;; + ТЕСТЫ С ДОСКИ
(define m2 (make-multi-vector '(2 2)))
(multi-vector-set! m2 '(1 0) 'a)
(multi-vector-set! m2 '(0 1) 'b)
(display (caddr m2))
(newline)
(display (multi-vector-ref m2 '(0 1)))
(newline)
(display (multi-vector-ref m2 '(1 0)))
(newline)

;; 5. Композиция функций
;; Реализуйте композицию функций (процедур) одного аргумента, для чего напишите процедуру o,
;; принимающую произвольное число процедур одного аргумента и возвращающую процедуру,
;; являющуюся композицией этих процедур.

;; Примеры применения процедуры:

;; (define (f x) (+ x 2))
;; (define (g x) (* x 3))
;; (define (h x) (- x))

;; ((o f g h) 1) ⇒ -1
;; ((o f g) 1)   ⇒ 5
;; ((o h) 1)     ⇒ -1
;; ((o) 1)       ⇒ 1
;; При решении задачи № 5 (композиция функций) воспользоваться одной из функций, написанных
;; при решении одной из предыдущих задач. Решение должно получиться нерекурсивным. +1 балл.

(define (o . fs)
  (lambda (x)
    (my-fold-left
     (lambda (x op)
       (op x))
     (cons x (reverse fs)))))

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

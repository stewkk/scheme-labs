---
title: Домашнее задание №1
---

При выполнении заданий **не используйте** присваивание и циклы.
Избегайте возврата логических значений из условных конструкций.
Подготовьте примеры для демонстрации работы разработанных вами процедур.

# 1. Определение дня недели по дате

Определите процедуру `day-of-week`, вычисляющую день недели по дате по
григорианскому календарю. Воспользуйтесь алгоритмом, описанным в
литературе. Пусть процедура принимает три формальных аргумента (день
месяца, месяц и год в виде целых чисел) и возвращает целое число — номер
дня в неделе (0 — воскресенье, 1 — понедельник, … 6 — суббота).

Пример вызова процедуры:

``` example
(day-of-week 04 12 1975) ⇒ 4
(day-of-week 04 12 2006) ⇒ 1
(day-of-week 29 05 2013) ⇒ 3
```

## алгоритм Сакамото

[источник](https://www.geeksforgeeks.org/tomohiko-sakamotos-algorithm-finding-day-week/)

``` scheme
(define (day-of-week-fixed-month day month year)
  (remainder (+ year
                (quotient year 4)
                (- (quotient year 100))
                (quotient year 400)
                (char->integer (string-ref "-bed=pen+mad." month))
                day)
             7))

(define (day-of-week day month year)
  (if (< month 3)
      (day-of-week-fixed-month day month (- year 1))
      (day-of-week-fixed-month day month year)))
```

### тесты

``` scheme
(define (test-day-of-week name)
  (display name)
  (newline)
  (display "04 12 1975 ")
  (display (day-of-week 04 12 1975))
  (newline)
  (display "04 12 2006 ")
  (display (day-of-week 04 12 2006))
  (newline)
  (display "29 05 2013 ")
  (display (day-of-week 29 05 2013))
  (newline)
  (display "01 01 1970 ")
  (display (day-of-week 01 01 1970))
  (newline)
  (display "02 01 1970 ")
  (display (day-of-week 02 01 1970))
  (newline)
  (display "03 01 1970 ")
  (display (day-of-week 03 01 1970))
  (newline)
  (display "04 01 1970 ")
  (display (day-of-week 04 01 1970))
  (newline)
  (display "05 01 1970 ")
  (display (day-of-week 05 01 1970))
  (newline)
  (display "06 01 1970 ")
  (display (day-of-week 06 01 1970))
  (newline)
  (newline))

(test-day-of-week "Sakamoto's:")
```

``` example
Sakamoto's:
04 12 1975 4
04 12 2006 1
29 05 2013 3
01 01 1970 4
02 01 1970 5
03 01 1970 6
04 01 1970 0
05 01 1970 1
06 01 1970 2

```

## алгоритм Сакамото без `string-ref`

``` scheme
(define (day-of-week-fixed-month day month year)
  (remainder (+ year
                (quotient year 4)
                (- (quotient year 100))
                (quotient year 400)
                (or
                    (and (= month  1) 0)
                    (and (= month  2) 3)
                    (and (= month  3) 2)
                    (and (= month  4) 5)
                    (and (= month  5) 0)
                    (and (= month  6) 3)
                    (and (= month  7) 5)
                    (and (= month  8) 1)
                    (and (= month  9) 4)
                    (and (= month 10) 6)
                    (and (= month 11) 2)
                    (and (= month 12) 4))
                day)
             7))
(define (day-of-week day month year)
  (if (< month 3)
      (day-of-week-fixed-month day month (- year 1))
      (day-of-week-fixed-month day month year)))
```

### тесты

``` scheme
(test-day-of-week "Sakamoto 2:")
```

``` example
Sakamoto 2:
04 12 1975 4
04 12 2006 1
29 05 2013 3
01 01 1970 4
02 01 1970 5
03 01 1970 6
04 01 1970 0
05 01 1970 1
06 01 1970 2

```

## алгоритм с wikibooks

[ссылка](https://ru.wikibooks.org/wiki/%D0%A0%D0%B5%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D0%B8_%D0%B0%D0%BB%D0%B3%D0%BE%D1%80%D0%B8%D1%82%D0%BC%D0%BE%D0%B2/%D0%92%D0%B5%D1%87%D0%BD%D1%8B%D0%B9_%D0%BA%D0%B0%D0%BB%D0%B5%D0%BD%D0%B4%D0%B0%D1%80%D1%8C)

``` scheme
(define (calc-day-of-week2 day month year)
  (remainder (+ day
                (quotient (* 31 month) 12)
                year
                (quotient year 4)
                (- (quotient year 100))
                (quotient year 400))
             7))

(define (day-of-week day month year)
  (if (or (= month 1) (= month 2))
      (calc-day-of-week2 day (+ month 10) (- year 1))
      (calc-day-of-week2 day (- month 2) year)))
```

### тесты

``` scheme
(test-day-of-week "ru.wikibooks.org:")
```

``` example
ru.wikibooks.org:
04 12 1975 4
04 12 2006 1
29 05 2013 3
01 01 1970 4
02 01 1970 5
03 01 1970 6
04 01 1970 0
05 01 1970 1
06 01 1970 2

```

# 2. Действительные корни квадратного уравнения

Определите процедуру, принимающую коэффициенты *a*, *b* и *c*
квадратного уравнения вида /ax/²+/bx/+/c/=0 и возвращающую список чисел
— корней уравнения (один или два корня, или пустой список, если корней
нет).

**Указание:** для формирования списка используйте функцию `(list …)`:

``` example
(list)        → ()
(list 10)     → (10)
(list 10 11)  → (10 11)
```

## решение

``` scheme
(define (D a b c)
  (- (* b b)
     (* 4 a c)))

(define (quadratic_equation_by_D a b D)
  (if (>= D 0)
      (if (> D 0)
          (list (/ (+ (- b) (sqrt D)) (* 2 a))
                (/ (- (- b) (sqrt D)) (* 2 a)))
          (list (/ (- b) (* 2 a))))
      (list)))

(define (quadratic_equation a b c)
  (quadratic_equation_by_D a b (D a b c)))
```

## тесты

``` scheme
(display (quadratic_equation 2 5 -3)) ;; -3 1/2
(newline)
(display (quadratic_equation 4 21 5)) ;; -5 -1/4
(newline)
(display (quadratic_equation 4 -12 9)) ;; 3/2
(newline)
(display (quadratic_equation 1 2 17)) ;; нет корней
(newline)
```

``` example
(1/2 -3)
(-1/4 -5)
(3/2)
()
```

# 3. НОД, НОК и проверка числа на простоту

Определите:

-   Процедуру `(my-gcd a b)`, возвращающую наибольший общий делитель
    чисел `a` и `b`. Поведение вашей процедуры должно быть идентично
    поведению встроенной процедуры `gcd`.

-   Процедуру `(my-lcm a b)`, возвращающую наименьшее общее кратное
    чисел `a` и `b`. Используйте процедуру `my-gcd`, определенную вами
    ранее. Поведение вашей процедуры должно быть идентично поведению
    встроенной процедуры `lcm`.

-   Процедуру `(prime? n)`, выполняющую проверку числа `n` на простоту и
    возвращающую `#t`, если число простое и `#f` в противном случае.

-   Примеры вызова процедур:

``` example
(my-gcd 3542 2464) ⇒ 154
(my-lcm 3 4)       ⇒  12
(prime? 11)        ⇒  #t
(prime? 12)        ⇒  #f
```

## решение

``` scheme
(define (my-gcd a b)
  (if (= b 0)
      a
      (my-gcd b (remainder a b))))

(define (my-lcm a b)
  (quotient (* a b) (my-gcd a b)))

(define (recursive-prime-test n i)
  (or (> (* i i) n)
      (and
       (> (remainder n i) 0)
       (> (remainder n (+ i 2)) 0)
       (recursive-prime-test n (+ i 6)))))

(define (prime? n)
  (or (= n 2)
      (= n 3)
      (and (>= n 5)
           (> (remainder n 2) 0)
           (> (remainder n 3) 0)
           (recursive-prime-test n 5))))
```

## тесты

``` scheme
(display (prime? 1))
(newline)
(display (prime? 2))
(newline)
(display (prime? 3))
(newline)
(display (prime? 4))
(newline)
(display (prime? 5))
(newline)
(display (prime? 6))
(newline)
(display (prime? 7))
(newline)
(display (prime? 8))
(newline)
(display (prime? 13))
(newline)
```

``` example
#f
#t
#t
#f
#t
#f
#t
#f
#t
```

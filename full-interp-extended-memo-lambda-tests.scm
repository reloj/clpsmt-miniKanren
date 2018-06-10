(load "mk.scm")
(load "z3-driver.scm")
(load "test-check.scm")
(load "full-interp-extended-memo-lambda.scm")


(test "evalo-fac-6"
  (run* (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (- n 1))))))))
              (fac 6))
           q))
  '(720))

;; slowish
(test "evalo-fac-9"
  (run* (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (- n 1))))))))
              (fac 9))
           q))
  '(362880))

(test "evalo-backwards-fac-6"
  (run 1 (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (- n 1))))))))
              (fac ,q))
           720))
  '(6))

;; remember the quote!
(test "evalo-backwards-fac-quoted-6"
  (run* (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (- n 1))))))))
              (fac ',q))
           720))
  '(6))


;; slowish
(test "evalo-backwards-fac-9"
  (run 1 (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (- n 1))))))))
              (fac ,q))
           362880))
  '(9))

;; remember the quote!
(test "evalo-backwards-fac-quoted-9"
  (run* (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (- n 1))))))))
              (fac ',q))
           362880))
  '(9))


;; slowish
(test "evalo-fac-table"
  (run* (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (- n 1))))))))
              (list
               (fac 0)
               (fac 1)
               (fac 2)
               (fac 3)))
           q))
  '((1 1 2 6)))

(test "evalo-fac-synthesis-hole-0"
  (run* (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) ',q
                                (* n (fac (- n 1))))))))
              (list
               (fac 0)
               (fac 1)
               (fac 2)
               (fac 3)))
           '(1 1 2 6)))
  '(1))

(test "evalo-fac-synthesis-hole-2"
  (run 1 (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (- ,q 1))))))))
              (list
               (fac 0)
               (fac 1)
               (fac 2)
               (fac 3)))
           '(1 1 2 6)))
  '(n))

(test "evalo-fac-synthesis-hole-3"
  (run 1 (q)
    (fresh (r s)
      (== (list r s) q)
      (evalo `(letrec ((fac
                        (lambda (n)
                          (if (< n 0) #f
                              (if (= n 0) 1
                                  (* n (fac (- ,r ,s))))))))
                (list
                 (fac 0)
                 (fac 1)
                 (fac 2)
                 (fac 3)))
             '(1 1 2 6))))
  '((n 1)))

;; slow, even with the 'symbolo' constraint on 'q'
(test "evalo-fac-synthesis-hole-4"
  (run 1 (q)
    (symbolo q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (,q n 1))))))))
              (list
               (fac 0)
               (fac 1)
               (fac 2)
               (fac 3)))
           '(1 1 2 6)))
  '(-))





(test "evalo-fac-synthesis-hole-1"
  (run 1 (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (,q (- n 1))))))))
              (list
               (fac 0)
               (fac 1)
               (fac 2)
               (fac 3)))
           '(1 1 2 6)))
  '(fac))





(test "evalo-even?/odd?-both-memod-0"
  (run* (q)
    (evalo `(letrec ((even? (memo-lambda even? (n)
                              (if (= n 0)
                                  #t
                                  (odd? (- n 1)))))
                     (odd? (memo-lambda odd? (n)
                              (if (= n 0)
                                  #f
                                  (even? (- n 1))))))
              (even? 0))
           q))
  '(#t))

(test "evalo-even?/odd?-both-memod-1"
  (run* (q)
    (evalo `(letrec ((even? (memo-lambda even? (n)
                              (if (= n 0)
                                  #t
                                  (odd? (- n 1)))))
                     (odd? (memo-lambda odd? (n)
                              (if (= n 0)
                                  #f
                                  (even? (- n 1))))))
              (even? 1))
           q))
  '(#f))

(test "evalo-even?/odd?-both-memod-2"
  (run* (q)
    (evalo `(letrec ((even? (memo-lambda even? (n)
                              (if (= n 0)
                                  #t
                                  (odd? (- n 1)))))
                     (odd? (memo-lambda odd? (n)
                              (if (= n 0)
                                  #f
                                  (even? (- n 1))))))
              (even? 2))
           q))
  '(#t))

(test "evalo-even?/odd?-both-memod-3"
  (run* (q)
    (evalo `(letrec ((even? (memo-lambda even? (n)
                              (if (= n 0)
                                  #t
                                  (odd? (- n 1)))))
                     (odd? (memo-lambda odd? (n)
                              (if (= n 0)
                                  #f
                                  (even? (- n 1))))))
              (even? 3))
           q))
  '(#f))

(test "evalo-even?/odd?-both-memod-4a"
  (run* (q)
    (evalo `(letrec ((even? (memo-lambda even? (n)
                              (if (= n 0)
                                  #t
                                  (odd? (- n 1)))))
                     (odd? (memo-lambda odd? (n)
                              (if (= n 0)
                                  #f
                                  (even? (- n 1))))))
              (even? 4))
           q))
  '(#t))

(test "evalo-even?/odd?-both-memod-4a-show-table"
  (run* (q)
    (fresh (tables-out val)
      (== (list tables-out val) q)
      (eval-expo `(letrec ((even? (memo-lambda even? (n)
                                    (if (= n 0)
                                        #t
                                        (odd? (- n 1)))))
                           (odd? (memo-lambda odd? (n)
                                   (if (= n 0)
                                       #f
                                       (even? (- n 1))))))
                    (even? 4))
                 initial-env
                 initial-tables
                 tables-out
                 val)))
  '((((even? ((4) (memo-value #t))
             ((2) (memo-value #t))
             ((0) (memo-value #t))
             ((0) in-progress)
             ((2) in-progress)
             ((4) in-progress))
      (odd? ((3) (memo-value #t))
            ((1) (memo-value #t))
            ((1) in-progress)
            ((3) in-progress))
      (even? ((2) (memo-value #t))
             ((0) (memo-value #t))
             ((0) in-progress)
             ((2) in-progress)
             ((4) in-progress))
      (odd? ((1) (memo-value #t))
            ((1) in-progress)
            ((3) in-progress))
      (even? ((0) (memo-value #t))
             ((0) in-progress)
             ((2) in-progress)
             ((4) in-progress))
      (even? ((0) in-progress)
             ((2) in-progress)
             ((4) in-progress))
      (odd? ((1) in-progress)
            ((3) in-progress))
      (even? ((2) in-progress)
             ((4) in-progress))
      (odd? ((3) in-progress))
      (even? ((4) in-progress))
      (odd?)
      (even?))
     #t)))

(test "evalo-even?/odd?-both-memod-4b"
  (run* (q)
    (evalo `(letrec ((even? (memo-lambda even? (n)
                              (if (= n 0)
                                  #t
                                  (odd? (- n 1)))))
                     (odd? (memo-lambda odd? (n)
                              (if (= n 0)
                                  #f
                                  (even? (- n 1))))))
              (list (even? 4) (even? 4)))
           q))
  '((#t #t)))

(test "evalo-even?/odd?-both-memod-4b-show-table"
  (run* (q)
    (fresh (tables-out val)
      (== (list tables-out val) q)
      (eval-expo `(letrec ((even? (memo-lambda even? (n)
                                    (if (= n 0)
                                        #t
                                        (odd? (- n 1)))))
                           (odd? (memo-lambda odd? (n)
                                   (if (= n 0)
                                       #f
                                       (even? (- n 1))))))
                    (list (even? 4) (even? 4)))
                 initial-env
                 initial-tables
                 tables-out
                 val)))
  '((((even? ((4) (memo-value #t))
             ((2) (memo-value #t))
             ((0) (memo-value #t))
             ((0) in-progress)
             ((2) in-progress)
             ((4) in-progress))
      (odd? ((3) (memo-value #t))
            ((1) (memo-value #t))
            ((1) in-progress)
            ((3) in-progress))
      (even? ((2) (memo-value #t))
             ((0) (memo-value #t))
             ((0) in-progress)
             ((2) in-progress)
             ((4) in-progress))
      (odd? ((1) (memo-value #t))
            ((1) in-progress)
            ((3) in-progress))
      (even? ((0) (memo-value #t))
             ((0) in-progress)
             ((2) in-progress)
             ((4) in-progress))
      (even? ((0) in-progress)
             ((2) in-progress)
             ((4) in-progress))
      (odd? ((1) in-progress)
            ((3) in-progress))
      (even? ((2) in-progress)
             ((4) in-progress))
      (odd? ((3) in-progress))
      (even? ((4) in-progress))
      (odd?)
      (even?))
     (#t #t))))



(test "evalo-even?/odd?-even?-memod-4a"
  (run* (q)
    (evalo `(letrec ((even? (memo-lambda even? (n)
                              (if (= n 0)
                                  #t
                                  (odd? (- n 1)))))
                     (odd? (lambda (n)
                              (if (= n 0)
                                  #f
                                  (even? (- n 1))))))
              (even? 4))
           q))
  '(#t))

(test "evalo-even?/odd?-even?-memod-4b"
  (run* (q)
    (evalo `(letrec ((even? (memo-lambda even? (n)
                              (if (= n 0)
                                  #t
                                  (odd? (- n 1)))))
                     (odd? (lambda (n)
                              (if (= n 0)
                                  #f
                                  (even? (- n 1))))))
              (list (even? 4) (even? 4)))
           q))
  '((#t #t)))

(test "evalo-even?/odd?-both-memod-4b-show-table"
  (run* (q)
    (fresh (tables-out val)
      (== (list tables-out val) q)
      (eval-expo `(letrec ((even? (memo-lambda even? (n)
                                    (if (= n 0)
                                        #t
                                        (odd? (- n 1)))))
                           (odd? (lambda (n)
                                   (if (= n 0)
                                       #f
                                       (even? (- n 1))))))
                    (list (even? 4) (even? 4)))
                 initial-env
                 initial-tables
                 tables-out
                 val)))
  '((((even? ((4) (memo-value #t))
             ((2) (memo-value #t))
             ((0) (memo-value #t))
             ((0) in-progress)
             ((2) in-progress)
             ((4) in-progress))
      (even? ((2) (memo-value #t))
             ((0) (memo-value #t))
             ((0) in-progress)
             ((2) in-progress)
             ((4) in-progress))
      (even? ((0) (memo-value #t))
             ((0) in-progress)
             ((2) in-progress)
             ((4) in-progress))
      (even? ((0) in-progress)
             ((2) in-progress)
             ((4) in-progress))
      (even? ((2) in-progress)
             ((4) in-progress))
      (even? ((4) in-progress))
      (even?))
     (#t #t))))

(test "evalo-even?/odd?-even?-memod-4c"
  (run* (q)
    (evalo `(letrec ((even? (memo-lambda even? (n)
                              (if (= n 0)
                                  #t
                                  (odd? (- n 1)))))
                     (odd? (lambda (n)
                              (if (= n 0)
                                  #f
                                  (even? (- n 1))))))
              (list (odd? 5) (odd? 5)))
           q))
  '((#t #t)))

(test "evalo-even?/odd?-both-memod-4c-show-table"
  (run* (q)
    (fresh (tables-out val)
      (== (list tables-out val) q)
      (eval-expo `(letrec ((even? (memo-lambda even? (n)
                                    (if (= n 0)
                                        #t
                                        (odd? (- n 1)))))
                           (odd? (lambda (n)
                                   (if (= n 0)
                                       #f
                                       (even? (- n 1))))))
                    (list (odd? 5) (odd? 5)))
                 initial-env
                 initial-tables
                 tables-out
                 val)))
  '((((even? ((4) (memo-value #t))
             ((2) (memo-value #t))
             ((0) (memo-value #t))
             ((0) in-progress)
             ((2) in-progress)
             ((4) in-progress))
      (even? ((2) (memo-value #t))
             ((0) (memo-value #t))
             ((0) in-progress)
             ((2) in-progress)
             ((4) in-progress))
      (even? ((0) (memo-value #t))
             ((0) in-progress)
             ((2) in-progress)
             ((4) in-progress))
      (even? ((0) in-progress)
             ((2) in-progress)
             ((4) in-progress))
      (even? ((2) in-progress)
             ((4) in-progress))
      (even? ((4) in-progress))
      (even?))
     (#t #t))))

(test "evalo-even?/odd?-even?-memod-4d"
  (run* (q)
    (evalo `(letrec ((even? (memo-lambda even? (n)
                              (if (= n 0)
                                  #t
                                  (odd? (- n 1)))))
                     (odd? (lambda (n)
                              (if (= n 0)
                                  #f
                                  (even? (- n 1))))))
              (list (odd? 5) (even? 4)))
           q))
  '((#t #t)))

(test "evalo-even?/odd?-both-memod-4d-show-table"
  (run* (q)
    (fresh (tables-out val)
      (== (list tables-out val) q)
      (eval-expo `(letrec ((even? (memo-lambda even? (n)
                                    (if (= n 0)
                                        #t
                                        (odd? (- n 1)))))
                           (odd? (lambda (n)
                                   (if (= n 0)
                                       #f
                                       (even? (- n 1))))))
                    (list (odd? 5) (even? 4)))
                 initial-env
                 initial-tables
                 tables-out
                 val)))
  '((((even? ((4) (memo-value #t))
             ((2) (memo-value #t))
             ((0) (memo-value #t))
             ((0) in-progress)
             ((2) in-progress)
             ((4) in-progress))
      (even? ((2) (memo-value #t))
             ((0) (memo-value #t))
             ((0) in-progress)
             ((2) in-progress)
             ((4) in-progress))
      (even? ((0) (memo-value #t))
             ((0) in-progress)
             ((2) in-progress)
             ((4) in-progress))
      (even? ((0) in-progress)
             ((2) in-progress)
             ((4) in-progress))
      (even? ((2) in-progress)
             ((4) in-progress))
      (even? ((4) in-progress))
      (even?))
     (#t #t))))



(test "evalo-even?/odd?-1"
  (run* (q)
    (evalo `(letrec ((even? (lambda (n)
                              (if (= n 0)
                                  #t
                                  (odd? (- n 1)))))
                     (odd? (lambda (n)
                              (if (= n 0)
                                  #f
                                  (even? (- n 1))))))
              (even? 3))
           q))
  '(#f))

(test "evalo-even?/odd?-2"
  (run* (q)
    (evalo `(letrec ((even? (lambda (n)
                              (if (= n 0)
                                  #t
                                  (odd? (- n 1)))))
                     (odd? (lambda (n)
                              (if (= n 0)
                                  #f
                                  (even? (- n 1))))))
              (even? 4))
           q))
  '(#t))

(test "evalo-even?/odd?-3a"
  (run 5 (q)
    (evalo `(letrec ((even? (lambda (n)
                              (if (= n 0)
                                  #t
                                  (odd? (- n 1)))))
                     (odd? (lambda (n)
                              (if (= n 0)
                                  #f
                                  (even? (- n 1))))))
              (even? ',q))
           #t))
  '(0 2 4 6 8))

(test "evalo-even?/odd?-3b"
  (run 5 (q)
    (evalo `(letrec ((even? (lambda (n)
                              (if (= n 0)
                                  #t
                                  (odd? (- n 1)))))
                     (odd? (lambda (n)
                              (if (= n 0)
                                  #f
                                  (even? (- n 1))))))
              (even? ,q))
           #t))
  '(0 2 '0 4 6))

(test "evalo-even?/odd?-4a"
  (run 5 (q)
    (evalo `(letrec ((even? (lambda (n)
                              (if (= n 0)
                                  #t
                                  (odd? (- n 1)))))
                     (odd? (lambda (n)
                              (if (= n 0)
                                  #f
                                  (even? (- n 1))))))
              (even? ',q))
           #f))
  '(1 3 5 7 9))

(test "evalo-even?/odd?-4b"
  (run 5 (q)
    (evalo `(letrec ((even? (lambda (n)
                              (if (= n 0)
                                  #t
                                  (odd? (- n 1)))))
                     (odd? (lambda (n)
                              (if (= n 0)
                                  #f
                                  (even? (- n 1))))))
              (even? ,q))
           #f))
  '(1 3 5 '1 7))



(test "evalo-simple-let-a"
  (run* (q)
    (evalo '(let ((foo (+ 1 2))) (* foo foo)) q))
  '(9))


#|
(test "evalo-assoc-1-a"
  (time
    (run* (q)
      (evalo `(letrec ((assoc (lambda (x ls)
                                (match ls
                                  [`() #f]
                                  [`((,y . ,v) . ,rest)
                                   (if (equal? x y)
                                       (cons y v)
                                       (assoc x rest))]))))
                (list (assoc 'z '((a . 3) (b . 4) (c . 5) (z . 6) (d . 7) (a . 8)))
                      (assoc 'w '((a . 3) (b . 4) (c . 5) (z . 6) (d . 7) (a . 8)))
                      (assoc 'a '((a . 3) (b . 4) (c . 5) (z . 6) (d . 7) (a . 8)))))
             q)))
  '(((z . 6) #f (a . 3))))
|#

(test "evalo-assoc-2-a"
  (time
    (run* (q)
      (evalo `(letrec ((assoc (lambda (x ls)
                                (if (null? ls)
                                    #f
                                    (if (equal? (car (car ls)) x)
                                        (car ls)
                                        (assoc x (cdr ls)))))))
                (list (assoc 'z '((a . 3) (b . 4) (c . 5) (z . 6) (d . 7) (a . 8)))
                      (assoc 'w '((a . 3) (b . 4) (c . 5) (z . 6) (d . 7) (a . 8)))
                      (assoc 'a '((a . 3) (b . 4) (c . 5) (z . 6) (d . 7) (a . 8)))))
             q)))
  '(((z . 6) #f (a . 3))))

(test "evalo-memo-lambda-1-a"
  (run* (q)
    (evalo `(list
             (lambda (x y z) (+ x y z))
             (memo-lambda foo (x y z) (+ x y z)))
           q))
  '(((closure
      (lambda (x y z) (+ x y z))
      ((val list closure (lambda x x) ()) (val not prim . not) (val equal? prim . equal?)
       (val symbol? prim . symbol?) (val cons prim . cons)
       (val null? prim . null?) (val car prim . car)
       (val cdr prim . cdr) (val + prim . +) (val - prim . -)
       (val * prim . *) (val / prim . /) (val = prim . =)
       (val != prim . !=) (val > prim . >) (val >= prim . >=)
       (val < prim . <) (val <= prim . <=)))
     (closure
      (memo-lambda foo (x y z) (+ x y z))
      ((val list closure (lambda x x) ()) (val not prim . not) (val equal? prim . equal?)
       (val symbol? prim . symbol?) (val cons prim . cons)
       (val null? prim . null?) (val car prim . car)
       (val cdr prim . cdr) (val + prim . +) (val - prim . -)
       (val * prim . *) (val / prim . /) (val = prim . =)
       (val != prim . !=) (val > prim . >) (val >= prim . >=)
       (val < prim . <) (val <= prim . <=))))))

(test "evalo-memo-lambda-2-a"
  (run* (q)
    (fresh (tables-out val)
      (== (list tables-out val) q)
      (eval-expo `(lambda (x) x) initial-env initial-tables tables-out val)))
  '((()
     (closure
      (lambda (x) x)
      ((val list closure (lambda x x) ()) (val not prim . not) (val equal? prim . equal?)
       (val symbol? prim . symbol?) (val cons prim . cons)
       (val null? prim . null?) (val car prim . car)
       (val cdr prim . cdr) (val + prim . +) (val - prim . -)
       (val * prim . *) (val / prim . /) (val = prim . =)
       (val != prim . !=) (val > prim . >) (val >= prim . >=)
       (val < prim . <) (val <= prim . <=))))))

(test "evalo-memo-lambda-3-a"
  (run* (q)
    (fresh (tables-out val)
      (== (list tables-out val) q)
      (eval-expo `(memo-lambda foo (x) x) initial-env initial-tables tables-out val)))
  '((((foo))
     (closure
      (memo-lambda foo (x) x)
      ((val list closure (lambda x x) ()) (val not prim . not) (val equal? prim . equal?)
       (val symbol? prim . symbol?) (val cons prim . cons)
       (val null? prim . null?) (val car prim . car)
       (val cdr prim . cdr) (val + prim . +) (val - prim . -)
       (val * prim . *) (val / prim . /) (val = prim . =)
       (val != prim . !=) (val > prim . >) (val >= prim . >=)
       (val < prim . <) (val <= prim . <=))))))

(test "evalo-memo-lambda-3-b"
  (run* (q)
    (fresh (tables-out val)
      (== (list tables-out val) q)
      (eval-expo `(list (lambda (x) x)
                        (memo-lambda foo (x) x)
                        (lambda (x) x)
                        (memo-lambda bar (x) x)
                        (lambda (x) x))
                 initial-env
                 initial-tables
                 tables-out
                 val)))
  '((((bar) (foo))
   ((closure
      (lambda (x) x)
      ((val list closure (lambda x x) ()) (val not prim . not) (val equal? prim . equal?)
        (val symbol? prim . symbol?) (val cons prim . cons)
        (val null? prim . null?) (val car prim . car)
        (val cdr prim . cdr) (val + prim . +) (val - prim . -)
        (val * prim . *) (val / prim . /) (val = prim . =)
        (val != prim . !=) (val > prim . >) (val >= prim . >=)
        (val < prim . <) (val <= prim . <=)))
     (closure
       (memo-lambda foo (x) x)
       ((val list closure (lambda x x) ()) (val not prim . not) (val equal? prim . equal?)
         (val symbol? prim . symbol?) (val cons prim . cons)
         (val null? prim . null?) (val car prim . car)
         (val cdr prim . cdr) (val + prim . +) (val - prim . -)
         (val * prim . *) (val / prim . /) (val = prim . =)
         (val != prim . !=) (val > prim . >) (val >= prim . >=)
         (val < prim . <) (val <= prim . <=)))
     (closure
       (lambda (x) x)
       ((val list closure (lambda x x) ()) (val not prim . not) (val equal? prim . equal?)
         (val symbol? prim . symbol?) (val cons prim . cons)
         (val null? prim . null?) (val car prim . car)
         (val cdr prim . cdr) (val + prim . +) (val - prim . -)
         (val * prim . *) (val / prim . /) (val = prim . =)
         (val != prim . !=) (val > prim . >) (val >= prim . >=)
         (val < prim . <) (val <= prim . <=)))
     (closure
       (memo-lambda bar (x) x)
       ((val list closure (lambda x x) ()) (val not prim . not) (val equal? prim . equal?)
         (val symbol? prim . symbol?) (val cons prim . cons)
         (val null? prim . null?) (val car prim . car)
         (val cdr prim . cdr) (val + prim . +) (val - prim . -)
         (val * prim . *) (val / prim . /) (val = prim . =)
         (val != prim . !=) (val > prim . >) (val >= prim . >=)
         (val < prim . <) (val <= prim . <=)))
     (closure
       (lambda (x) x)
       ((val list closure (lambda x x) ()) (val not prim . not) (val equal? prim . equal?)
         (val symbol? prim . symbol?) (val cons prim . cons)
         (val null? prim . null?) (val car prim . car)
         (val cdr prim . cdr) (val + prim . +) (val - prim . -)
         (val * prim . *) (val / prim . /) (val = prim . =)
         (val != prim . !=) (val > prim . >) (val >= prim . >=)
         (val < prim . <) (val <= prim . <=)))))))

(test "evalo-memo-lambda-4-a"
  (run* (q)
    (evalo `((memo-lambda foo (b) 5) 'there)
           q))
  '(5))

(test "evalo-memo-lambda-5-a"
  (run* (q)
    (evalo `((memo-lambda foo (b) b) 'there)
           q))
  '(there))

(test "evalo-memo-lambda-6-a"
  (run* (q)
    (evalo `(list
              ((lambda (a) a) 'hi)
              ((memo-lambda foo (b) b) 'there))
           q))
  '((hi there)))

(test "evalo-memo-lambda-6-b"
  (run* (q)
    (fresh (tables-out val)
      (== (list tables-out val) q)
      (eval-expo `(list
                    ((lambda (a) a) 'hi)
                    ((memo-lambda foo (b) b) 'there))
                 initial-env
                 initial-tables
                 tables-out
                 val)))
  '((((foo . (((there) (memo-value there))
              ((there) in-progress)))
      (foo . (((there) in-progress)))
      (foo . ()))
     (hi there))))

#|
;; need to add letrec version!  and need to add test-diverge

(test-diverge "evalo-memo-lambda-7-a"
  (run* (q)
    (fresh (tables-out val)
      (== (list tables-out val) q)
      (eval-expo `(letrec ((f (lambda (x)
                                (f x))))
                    (f 'catte))
                 initial-env
                 initial-tables
                 tables-out
                 val))))

(test "evalo-memo-lambda-7-b"
  (run* (q)
    (fresh (tables-out val)
      (== (list tables-out val) q)
      (eval-expo `(letrec ((f (memo-lambda foo (x)
                                (f x))))
                    (f 'catte))
                 initial-env
                 initial-tables
                 tables-out
                 val)))
  '())
|#

(test "evalo-memo-lambda-8-a"
  (run* (q)
    (fresh (tables-out val)
      (== (list tables-out val) q)
      (eval-expo `(let ((square-mem (memo-lambda square (x)
                                      (* x x))))
                    (square-mem 3))
                 initial-env
                 initial-tables
                 tables-out
                 val)))
  '((((square . (((3) (memo-value 9))
                 ((3) in-progress)))
      (square . (((3) in-progress)))
      (square . ()))
     9)))

(test "evalo-memo-lambda-8-b"
  (run* (q)
    (fresh (tables-out val)
      (== (list tables-out val) q)
      (eval-expo `(let ((square-mem (memo-lambda square (x)
                                      (* x x))))
                    (list (square-mem 3)                          
                          (square-mem 3)))
                 initial-env
                 initial-tables
                 tables-out
                 val)))
  '((((square . (((3) (memo-value 9))
                 ((3) in-progress)))
      (square . (((3) in-progress)))
      (square . ()))
     (9 9))))

(test "evalo-memo-lambda-8-c"
  (run* (q)
    (fresh (tables-out val)
      (== (list tables-out val) q)
      (eval-expo `(let ((square-mem (memo-lambda square (x)
                                      (* x x))))
                    (list (square-mem 3)
                          (square-mem 4)
                          (square-mem 3)))
                 initial-env
                 initial-tables
                 tables-out
                 val)))
  '((((square . (((4) (memo-value 16))
                 ((4) in-progress)
                 ((3) (memo-value 9))
                 ((3) in-progress)))
      (square . (((4) in-progress)
                 ((3) (memo-value 9))
                 ((3) in-progress)))
      (square . (((3) (memo-value 9))
                 ((3) in-progress)))
      (square . (((3) in-progress)))
      (square . ()))
     (9 16 9))))



;; old comment:  takes a while
;; Now it seems to take a long time, indeed!
(time
  (test "evalo-fac-synthesis-hole-1-reversed-examples"
    (run 1 (q)
      (evalo `(letrec ((fac
                        (lambda (n)
                          (if (< n 0) #f
                              (if (= n 0) 1
                                  (* n (,q (- n 1))))))))
                (list
                 (fac 3)
                 (fac 2)
                 (fac 1)
                 (fac 0)))
             '(6 2 1 1)))
  '(fac)))




#!eof

;;; takes about a minute on Will's laptop
(test "evalo-fib-1-a"
  (time
    (run* (q)
      (evalo `(letrec ((fib (lambda (n)
                              (if (= n 0)
                                  0
                                  (if (= n 1)
                                      1
                                      (+ (fib (- n 1)) (fib (- n 2))))))))
                (fib 6))
             q)))
  '(8))



;;; symbolic execution example from slide 7 of Stephen Chong's slides
;;; on symbolic execution (contains contents from Jeff Foster's
;;; slides)
;;;
;;; http://www.seas.harvard.edu/courses/cs252/2011sp/slides/Lec13-SymExec.pdf

;;;  1. int a = α, b = β, c = γ
;;;  2.             // symbolic
;;;  3. int x = 0, y = 0, z = 0;
;;;  4. if (a) {
;;;  5.   x = -2;
;;;  6. }
;;;  7. if (b < 5) {
;;;  8.   if (!a && c)  { y = 1; }
;;;  9.   z = 2;
;;; 10. }
;;; 11. assert(x+y+z!=3)

(test "evalo-symbolic-execution-a"
  (run 1 (q)
    (fresh (alpha beta gamma)
      (== (list alpha beta gamma) q)
      (evalo `(let ((a ',alpha))
                (let ((b ',beta))
                  (let ((c ',gamma))
                    (let ((x (if (!= a 0)
                                 -2
                                 0)))
                      (let ((y (if (and (< b 5) (= a 0) (!= c 0))
                                   1
                                   0)))
                        (let ((z (if (< b 5)
                                     2
                                     0)))
                          (if (!= (+ x (+ y z)) 3)
                              'good
                              'bad)))))))
             'bad)))  
  '((0 4 1)))

(test "evalo-symbolic-execution-b"
  (run 8 (q)
    (fresh (alpha beta gamma)
      (== (list alpha beta gamma) q)
      (evalo `(let ((a ',alpha))
                (let ((b ',beta))
                  (let ((c ',gamma))
                    (let ((x (if (!= a 0)
                                 -2
                                 0)))
                      (let ((y (if (and (< b 5) (= a 0) (!= c 0))
                                   1
                                   0)))
                        (let ((z (if (< b 5)
                                     2
                                     0)))
                          (if (!= (+ x (+ y z)) 3)
                              'good
                              'bad)))))))
             'bad)))  
  '((0 4 1)
    (0 0 -1)
    (0 -1 -2)
    (0 -2 -3)
    (0 -3 -4)
    (0 -4 -5)
    (0 -5 -6)
    (0 -6 -7)))


(test "evalo-symbolic-execution-c"
  (run 8 (q)
    (fresh (alpha beta gamma vals)
      (== (list alpha beta gamma vals) q)
      (evalo `(let ((a ',alpha))
                (let ((b ',beta))
                  (let ((c ',gamma))
                    (let ((x (if (!= a 0)
                                 -2
                                 0)))
                      (let ((y (if (and (< b 5) (= a 0) (!= c 0))
                                   1
                                   0)))
                        (let ((z (if (< b 5)
                                     2
                                     0)))
                          (if (!= (+ x (+ y z)) 3)
                              'good
                              (list 'bad x y z))))))))
             `(bad . ,vals))))  
  '((0 4 1 (0 1 2))
    (0 0 -1 (0 1 2))
    (0 -1 -2 (0 1 2))
    (0 -2 -3 (0 1 2))
    (0 -3 -4 (0 1 2))
    (0 -4 -5 (0 1 2))
    (0 -5 -6 (0 1 2))
    (0 -6 -7 (0 1 2))))

(test "evalo-symbolic-execution-d"
  (run 1 (q)
    (fresh (alpha beta gamma vals)
      (z/assert `(not (= 0 ,beta)))
      (== (list alpha beta gamma vals) q)
      (evalo `(let ((a ',alpha))
                (let ((b ',beta))
                  (let ((c ',gamma))
                    (let ((x (if (!= a 0)
                                 -2
                                 0)))
                      (let ((y (if (and (< b 5) (= a 0) (!= c 0))
                                   1
                                   0)))
                        (let ((z (if (< b 5)
                                     2
                                     0)))
                          (if (!= (+ x (+ y z)) 3)
                              'good
                              (list 'bad x y z))))))))
             `(bad . ,vals))))  
  '((0 1 1 (0 1 2))))

(test "evalo-symbolic-execution-e"
  (run 1 (q)
    (fresh (alpha beta gamma vals)
      (z/assert `(not (= 0 ,alpha)))
      (== (list alpha beta gamma vals) q)
      (evalo `(let ((a ',alpha))
                (let ((b ',beta))
                  (let ((c ',gamma))
                    (let ((x (if (!= a 0)
                                 -2
                                 0)))
                      (let ((y (if (and (< b 5) (= a 0) (!= c 0))
                                   1
                                   0)))
                        (let ((z (if (< b 5)
                                     2
                                     0)))
                          (if (!= (+ x (+ y z)) 3)
                              'good
                              (list 'bad x y z))))))))
             `(bad . ,vals))))
  '())

;;;

(test "evalo-symbolic-execution-f"
  (run 8 (q)
    (fresh (alpha beta gamma vals)
      (== (list alpha beta gamma vals) q)
      (evalo `((lambda (a b c)
                 (let ((x (if (!= a 0)
                              -2
                              0)))
                   (let ((y (if (and (< b 5) (= a 0) (!= c 0))
                                1
                                0)))
                     (let ((z (if (< b 5)
                                  2
                                  0)))
                       (if (!= (+ x (+ y z)) 3)
                           'good
                           (list 'bad x y z))))))
               ',alpha ',beta ',gamma)
             `(bad . ,vals))))  
  '((0 4 1 (0 1 2))
    (0 0 -1 (0 1 2))
    (0 -1 -2 (0 1 2))
    (0 -2 -3 (0 1 2))
    (0 -3 -4 (0 1 2))
    (0 -4 -5 (0 1 2))
    (0 -5 -6 (0 1 2))
    (0 -6 -7 (0 1 2))))

(test "evalo-symbolic-execution-g"
  (run 8 (q)
    (fresh (alpha beta gamma vals)
      (z/assert `(not (= 0 ,beta)))
      (== (list alpha beta gamma vals) q)
      (evalo `((lambda (a b c)
                 (let ((x (if (!= a 0)
                              -2
                              0)))
                   (let ((y (if (and (< b 5) (= a 0) (!= c 0))
                                1
                                0)))
                     (let ((z (if (< b 5)
                                  2
                                  0)))
                       (if (!= (+ x (+ y z)) 3)
                           'good
                           (list 'bad x y z))))))
               ',alpha ',beta ',gamma)
             `(bad . ,vals))))  
  '((0 1 1 (0 1 2))
    (0 -1 -1 (0 1 2))
    (0 -2 -2 (0 1 2))
    (0 -3 -3 (0 1 2))
    (0 -4 -4 (0 1 2))
    (0 -5 -5 (0 1 2))
    (0 -6 -6 (0 1 2))
    (0 2 -7 (0 1 2))))

(test "evalo-symbolic-execution-h"
  (run* (q)
    (fresh (alpha beta gamma vals)
      (z/assert `(not (= 0 ,alpha)))
      (== (list alpha beta gamma vals) q)
      (evalo `((lambda (a b c)
                 (let ((x (if (!= a 0)
                              -2
                              0)))
                   (let ((y (if (and (< b 5) (= a 0) (!= c 0))
                                1
                                0)))
                     (let ((z (if (< b 5)
                                  2
                                  0)))
                       (if (!= (+ x (+ y z)) 3)
                           'good
                           (list 'bad x y z))))))
               ',alpha ',beta ',gamma)
             `(bad . ,vals))))  
  '())

;;;

(test "evalo-symbolic-execution-i"
  (run 8 (q)
    (fresh (alpha beta gamma vals)
      (== (list alpha beta gamma vals) q)
      (evalo `((lambda (a b c)
                 ((lambda (x y z)
                    (if (!= (+ x (+ y z)) 3)
                        'good
                        (list 'bad x y z)))
                  ;; x
                  (if (!= a 0)
                      -2
                      0)
                  ;; y
                  (if (and (< b 5) (= a 0) (!= c 0))
                      1
                      0)
                  ;; z
                  (if (< b 5)
                      2
                      0)))
               ',alpha ',beta ',gamma)
             `(bad . ,vals))))
  '((0 4 1 (0 1 2))
    (0 0 -1 (0 1 2))
    (0 -1 -2 (0 1 2))
    (0 -2 -3 (0 1 2))
    (0 -3 -4 (0 1 2))
    (0 -4 -5 (0 1 2))
    (0 -5 -6 (0 1 2))
    (0 -6 -7 (0 1 2))))

(test "evalo-symbolic-execution-j"
  (run 8 (q)
    (fresh (alpha beta gamma vals)
      (z/assert `(not (= 0 ,beta)))
      (== (list alpha beta gamma vals) q)
      (evalo `((lambda (a b c)
                 ((lambda (x y z)
                    (if (!= (+ x (+ y z)) 3)
                        'good
                        (list 'bad x y z)))
                  ;; x
                  (if (!= a 0)
                      -2
                      0)
                  ;; y
                  (if (and (< b 5) (= a 0) (!= c 0))
                      1
                      0)
                  ;; z
                  (if (< b 5)
                      2
                      0)))
               ',alpha ',beta ',gamma)
             `(bad . ,vals))))
  '((0 1 1 (0 1 2))
    (0 -1 -1 (0 1 2))
    (0 -2 -2 (0 1 2))
    (0 -3 -3 (0 1 2))
    (0 -4 -4 (0 1 2))
    (0 -5 -5 (0 1 2))
    (0 -6 -6 (0 1 2))
    (0 2 -7 (0 1 2))))

(test "evalo-symbolic-execution-k"
  (run* (q)
    (fresh (alpha beta gamma vals)
      (z/assert `(not (= 0 ,alpha)))
      (== (list alpha beta gamma vals) q)
      (evalo `((lambda (a b c)
                 ((lambda (x y z)
                    (if (!= (+ x (+ y z)) 3)
                        'good
                        (list 'bad x y z)))
                  ;; x
                  (if (!= a 0)
                      -2
                      0)
                  ;; y
                  (if (and (< b 5) (= a 0) (!= c 0))
                      1
                      0)
                  ;; z
                  (if (< b 5)
                      2
                      0)))
               ',alpha ',beta ',gamma)
             `(bad . ,vals))))
  '())

#!eof

;;; old tests:

(test "evalo-1"
  (run* (q)
    (evalo '(+ 1 2) q))
  '(3))

(test "evalo-backwards-1"
  (run* (q)
    (evalo `(+ 0 ',q) 3))
  '(3))

(test "evalo-bop-1"
  (run* (q)
    (evalo `((lambda (n) (< n 0)) 0) q))
  '(#f))

(test "evalo-2"
  (run* (q)
    (evalo `(((lambda (f)
                (lambda (n) (if (< n 0) #f
                           (if (= n 0) 1
                               (* n (f (- n 1)))))))
              (lambda (x) 1))
             2)
           q))
  '(2))


(test "evalo-fac-6"
  (run* (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (- n 1))))))))
              (fac 6))
           q))
  '(720))

;; slowish
(test "evalo-fac-9"
  (run* (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (- n 1))))))))
              (fac 9))
           q))
  '(362880))

(test "evalo-backwards-fac-6"
  (run 1 (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (- n 1))))))))
              (fac ,q))
           720))
  '(6))

;; remember the quote!
(test "evalo-backwards-fac-quoted-6"
  (run* (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (- n 1))))))))
              (fac ',q))
           720))
  '(6))


;; slowish
(test "evalo-backwards-fac-9"
  (run 1 (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (- n 1))))))))
              (fac ,q))
           362880))
  '(9))

;; remember the quote!
(test "evalo-backwards-fac-quoted-9"
  (run* (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (- n 1))))))))
              (fac ',q))
           362880))
  '(9))


;; slowish
(test "evalo-fac-table"
  (run* (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (- n 1))))))))
              (list
               (fac 0)
               (fac 1)
               (fac 2)
               (fac 3)))
           q))
  '((1 1 2 6)))

(test "evalo-fac-synthesis-hole-0"
  (run* (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) ',q
                                (* n (fac (- n 1))))))))
              (list
               (fac 0)
               (fac 1)
               (fac 2)
               (fac 3)))
           '(1 1 2 6)))
  '(1))

(test "evalo-fac-synthesis-hole-1"
  (run 1 (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (,q (- n 1))))))))
              (list
               (fac 0)
               (fac 1)
               (fac 2)
               (fac 3)))
           '(1 1 2 6)))
  '(fac))

;; takes a while
(test "evalo-fac-synthesis-hole-1-reversed-examples"
  (run 1 (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (,q (- n 1))))))))
              (list
               (fac 3)
               (fac 2)
               (fac 1)
               (fac 0)))
           '(6 2 1 1)))
  '(fac))

(test "evalo-fac-synthesis-hole-2"
  (run 1 (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (- ,q 1))))))))
              (list
               (fac 0)
               (fac 1)
               (fac 2)
               (fac 3)))
           '(1 1 2 6)))
  '(n))

(test "evalo-fac-synthesis-hole-3"
  (run 1 (q)
    (fresh (r s)
      (== (list r s) q)
      (evalo `(letrec ((fac
                        (lambda (n)
                          (if (< n 0) #f
                              (if (= n 0) 1
                                  (* n (fac (- ,r ,s))))))))
                (list
                 (fac 0)
                 (fac 1)
                 (fac 2)
                 (fac 3)))
             '(1 1 2 6))))
  '((n 1)))

;; slow, even with the 'symbolo' constraint on 'q'
(test "evalo-fac-synthesis-hole-4"
  (run 1 (q)
    (symbolo q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (,q n 1))))))))
              (list
               (fac 0)
               (fac 1)
               (fac 2)
               (fac 3)))
           '(1 1 2 6)))
  '(-))


(test "evalo-division-using-multiplication-0"
  (run* (q)
    (evalo `(* 3 ',q) 6))
  '(2))

(test "evalo-division-using-multiplication-1"
  (run* (q)
    (evalo `(* 4 ',q) 6))
  '())

(test "evalo-division-using-multiplication-2"
  (run* (q)
    (evalo `(* 3 ',q) 18))
  '(6))

(test "evalo-many-0"
  (run* (q)
    (fresh (x y)
      (evalo `(* ',x ',y) 6)
      (== q (list x y))))
  '((6 1) (1 6) (-1 -6) (-2 -3)
    (-3 -2) (-6 -1) (2 3) (3 2)))

(test "many-1"
  (run* (q)
    (fresh (x y)
      (evalo `(+ (* ',x ',y) (* ',x ',y)) 6)
      (== q (list x y))))
  '((3 1) (1 3) (-1 -3) (-3 -1)))

(test "many-2"
  (run* (q)
    (fresh (x y)
      (evalo `(* (* ',x ',y) 2) 6)
      (== q (list x y))))
  '((3 1) (1 3) (-1 -3) (-3 -1)))

;;; time to get interesting!

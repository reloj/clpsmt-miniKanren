;;; RSA crypto algorithm in miniKanren + CLP(SMT)

;; Examples taken from http://doctrina.org/How-RSA-Works-With-Examples.html

(load "mk.scm")
(load "z3-driver.scm")
(load "full-interp-with-let.scm")
(load "test-check.scm")

;; test 'begin' extension to evalo
(test "evalo-begin-1"
  (run* (q)
    (evalo `(begin
              (cons 3 4)
              (* 5 6))            
           q))
  '(30))

(test "evalo-begin-2"
  (run* (q)
    (evalo `(begin
              (* 5 6))            
           q))
  '(30))

(test "evalo-begin-3"
  (run* (q)
    (evalo `(begin
              (cons 3 4)
              (+ 2 3)
              (* 5 6))            
           q))
  '(30))


;; test 'assert' extension to evalo
(test "evalo-assert-0"
  (run* (q)
    (evalo `(assert #t)
           q))
  '(_.0))

(test "evalo-assert-1"
  (run* (q)
    (evalo `(begin
              (assert #t)
              (* 5 6))
           q))
  '(30))

(test "evalo-assert-2"
  (run* (q)
    (evalo `(begin
              (assert (<= 4 (* 2 3)))
              (* 5 6))
           q))
  '(30))

(test "evalo-assert-3"
  (run* (q)
    (evalo `(begin
              (assert (<= 7 (* 2 3)))
              (* 5 6))
           q))
  '())


;; test 'let' extension to evalo
(test "evalo-let-1"
  (run* (q)
    (evalo `(let ((y 5))
              y)            
           q))
  '(5))

(test "evalo-let-2"
  (run* (q)
    (evalo `(let ((y 5)
                  (z 6))
              z)
           q))
  '(6))

(test "evalo-let-3"
  (run* (q)
    (evalo `(let ((y 5)
                  (z 6))
              (* y z))
           q))
  '(30))

(test "evalo-let-4"
  (run* (q)
    (evalo `(let ((y 5)
                  (z 6))
              (list y z))
           q))
  '((5 6)))

(test "evalo-let-5"
  (run* (q)
    (evalo `(let ((y (+ 2 3))
                  (z (* 4 4)))
              (list y z))
           q))
  '((5 16)))


;; test 'mod'
(test "evalo-mod-1"
  (run* (q)
    (evalo `(mod 17 3)
           q))
  '(2))

(test "evalo-mod-2"
  (run* (q)
    (evalo `(mod 721 120)
           q))
  '(1))

(test "evalo-mod-3"
  (run* (q)
    (evalo `(= (mod 721 120) 1)
           q))
  '(#t))

(test "evalo-mod-4"
  (run* (q)
    (evalo `(= (mod (* 7 103) 120) 1)
           #t))
  '(_.0))

(test "evalo-=-backwards-1"
  (run 1 (q)
    (evalo `(= ,q 1)
           #t))
  '(1))

(test "evalo-mod-1-backwards-1"
  (run 1 (q)
    (evalo `(mod ,q 3)
           2))
  '(2))

;; Y NO 5????  Interleaaaavvveeee plzzzzz!!
(test "evalo-mod-1-backwards-2"
  (run 20 (q)
    (evalo `(mod ,q 3)
           2))
  '(2 -1 -4 -7 -10 -13 -16 -19 -22 -25 -28 -31 -34 -37 -40 -43
   -46 -49 -52 -55))

(test "evalo-mod-1-backwards-2"
  (run 3 (q)
    (evalo `(and (<= 0 ,q) (mod ,q 3))
           2))
  '(2 5 8))

(test "evalo-mod-3-backwards-1"
  (run 1 (q)
    (evalo `(= (mod ,q 120) 1)
           #t))
  '(1))

(test "evalo-mod-4-backwards-1"
  (run 1 (q)
    (evalo `(= (mod (* 7 ,q) 120) 1)
           #t))
  '(-17))

(test "evalo-mod-4-backwards-2"
  (run 1 (q)
    (evalo `(and (<= 0 ,q) (= (mod (* 7 ,q) 120) 1))
           #t))
  '(103))

;;; RSA time!

;; use SMT constraints to calculate d, instead of explicitly using the
;; Extended Euclidean Algorithm
(time
 (test "evalo-rsa-small-nums"
   (run 1 (k)
     (fresh (d?)
       (evalo `(let ((p 11)
                     (q 13))
                 (let ((n (* p q))
                       (phi (* (- p 1) (- q 1))))
                   (let ((e 7))
                     (let ((d ,d?))
                       (let ((public-key (cons e n)))
                         (list (and (<= 0 ,d?)
                                    (= (mod (* e ,d?) phi) 1))
                               n
                               phi
                               public-key
                               d))))))
              `(#t . ,k))))
   '((143 120 (7 . 143) 103))))

(time
 (test "evalo-rsa-small-nums-assert"
   (run 1 (k)
     (fresh (d?)
       (evalo `(let ((p 11)
                     (q 13))
                 (let ((n (* p q))
                       (phi (* (- p 1) (- q 1))))
                   (let ((e 7))
                     (let ((d ,d?))
                       (let ((public-key (cons e n)))                         
                         (begin
                           (assert (<= 0 ,d?))
                           (assert (= (mod (* e ,d?) phi) 1))
                           (list n
                                 phi
                                 public-key
                                 d)))))))
              k)))
   '((143 120 (7 . 143) 103))))

;;; hmmm!  maybe not so fast using big nums!
;;; aka, "I've made a terrible mistake!"
#|
;; use SMT constraints to calculate d, instead of explicitly using the
;; Extended Euclidean Algorithm
(time
 (test "evalo-rsa-big-nums"
   (run 1 (k)
     (fresh (d?)
       (evalo `(let ((p 12131072439211271897323671531612440428472427633701410925634549312301964373042085619324197365322416866541017057361365214171711713797974299334871062829803541)
                     (q 12027524255478748885956220793734512128733387803682075433653899983955179850988797899869146900809131611153346817050832096022160146366346391812470987105415233))
                 (let ((n (* p q))
                       (phi (* (- p 1) (- q 1))))
                   (let ((e 65537))
                     (let ((d ,d?))
                       (let ((public-key (cons e n)))
                         (list (and (<= 0 ,d?)
                                    (= (mod (* e ,d?) phi) 1))
                               n
                               phi
                               public-key
                               d))))))
              `(#t . ,k))))
   '??))
|#

;; n = p * q, where p and q are given
(time
 (test "evalo-rsa-mult-1"
   (run* (k)
     (evalo `(let ((p 12131072439211271897323671531612440428472427633701410925634549312301964373042085619324197365322416866541017057361365214171711713797974299334871062829803541)
                   (q 12027524255478748885956220793734512128733387803682075433653899983955179850988797899869146900809131611153346817050832096022160146366346391812470987105415233))
               (let ((n (* p q)))
                 n))            
            k))
   '(145906768007583323230186939349070635292401872375357164399581871019873438799005358938369571402670149802121818086292467422828157022922076746906543401224889672472407926969987100581290103199317858753663710862357656510507883714297115637342788911463535102712032765166518411726859837988672111837205085526346618740053)))


;; n = p * q, where p and n are given
(time
 (test "evalo-rsa-mult-1-backwards"
   (run* (k)
     (evalo `(let ((p 12131072439211271897323671531612440428472427633701410925634549312301964373042085619324197365322416866541017057361365214171711713797974299334871062829803541)
                   (q 12027524255478748885956220793734512128733387803682075433653899983955179850988797899869146900809131611153346817050832096022160146366346391812470987105415233))
               (let ((n (* p ',k))) ;; dont forget the quote!
                 n))
            145906768007583323230186939349070635292401872375357164399581871019873438799005358938369571402670149802121818086292467422828157022922076746906543401224889672472407926969987100581290103199317858753663710862357656510507883714297115637342788911463535102712032765166518411726859837988672111837205085526346618740053))
   '(12027524255478748885956220793734512128733387803682075433653899983955179850988797899869146900809131611153346817050832096022160146366346391812470987105415233)))


(time
 (test "evalo-rsa-mult-2"
   (run* (k)
     (evalo `(let ((p 12131072439211271897323671531612440428472427633701410925634549312301964373042085619324197365322416866541017057361365214171711713797974299334871062829803541)
                   (q 12027524255478748885956220793734512128733387803682075433653899983955179850988797899869146900809131611153346817050832096022160146366346391812470987105415233))
               (let ((n (* p q))
                     (phi (* (- p 1) (- q 1))))
                 (list n phi)))
            k))
   '((145906768007583323230186939349070635292401872375357164399581871019873438799005358938369571402670149802121818086292467422828157022922076746906543401224889672472407926969987100581290103199317858753663710862357656510507883714297115637342788911463535102712032765166518411726859837988672111837205085526346618740053
      145906768007583323230186939349070635292401872375357164399581871019873438799005358938369571402670149802121818086292467422828157022922076746906543401224889648313811232279966317301397777852365301547848273478871297222058587457152891606459269718119268971163555070802643999529549644116811947516513938184296683521280))))

(time
 (test "evalo-rsa-mult-3"
   (run* (k)
     (evalo `(let ((p 12131072439211271897323671531612440428472427633701410925634549312301964373042085619324197365322416866541017057361365214171711713797974299334871062829803541)
                   (q 12027524255478748885956220793734512128733387803682075433653899983955179850988797899869146900809131611153346817050832096022160146366346391812470987105415233))
               (let ((n (* p q))
                     (phi (* (- p 1) (- q 1))))
                 (let ((e 65537))
                   (let ((public-key (cons e n)))
                     (list n phi public-key)))))
            k))
   '((145906768007583323230186939349070635292401872375357164399581871019873438799005358938369571402670149802121818086292467422828157022922076746906543401224889672472407926969987100581290103199317858753663710862357656510507883714297115637342788911463535102712032765166518411726859837988672111837205085526346618740053
      145906768007583323230186939349070635292401872375357164399581871019873438799005358938369571402670149802121818086292467422828157022922076746906543401224889648313811232279966317301397777852365301547848273478871297222058587457152891606459269718119268971163555070802643999529549644116811947516513938184296683521280
      (65537 . 145906768007583323230186939349070635292401872375357164399581871019873438799005358938369571402670149802121818086292467422828157022922076746906543401224889672472407926969987100581290103199317858753663710862357656510507883714297115637342788911463535102712032765166518411726859837988672111837205085526346618740053)))))

(time
 (test "evalo-rsa-mult-3-simple-synthesis-1"
   (run 1 (k)
     (symbolo k)
     (evalo `(let ((p 12131072439211271897323671531612440428472427633701410925634549312301964373042085619324197365322416866541017057361365214171711713797974299334871062829803541)
                   (q 12027524255478748885956220793734512128733387803682075433653899983955179850988797899869146900809131611153346817050832096022160146366346391812470987105415233))
               (let ((n (* p q))
                     (phi (* (- ,k 1) (- q 1))))
                 (let ((e 65537))
                   (let ((public-key (cons e n)))
                     (list n phi public-key)))))
            '(145906768007583323230186939349070635292401872375357164399581871019873438799005358938369571402670149802121818086292467422828157022922076746906543401224889672472407926969987100581290103199317858753663710862357656510507883714297115637342788911463535102712032765166518411726859837988672111837205085526346618740053
              145906768007583323230186939349070635292401872375357164399581871019873438799005358938369571402670149802121818086292467422828157022922076746906543401224889648313811232279966317301397777852365301547848273478871297222058587457152891606459269718119268971163555070802643999529549644116811947516513938184296683521280
              (65537 . 145906768007583323230186939349070635292401872375357164399581871019873438799005358938369571402670149802121818086292467422828157022922076746906543401224889672472407926969987100581290103199317858753663710862357656510507883714297115637342788911463535102712032765166518411726859837988672111837205085526346618740053))))
   '(p)))


#!eof

(time
 (test "evalo-backwards-fac-quoted-6"
   (run* (q)
     (evalo `(letrec ((fac
                       (lambda (n)
                         (if (< n 0) #f
                             (if (= n 0) 1
                                 (* n (fac (- n 1))))))))
               (fac ',q))
            720))
   '(6)))

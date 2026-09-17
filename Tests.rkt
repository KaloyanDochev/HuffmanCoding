(load "main.rkt")
(define l '(2 #t 5 5 5 5 2 5 1 #t #f))
(define freqList (frequencyList l equal? '()))
(define frequencyTest
      (equal? (frequencyList l equal? '()) (list(cons 2  2) (cons #t 2) (cons 5  5) (cons 1  1) (cons #f  1)))
  )
(define leafs (leafList (frequencyList l equal? '())))
;(((2 . 2) () ()) ((2 . #t) () ()) ((5 . 5) () ()) ((1 . 1) () ()) ((1 . #f) () ()))

(define sortedLeafs (sortTrees leafs))
;(((1 . 1) () ()) ((1 . #f) () ()) ((2 . 2) () ()) ((2 . #t) () ()) ((5 . 5) () ()))

(define tree
  (if(null? sortedLeafs)
     '()
     (car(leafsToTree sortedLeafs)))
  )

;((11) ((5 . 5) () ()) ((6) ((2 . #t) () ()) ((4) ((2) ((1 . 1) () ()) ((1 . #f) () ())) ((2 . 2) () ()))))

(define binary (treeToBinary tree l equal?))
;(#\1 #\1 #\1 (2) #\1 #\0 (#t) #\0 (5) #\0 (5) #\0 (5) #\0 (5) #\1 #\1 #\1 (2)#\0 (5)#\1 #\1 #\0 #\0 (1) #\1 #\0 (#t) #\1 #\1 #\0 #\1(#f))

;2 - 111 #t - 10 5 - 0 1 - 1100 #f 1101
(define 5code (symbolToBinary tree 5 equal? '()))
(define 1code (symbolToBinary tree 1 equal? '()))
(define 2code (symbolToBinary tree 2 equal? '()))
(define fcode (symbolToBinary tree #f equal? '()))
(define tcode (symbolToBinary tree #t equal? '()))

(define result (HuffmanCoding l equal?))
(define decodingRes (HuffmanDecoding (car result) (cdr result)))

(define codingTest2 (HuffmanCoding '(1 2 8 8 10) equal?))
;(((5) ((2 . 8) () ()) ((3) ((1 . 10) () ()) ((2) ((1 . 1) () ()) ((1 . 2) () ())))) #\1 #\1 #\0 #\1 #\1 #\1 #\0 #\0 #\1 #\0)
(define decodingTest2 (HuffmanDecoding (car codingTest2) (cdr codingTest2)))
;(1 2 8 8 10)
(define emptyCoding (HuffmanCoding '() eq?))
;(()) = (cons '() '())
(define emptyDecoding (HuffmanDecoding '() '()))
;()
;1 list -> frequencyList
(load "helpFunctions.rkt")
(define (findFrequencyOf elem l eq2)
  (cond
    ((null? l) 0)
    ((eq2 (car l) elem) (+ 1 (findFrequencyOf elem (cdr l) eq2)))
    ( else (findFrequencyOf elem (cdr l) eq2))
  ))

(define (unique? elem l eq2)
  (cond
    ((null? l) #t)
    ((eq2 elem (car l)) #f)
    (else (unique? elem (cdr l) eq2))
  )
  )

(define (unique?2 elem l eq2)
  (cond
    ((null? l) #t)
    ((eq2 elem (car (car l))) #f)
    (else (unique?2 elem (cdr l) eq2))
  )
  )

(define (frequencyList2 l eq2 assocList)
  (cond
    ((null? l) assocList)
    ((unique?2 (car l) assocList eq2)  (frequencyList2 (cdr l) eq2 (cons (cons (car l) (findFrequencyOf (car l) l eq2)) assocList)))
    (else  (frequencyList2 (cdr l) eq2 assocList))
  )
  )

(define (frequencyList l eq2 alreadyCounted)
  (cond
    ((null? l) '())
    ((unique? (car l) alreadyCounted eq2) (cons (cons (car l) (findFrequencyOf (car l) l eq2)) (frequencyList (cdr l) eq2 (cons (car l) alreadyCounted))))
    (else  (frequencyList (cdr l) eq2 alreadyCounted))
  )
  )

(define l '(2 #t 5 5 5 5 2 5 1 #t #f))
(define freqList (frequencyList l equal? '()))
(define freqList2 (frequencyList2 l equal? '()))

;2 frequencyList -> tree
;2.1 leafList
(define (leafList freqList)
  (if (null? freqList)
      '()
      (cons (list (cons (cdr (car freqList)) (car (car freqList))) '() '()) (leafList (cdr freqList)))
      )
  )

(define leafs (leafList (frequencyList l equal? '())))

;2.2 sort
(define (sortTrees tree)
  (if(null? tree)
     '()
     (append ( sortTrees (filter (lambda (x) (< (car (car x)) (car (car (car tree))))) (cdr tree)) )
             (list (car tree))
             (sortTrees (filter (lambda (x) (>= (car (car x)) (car (car (car tree))))) (cdr tree))))  
     )
)

(define sortedLeafs (sortTrees leafs))

;2.3 tree
(define (newTree t1 t2)
  (list (list (+ (car(car t1)) (car(car t2)))) t1 t2)
  )

(define (leafsToTree leafs)
  (if ( or (null? leafs) (null? (cdr leafs)))
      leafs
      (leafsToTree (sortTrees (cons (newTree (car leafs) (cadr leafs)) (cddr leafs))))
      )
  )

(define tree
  (if(null? sortedLeafs)
     '()
     (car(leafsToTree sortedLeafs)))
  )

;3 tree -> binary
(define (symbolToBinary tree symbol eq2 binaryL)
  (cond
    ((null? tree) #f)
    ((eq2 (cdr(car tree)) symbol) binaryL)
    (else (or (symbolToBinary (cadr tree) symbol eq2 (append binaryL (list #\0))) (symbolToBinary (caddr tree) symbol eq2 (append binaryL (list #\1)))))
    ))

(define (treeToBinary tree l eq2)
  (if (null? l)
      '()
      (append (symbolToBinary tree (car l) eq2 '()) (treeToBinary tree (cdr l) eq2)) 
      )
  )

(define binary (treeToBinary tree l equal?))

;4 (1,2,3) list -> tree + binary
(define (HuffmanCoding l eq2)
  (let*
      ((freqList (frequencyList l eq2 '()))
      (leafs (leafList freqList))
      (sortedLeafs (sortTrees leafs))
      (tree
       (if(null? sortedLeafs)
          '()
          (car(leafsToTree sortedLeafs)))
       )
      (binary (treeToBinary tree l eq2)))
     (cons tree binary)
    )
  )
(define result (HuffmanCoding l equal?))

;5 Decoding
(define (HuffmanDecodingHelper tree currTree binary)
   (cond
      ((not (null? (cdr (car currTree)))) (cons (cdr (car currTree)) (HuffmanDecodingHelper tree tree  binary)))
      ((null? binary) '())
      (else
       (if (equal? #\0 (car binary))
           (HuffmanDecodingHelper tree (cadr currTree)  (cdr binary))
           (HuffmanDecodingHelper tree (caddr currTree)  (cdr binary))
           )
       )
    )
  )

(define (HuffmanDecoding tree binary)
  (if(null? tree)
     '()
     (HuffmanDecodingHelper tree tree binary)
  )
  )


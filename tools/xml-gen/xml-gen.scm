; ~/~ begin <<tools/xml-gen/README.md#xml-gen::tools/xml-gen/xml-gen.scm>>[init]
(import (rnrs)
        (rnrs eval)
        (ice-9 match)
        (ice-9 format))

; ~/~ begin <<tools/xml-gen/README.md#xml-gen::main>>[init]
(define (read-all)
  (do ((x (read) (read))
       (r '() (cons x r)))
      ((eof-object? x) (reverse r))))
; ~/~ end
; ~/~ begin <<tools/xml-gen/README.md#xml-gen::main>>[1]
(define (string-ends-with? c s)
  (eq? c (string-ref s (- (string-length s) 1))))

(define (keyword? obj)
  (and (symbol? obj) (string-ends-with? #\: (symbol->string obj))))

(define (keyword->string obj)
  (let ((str (symbol->string obj)))
    (substring str 0 (- (string-length str) 1))))
; ~/~ end
; ~/~ begin <<tools/xml-gen/README.md#xml-gen::main>>[2]
(define (kwargs->attrs lst)
  (let loop ((lst lst)
             (r   '()))
    (match lst
      (((? keyword? kw) arg . rest)
       (loop rest
             (cons (format #f "~a=\"~a\"" (keyword->string kw) arg) r)))
      (('/) (reverse (cons "/" r)))
      ((a . rest)
       (loop rest
             (cons (format #f "~a" a) r)))
      (()  (reverse r)))))
; ~/~ end
; ~/~ begin <<tools/xml-gen/README.md#xml-gen::main>>[3]
(define (xmlize expr)
  (match expr
    ((tag)           (string-append "<" (symbol->string tag) ">"))
    ((tag . kwargs)  (string-append "<" (symbol->string tag) " " (string-join (kwargs->attrs kwargs) " ") ">"))
    (a               a)))
; ~/~ end
; ~/~ begin <<tools/xml-gen/README.md#xml-gen::main>>[4]
(define (run code)
  (match code
    ((('import . <imports> ) . <program>)
     (eval (cons 'begin <program>)
           (apply environment '(rnrs) <imports>)))
    (<program>
     (eval (cons 'begin <program>)
           (environment '(rnrs))))))

(let* ((src  (read-all))
       (expr (run src)))
  (display (string-join (map xmlize expr) "\n")) (newline))
; ~/~ end
; ~/~ end

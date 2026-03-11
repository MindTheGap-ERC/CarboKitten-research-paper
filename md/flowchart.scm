(import (rnrs (6))
        (srfi srfi-28)
        (srfi srfi-13))

(define (strip-css-comments text)
  (let loop ((result '())
             (text text))
    (if (zero? (string-length text))
      (apply string-append (reverse result))
      (let* ((a (string-contains text "/*"))
             (b (if a (string-contains text "*/" (+ a 2)) #f))
             (chunk (if (and a b) (substring text 0 a) text))
             (remain (if (and a b) (substring text (+ b 2) (string-length text)) "")))
        (loop (cons chunk result) remain)))))

(define style-sheet
  (strip-css-comments
    (call-with-input-file "md/flowchart.css" get-string-all)))

(define (edge-arc x1 y1 x2 y2)
  `(path class: "edge" d: ,(format "M ~a ~a A ~a ~a 0 0 1 ~a ~a"
                                   x1 y1 (abs (- x1 x2)) (abs (- y1 y2)) x2 y2)
         marker-end: "url(#arrow)" /))

(define node-width 120)
(define node-height 30)
(define margin 10)
(define center-left 285)
(define ylevel-1 25)
(define ylevel-2 150)
(define ylevel-3 (+ ylevel-2 ylevel-2 (- ylevel-1)))

(define (node x y name)
  `((g class: "node" transform: ,(format "translate(~a ~a)" x y))
    (rect rx: 5 ry: 5 x: -60 y: -15 width: 120 height: 30 /)
    (text) ,name (/text)
    (/g)))

`((?xml version: "1.0" standalone: "no" ?)
  (svg viewBox: "-5 -5 720 350"
       xmlns: "http://www.w3.org/2000/svg"
       xmlns:xlink: "http://www.w3.org/1999/xlink")
    (style) ,style-sheet (/style)
    (defs)
      (marker id: "arrow" viewBox: "0 0 10 10"
              refX: "8" refY: "5"
              markerWidth: "6" markerHeight: "6"
              orient: "auto-start-reverse")
        (path d: "M 0 0 L 10 5 L 0 10 z" /)
      (/marker)
    (/defs)
    (g id: "root")
    (rect id: "background" x: -5 y: -5 width: 720 height: 350 /)
    
    (g class: "state" id: "ca")
    (rect class: "shadow-box" x: 522 y: ,(- ylevel-1 (div node-height 2) margin -2)
          width: 190 height: 50 /)
    (rect class: "top-state-box" x: 520 y: ,(- ylevel-1 (div node-height 2) margin)
          width: 190 height: 50 /)
    (text x: 550 y: ,ylevel-1) "CA" (/text)
    (/g)
    
    (g class: "state" id: "sediment-buffer")
    (rect class: "shadow-box" x: 2 y: ,(- ylevel-2 (div node-height 2) margin -2)
          width: 570 height: ,(+ node-height (* 2 margin)) /)
    (rect class: "top-state-box" x: 0 y: ,(- ylevel-2 (div node-height 2) margin)
          width: 570 height: ,(+ node-height (* 2 margin)) /)
    (text x: ,center-left y: ,ylevel-2) "SEDIMENT BUFFER" (/text)
    (/g)

    (g class: "state" id: "active-layer")
    (rect class: "shadow-box" x: 2 y: ,(- ylevel-3 node-height (* 2 margin) -2)
          width: 570 height: ,(+ (* 2 node-height) (* 2 margin)) /)
    (rect class: "top-state-box" x: 0 y: ,(- ylevel-3 node-height (* 2 margin)) width: 570 height: ,(+ (* 2 node-height) (* 2 margin)) /)
    (text x: ,center-left y: ,(- ylevel-3 node-height)) "ACTIVE LAYER" (/text)
    (/g)
    
    (line class: "edge" x1: 640 y1: ,(+ ylevel-1 (div node-height 2))
          x2: 640 y2: ,(- ylevel-2 (div node-height 2))
          marker-end: "url(#arrow)" /)

    ,(edge-arc (+ center-left (div node-width 2)) ylevel-1 640 (- ylevel-2 (div node-height 2)))
    ,(edge-arc (+ center-left (div node-width 2)) ylevel-1 500 (- ylevel-2 (div node-height 2)))
    ,(edge-arc 640 (+ ylevel-2 (div node-height 2)) (+ center-left (div node-width 2)) ylevel-3)
    ,(edge-arc 500 (+ ylevel-2 (div node-height 2)) (+ center-left (div node-width 2)) ylevel-3)
    ,(edge-arc (- center-left (div node-width 2)) ylevel-3 70 (+ ylevel-2 (div node-height 2)))
    ,(edge-arc 70 (- ylevel-2 (div node-height 2)) (- center-left (div node-width 2)) ylevel-1)

    ,(let ((x1 (+ center-left (div node-width 3)))
           (x2 (- center-left (div node-width 3)))
           (y  (+ ylevel-3 (div node-height 2))))
      `(path class: "edge" d: ,(format "M ~a ~a A ~a ~a 0 0 1 ~a ~a"
                                   x1 y (* 0.333 node-width) (* 0.4 node-width) x2 y)
         marker-start: "url(#arrow)" /))
               
    ,@(node center-left ylevel-1 "time step")
    ,@(node 640 ylevel-2 "produce")
    ,@(node 640 ylevel-1 "evolve")
    ,@(node 500 ylevel-2 "disintegrate")
    ,@(node center-left ylevel-3 "transport")
    ,@(node 70  ylevel-2 "lithify")

    (/g)
  (/svg))

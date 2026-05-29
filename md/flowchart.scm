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

(define node-width 80)
(define node-height 20)
(define margin 10)
(define col1 (+ margin (div node-width 2)))
(define col2 140)
(define col3 (- (* 2 col2) col1))
(define col4 (+ col3 (* 2 margin) node-width))

(define state-box-width-1 (+ (- col3 col1) node-width (* 2 margin)))

(define ylevel-1 25)
(define ylevel-2 130)
(define ylevel-3 (+ ylevel-2 ylevel-2 (- ylevel-1)))

(define fig-height (+ ylevel-3 (div node-height 2) margin 20))
(define fig-width (+ col4 (div node-width 2) margin 5))

(define (node x y name)
  `((g class: "node" transform: ,(format "translate(~a ~a)" x y))
      (rect rx: 5 ry: 5 x: ,(- (div node-width 2)) y: ,(- (div node-height 2))
            width: ,node-width height: ,node-height /)
    (text font-size: "smaller") ,name (/text)
    (/g)))

`((?xml version: "1.0" standalone: "no" ?)
    (svg viewBox: ,(format "-5 -5 ~a ~a" (+ fig-width 5) (+ fig-height 5))
       xmlns: "http://www.w3.org/2000/svg"
       xmlns:xlink: "http://www.w3.org/1999/xlink")
    (style) ,style-sheet (/style)
    (defs)
      (marker id: "arrow" viewBox: "0 0 10 10"
              refX: "8" refY: "5"
              markerWidth: "4" markerHeight: "4"
              orient: "auto-start-reverse")
        (path d: "M 0 0 L 10 5 L 0 10 z" /)
      (/marker)
    (/defs)
    (g id: "root")
    ; (rect id: "background" x: -5 y: -5 width: 720 height: 350 /)

    (g class: "state" id: "ca")
    (rect class: "shadow-box" x: ,(- col4 (div node-width 2) margin 38) y: ,(- ylevel-1 (div node-height 2) margin -2)
          width: 140 height: 40 /)
    (rect class: "top-state-box" x: ,(- col4 (div node-width 2) margin 40) y: ,(- ylevel-1 (div node-height 2) margin)
          width: 140 height: 40 /)
    (text x: ,(- col4 (div node-width 2) (- 40 margin)) y: ,ylevel-1) "CA" (/text)
    (/g)

    (g class: "state" id: "sediment-buffer")
    (rect class: "shadow-box" x: 2 y: ,(- ylevel-2 node-height (* 2 margin) -2)
          width: ,state-box-width-1 height: ,(+ (* 2 node-height) (* 2 margin)) /)
    (rect class: "top-state-box" x: 0 y: ,(- ylevel-2 node-height (* 2 margin))
          width: ,state-box-width-1 height: ,(+ (* 2 node-height) (* 2 margin)) /)
    (text x: ,col2 y: ,(- ylevel-2 node-height 5)) "SEDIMENT BUFFER" (/text)
    (/g)

    (g class: "state" id: "active-layer")
    (rect class: "shadow-box" x: 2 y: ,(- ylevel-3 node-height (* 2 margin) -2)
          width: ,state-box-width-1 height: ,(+ (* 2 node-height) (* 2 margin)) /)
    (rect class: "top-state-box" x: 0 y: ,(- ylevel-3 node-height (* 2 margin))
          width: ,state-box-width-1 height: ,(+ (* 2 node-height) (* 2 margin)) /)
    (text x: ,col2 y: ,(- ylevel-3 node-height 5)) "ACTIVE LAYER" (/text)
    (/g)

    (line class: "edge" x1: ,col4 y1: ,(+ ylevel-1 (div node-height 2))
          x2: ,col4 y2: ,(- ylevel-2 (div node-height 2))
          marker-end: "url(#arrow)" /)

    ,(edge-arc (+ col2 (div node-width 2)) ylevel-1 col4 (- ylevel-2 (div node-height 2)))
    ,(edge-arc (+ col2 (div node-width 2)) ylevel-1 col3 (- ylevel-2 (div node-height 2)))
    ,(edge-arc col4 (+ ylevel-2 (div node-height 2)) (+ col2 (div node-width 2)) ylevel-3)
    ,(edge-arc col3 (+ ylevel-2 (div node-height 2)) (+ col2 (div node-width 2)) ylevel-3)
    ,(edge-arc (- col2 (div node-width 2)) ylevel-3 col1 (+ ylevel-2 (div node-height 2)))
    ,(edge-arc col1 (- ylevel-2 (div node-height 2)) (- col2 (div node-width 2)) ylevel-1)

    ,(let ((x1 (+ col2 (div node-width 3)))
           (x2 (- col2 (div node-width 3)))
           (y  (+ ylevel-3 (div node-height 2))))
      `(path class: "edge" d: ,(format "M ~a ~a A ~a ~a 0 0 1 ~a ~a"
                                   x1 y (* 0.333 node-width) (* 0.4 node-width) x2 y)
         marker-start: "url(#arrow)" /))

    ,@(node col2 ylevel-1 "time step")
    ,@(node col4 ylevel-2 "produce")
    ,@(node col4 ylevel-1 "evolve")
    ,@(node col3 ylevel-2 "disintegrate")
    ,@(node col2 ylevel-3 "transport")
    ,@(node col1  ylevel-2 "lithify")

    (/g)
  (/svg))

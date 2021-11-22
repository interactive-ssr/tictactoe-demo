(in-package #:core)

(deftype spot ()
  '(member :x :o nil))

(defun spotp (object)
  (typep object 'spot))

(defun spot-opposite (spot)
  (if (eq :x spot)
      :o
      :x))

(deftype board (&optional (size 3))
  `(simple-array spot (,size ,size)))

(defun make-board (&key (list) (size 3))
  (cond
    (list
     (assert (every 'spotp list))
     (let ((size (ceiling (sqrt (length list)))))
       (make-array
        (list size size)
        :element-type 'spot
        :initial-contents
        (loop for start from 0 below (* size size) by size
              collect (subseq list start (+ start size))))))
    (t (make-array
        (list size size)
        :element-type 'spot
        :initial-element nil))))

(defun board-size (board)
  (first (array-dimensions board)))

(defun board-rows (board)
  (loop with size = (board-size board)
        for row from 0 below size
        collect
        (loop for column from 0 below size
              collect (aref board row column))))

(defun board-winner (board)
  (flet ((columns (board)
           (loop with size = (board-size board)
                 for column from 0 below size
                 collect
                 (loop for row from 0 below size
                       collect (aref board row column))))
         (diagonals (board)
           (list (loop with size = (board-size board)
                       for row from 0 below size
                       for column from 0 below size
                       collect (aref board row column))
                 (loop with size = (board-size board)
                       for row from 0 below size
                       for column from (- size 1) downto 0
                       collect (aref board row column))))
         (same (x y)
           (when (eq x y)
             x)))
    (some (curry 'reduce #'same)
          (append (board-rows board)
                  (columns board)
                  (diagonals board)))))

(defun board-spot (board row column)
  (aref board row column))

(defun (setf board-spot) (spot board row column)
  (unless (aref board row column)
    (setf (aref board row column) spot)))

(defun board-both-played-p (board)
  (->> board
    board-rows
    (apply 'append)
    (remove nil)
    remove-duplicates
    length
    (= 2)))

(defun alpha-only (string)
  (remove-if-not 'alpha-char-p string))

(defalias alpha-upcase (compose 'str:upcase 'alpha-only))

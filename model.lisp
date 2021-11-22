(in-package #:model)

(defvar *game-id-length* 12)

(defun make-game-id ()
   (map 'string 'code-char
        (loop repeat *game-id-length*
              collect (+ 65 (random 26)))))

(defvar *dbi-connection* (dbi:connect :mysql :database-name "tictactoe"))

(defun dosxql (sql &rest params)
  (dbi:execute (dbi:prepare *dbi-connection* (sxql:yield sql)) params))

(defun sxql-query (sql &rest params)
  (mapcar
   (lambda (row)
     (mapcar
      (lambda (data)
        (if (keywordp data)
            (find-keyword (str:upcase (symbol-name data)))
            data))
      row))
   (dbi:fetch-all (apply 'dosxql sql params))))

(dosxql
 (create-table (:game :if-not-exists t)
     ((id :type `(:varchar ,*game-id-length*)
          :primary-key t)
      (turn :type :boolean)
      (board :type '(:integer 12)))))

(defun board-number (board)
  (let ((*read-base* 3))
    (->> board
      board-rows
      (apply 'append)
      (map 'string
           (lambda (spot)
             (case spot
               (:x #\1)
               (:o #\2)
               (otherwise #\0))))
      read-from-string)))

(defun number-board (number)
  (declare (type integer number))
  (->> number
    (format nil "~3,9,'0R")
    (map 'list
         (lambda (number)
           (case number
             (#\0 nil)
             (#\1 :x)
             (#\2 :o))))
    (make-board :list)))

(defun deserialize-game (plist)
  (list :id (getf plist :id)
        :turn (case (getf plist :turn)
                (0 :o)
                (otherwise :x))
        :board (number-board (getf plist :board))))

(defun find-game (&optional (id (make-game-id)))
  (let ((data
          (first
           (sxql-query
            (select :*
              (from :game)
              (where (:= :id :?))
              (limit 1))
            id))))
    (if data
        (deserialize-game data)
        (list :id id :turn :x :board (make-board)))))

(defun save-game (game)
  (let ((turn (if (eq :x (getf game :turn))
                  1 0))
        (board (board-number (getf game :board)))
        (id (getf game :id)))
    (dosxql
     (insert-into :game
       (set= :turn :?
             :board :?
             :id :?)
       (on-duplicate-key-update
        :turn :?
        :board :?))
     turn board id
     turn board)))

(defun game-spot (game row column)
  (board-spot (getf game :board) row column))

(defun game-winner (game)
  (board-winner (getf game :board)))

(defun game-play-spot (game row column)
  (let ((board (getf game :board)))
    (if (and (null (board-winner board))
             (setf (board-spot board row column)
                   (getf game :turn)))
        (loop for (key value) on game by 'cddr
              collect key
              collect (if (eq :turn key)
                          (spot-opposite value)
                          value))
        game)))

(defun game-both-played-p (game)
  (board-both-played-p (getf game :board)))

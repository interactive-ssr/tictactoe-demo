(in-package #:controller)

(defun initialize-turn-table ()
  (unless (session-value :turns)
    (setf (session-value :turns)
          (make-hash-table :test 'equal))))

(defun turn (game-id)
  (gethash game-id (session-value :turns)))

(defun (setf turn) (turn game-id)
  (setf (gethash game-id (session-value :turns))
        turn))

(defun filter-game-id (string)
  (str:substring 0 model:*game-id-length*
                 (alpha-upcase (str:trim string))))

(define-easy-handler (/tictactoe :uri "/tictactoe")
    (game-id open close play new-game)
  (start-session)
  (initialize-turn-table)
  (let ((raw-game-id game-id)
        (game-id (filter-game-id game-id))
        (close (filter-game-id close))
        (session-id (princ-to-string (session-id *session*))))
    (unless (str:blankp new-game)
      (let ((new-game (model:find-game)))
        (model:save-game new-game)
        (model:enter-game session-id (getf new-game :id))))
    (when (and (not (str:blankp open))
               (not (str:blankp game-id)))
      (model:save-game (model:find-game game-id))
      (model:enter-game session-id game-id))
    (unless (str:blankp close)
      (model:leave-game session-id close))
    (unless (str:blankp play)
      ;(ignore-errors
       (let* ((play-info (jojo:parse (tbnl:url-decode play)))
              (game (-> play-info (getf :id) model:find-game)))
         (when (and (not (model:game-both-played-p game))
                    (null (turn (getf game :id))))
           (setf (turn (getf game :id))
                 (getf game :turn)))
         (when (eq (turn (getf game :id))
                   (getf game :turn))
           (let ((new-game
                   (model:game-play-spot
                    game
                    (getf play-info :row)
                    (getf play-info :col))))
             (unless (eq (getf game :turn)
                         (getf new-game :turn))
               (model:save-game new-game)
               (mapcar
                (lambda (issr-id)
                  (issr:rr issr-id
                           (list (cons "open" "")
                                 (cons "close" "")
                                 (cons "play" "")
                                 (cons "new-game" ""))))
                (remove (header-in* "issr-id")
                        (model:issr-users (getf new-game :id))
                        :test 'string=)))))));)
    (let ((game-id (if (str:blankp open) game-id "")))
      (view:tictactoe
       :games (remove-duplicates
               (model:games session-id)
               :key (lambda (game) (getf game :id))
               :test 'string=)
       :join-game-id game-id
       :update-join-game-id (string/= raw-game-id game-id)
       :var-open-name "game-id"
       :var-open-action "open"
       :var-close-action "close"
       :var-play-action "play"
       :var-new-game-action "new-game"))))

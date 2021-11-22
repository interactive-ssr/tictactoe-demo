(in-package #:model)

(dosxql
 (create-table (:user :if-not-exists t)
     ((issr_id :type '(:char 36)
               :primary-key t)
      (session_id :type '(:varchar 60)))))

(dosxql
 (create-table (:user_game :if-not-exists t)
     ((session_id :type '(:varchar 60))
      (game_id :type `(:varchar ,*game-id-length*)))))

(defun enter (issr-id session-id)
  (dosxql
   (insert-into :user
     (set= :issr_id :?
           :session_id :?))
   issr-id session-id))

(defun leave (issr-id)
  (dosxql
   (delete-from :user
     (where (:= :issr_id :?)))
   issr-id))

(defun enter-game (session-id game-id)
  (dosxql
   (insert-into :user_game
     (set= :session_id :?
           :game_id :?))
   session-id game-id))

(defun leave-game (session-id game-id)
  (dosxql
   (delete-from :user_game
     (where (:and (:= :session_id :?)
                  (:= :game_id :?))))
   session-id game-id))

(defun games (session-id)
  (mapcar
   'deserialize-game
   (sxql-query
    (select (:id :turn :board)
      (from :user_game)
      (join :game
            :on (:= :game_id :id))
      (where (:= :session_id :?)))
    session-id)))

(defun issr-users (game-id)
  (mapcar
   (lambda (row) (getf row :issr_id))
   (sxql-query
    (select (:issr_id)
      (from :user)
      (join :user_game
            :on (:= :user.session_id :user_game.session_id))
      (where (:= :game_id :?)))
    game-id)))

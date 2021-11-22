(in-package #:asdf-user)

(defsystem tictactoe
  :depends-on
  ("str"
   "hunchentoot" 
   "markup"
   "alexandria"
   "serapeum" 
   "binding-arrows"
   "trivia"
   "issr"
   "dbi"
   "sxql"
   "jonathan")
  :components
  ((:file "package")
   (:file "core")
   (:file "model")
   (:file "user-model")
   (:file "view")
   (:file "tictactoe-controller")
   (:file "index")))

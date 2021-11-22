(in-package #:controller)

(defvar *server*
  (make-instance
   'easy-acceptor
   :port 8080
   :document-root "resources/"))

(defun tictactoe-connect-hook (uuid)
  (when (str:starts-with-p "/tictactoe" (issr:header uuid "uri"))
    (let ((session-cookie (issr:cookie uuid "hunchentoot-session")))
      (model:enter uuid (str:substring 0 (position #\: session-cookie)
                                       session-cookie)))))

(pushnew 'tictactoe-connect-hook issr:*connect-hooks*)

(defun tictactoe-disconnect-hook (uuid)
  (when (str:starts-with-p "/tictactoe" (issr:header uuid "uri"))
    (model:leave uuid)))

(pushnew 'tictactoe-disconnect-hook issr:*disconnect-hooks*)

(setq issr:*redis-password* "1234")

(start *server*)

(issr:start-hook-listener)

(defpackage core
  (:use #:cl)
  (:import-from #:alexandria
                #:curry
                #:compose)
  (:import-from #:serapeum
                #:defalias)
  (:import-from #:binding-arrows
                #:->>
                #:->)
  (:export
   #:spot
   #:spot-opposite
   #:board
   #:board-size
   #:make-board
   #:board-winner
   #:board-rows
   #:board-spot
   #:board-both-played-p
   #:alpha-upcase))

(defpackage model
  (:use #:cl #:core)
  (:import-from #:sxql
                #:join
                #:delete-from
                #:on-duplicate-key-update
                #:insert-into
                #:returning
                #:set=
                #:update
                #:limit
                #:where
                #:from
                #:select
                #:create-table)
  (:import-from #:binding-arrows
                #:as->
                #:->>)
  (:import-from #:serapeum
                #:find-keyword)
  (:export
   #:find-game
   #:save-game
   #:game-play-spot
   #:game-spot
   #:game-winner
   #:enter
   #:leave
   #:enter-game
   #:leave-game
   #:games
   #:game-both-played-p
   #:*game-id-length*
   #:issr-users))

(defpackage view
  (:use #:cl #:core)
  (:import-from #:markup
                #:deftag
                #:merge-tag)
  (:export
   #:tictactoe))

(defpackage controller
  (:use #:cl #:core)
  (:import-from #:binding-arrows
                #:->)
  (:import-from #:hunchentoot
                #:session-value
                #:session-id
                #:*session*
                #:start-session
                #:define-easy-handler
                #:start
                #:easy-acceptor
                #:header-in*))

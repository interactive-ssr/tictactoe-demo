(in-package #:view)
(markup:enable-reader)

(deftag board (&key game-id board var-play-action)
  <div class="board">
    <link rel="stylesheet" href="board.css"/>
    ,@(apply
       'append
       (loop with size = (board-size board)
             for row from 0 below size
             collect
             (loop for column from 0 below size
                   for spot = (board-spot board row column)
                   collect
                   <button class="spot"
                           action=var-play-action
                           value=(tbnl:url-encode
                                  (jojo:to-json
                                   (list :id game-id
                                         :row row
                                         :col column)))
                           onclick=(unless spot "rr(this)")>
                     ,(when spot
                        (symbol-name spot))
                   </button>)))
  </div>)

(deftag game (children &key game var-open-name var-open-action var-close-action)
  <div class="game">
    <link rel="stylesheet" href="game.css"/>
    <h2>
    <button onclick=(format nil "navigator.clipboard.writeText('https://~A/tictactoe?~A=~A&~A=t')"
                            (hunchentoot:host)
                            var-open-name (getf game :id)
                            var-open-action)
            title="Copy Join Link">
        📋
      </button>
      <code>,(getf game :id)</code>
      <button class="close"
              title="Close Game"
              action=var-close-action
              value=(getf game :id)
              onclick="rr(this)">
        ×
      </button>
    </h2>
    ,(let ((winner (model:game-winner game)))
       (if winner
           <p>,(progn winner) wins!</p>
           <p>,(getf game :turn)'s turn</p>))
    ,@children
  </div>)

(defun tictactoe (&key games
                    join-game-id
                    update-join-game-id
                    var-open-name
                    var-open-action
                    var-close-action
                    var-play-action
                    var-new-game-action)
  (markup:write-html
   <html>
     <head>
       <meta name="viewport" content="width=device-width, initial-scale=1.0">
       <link rel="stylesheet" href="tictactoe.css"/>
       <title>Tic Tac Toe</title>
     </head>
     <body>
       <h1>
         Tic Tac Toe
         <div>Three in a Row</div>
       </h1>
       <label>
         Game ID:
         <input name=var-open-name
                value=join-game-id
                placeholder="Game ID"
                update=update-join-game-id
                type="search"
                oninput="drr(id)()"/>
       </label>
       <button action=var-open-action
               onclick="rr(this)">
         Join
       </button>
       <button action=var-new-game-action
               onclick="rr(this)">
         New Game
       </button>
       <div class="tictactoe">
         ,@(mapcar
            (lambda (game)
              <game game=game var-close-action=var-close-action
                    var-open-name=var-open-name
                    var-open-action=var-open-action >
                <board game-id=(getf game :id)
                       board=(getf game :board)
                       var-play-action=var-play-action />
              </game>)
            games)
       </div>
     </body>
   </html>))

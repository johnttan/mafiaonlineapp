GameLobby = require('./GameLobby').GameLobby
uuid = require('node-uuid')
Config = require('./config').Config
UserManager = require('./UserManager').UserManager

class QueueManager
  constructor: (io)->
    @io = io
    @gamesArray = []
    do (queue = @)->
      io.of('/').on('connection', (socket)->
          user = UserManager.getUser(socket.id)
          if not user
            socket.emit('playerNotFound')
            socket.on('addPlayer', (playerInfo)->
              UserManager.setUser(socket, playerInfo)
            )
          else
            socket.emit('playerFound', user)

      )
      io.of('/matchmaking').on('connection', (socket)->
          user = UserManager.getUser(socket.id)
          if not user
            socket.emit('playerNotFound')
            socket.on('addPlayer', (playerInfo)->
              UserManager.setUser(socket, playerInfo)
            )
          else
            console.log socket.id
            queue.beginQueue(socket)
      )

  beginQueue: (socket)->
    console.log 'beginqueue'
    gamefound = false
    while not gamefound
      queueLength = @gamesArray.length
      if queueLength isnt 0
        if @gamesArray[queueLength-1].game.checkStatus()
          socket.emit('match_found', @gamesArray[queueLength-1].namespace.name)
          gamefound = true
          console.log 'found new game'
        else
          removedGame = @gamesArray.pop().game.outOfQueue()
          console.log removedGame
      else
        console.log 'making new game'
        randomName = uuid.v4()
        randomName = '/' + randomName.split('-').join('')
        newNamespace = @io.of(randomName)
        console.log newNamespace.name
        game = new GameLobby(@io, newNamespace, @, new Config(['mafia', 'villager', 'villager']))
        gameObject = {
          game: game
          namespace: newNamespace
        }
        @gamesArray.push(gameObject)
        console.log 'made new game'
#        console.log(gameObject)

  addToQueue: (game)->
    @gamesArray.push(game)


exports.QueueManager = QueueManager
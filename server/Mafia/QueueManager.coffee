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
            console.log('playerNotFound, at queuemanager/main')
            socket.on('addPlayer', (playerInfo)->
              UserManager.setUser(socket, playerInfo)
            )
          else
            socket.emit('playerFound', user)
            console.log('playerFound')
#            console.log('playerFound', user)

      )

      io.of('/matchmaking').on('connection', (socket)->
          console.log 'matchmaking connected', socket.id
          user = UserManager.getUser(socket.id)
          console.log user, 'user'
          if user is undefined
            console.log 'emitting playernotfound at matchmaking'
            socket.emit('playerNotFound, at queue')
            socket.on('addPlayer', (playerInfo)->
#              console.log 'addingPlayer at matchmaking', playerInfo
              UserManager.setUser(socket, playerInfo)
              socket.playerName = playerInfo.name
              queue.beginQueue(socket)
            )
          else
            console.log socket.id, 'playerFound'
            socket.playerName = user.name
            console.log socket.playerName, 'matchmaking name'
            socket.emit('playerFound', user)
          socket.on('joinQueue', ->
            queue.beginQueue(socket)
          )
      )


  beginQueue: (socket)->
    socket.emit('beginQueue')
    console.log 'beginqueue'
    gamefound = false
    while not gamefound
      console.log 'searching for game'
      queueLength = @gamesArray.length
      if queueLength isnt 0
        if @gamesArray[queueLength-1].game.checkStatus()
#          console.log UserManager.getUser(socket.id)
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
        game = new GameLobby(@io, newNamespace, @, new Config(['mafia', 'mafia', 'villager', 'villager', 'villager', 'villager', 'villager']))
        gameObject = {
          game: game
          namespace: newNamespace
        }
        @gamesArray.push(gameObject)
        console.log 'made new game'

  addToQueue: (game)->
    @gamesArray.push(game)


exports.QueueManager = QueueManager
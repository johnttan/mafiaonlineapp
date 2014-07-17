GameEngine = require('./GameEngine').GameEngine
uuid = require('node-uuid')
UserManager = require('./UserManager').UserManager
class GameLobby
  constructor: (io, ioNamespace, queue, config)->
    @queue = queue
    @ioNamespace = ioNamespace
    @io = io
    @config = config
    @playersInfo = {}
    @gameEngine = new GameEngine(io, ioNamespace, @playersInfo, config)
    @availableRoles = config.availableRoles
    @inQueue = true
    #      Fisher-Yates shuffle
    for _i in [@availableRoles.length-1..1]
      _j = Math.floor(Math.random() * (_i + 1))
      [@availableRoles[_i], @availableRoles[_j]] = [@availableRoles[_j], @availableRoles[_i]]
#    console.log(@availableRoles)
    do (lobby = @)->
      ioNamespace.on('connection', (socket)->
        playerInfo = UserManager.getUser(socket.id)
        if playerInfo and not lobby.gameEngine.started
          socket.playerName = playerInfo.name
          console.log 'adding player', playerInfo.name, 'to LOBBY'
          lobby.addPlayer(socket, playerInfo)
        else
          socket.emit('playerNotFound')
      )
      ioNamespace.on('quit', (socket)->
        lobby.removePlayer(socket.playerName)
      )
      ioNamespace.on('disconnect', (socket)->
        if not lobby.gameEngine.started
          lobby.removePlayer(socket.playerName)
      )
      ioNamespace.on('endGame', (wins)->
        console.log 'lobby got endGame', wins
      )
  getGameID: ->
    return @ioNamespace.name
  checkGameEnd: (playerName)->
    if Object.keys(@gameEngine.wins).length isnt 0
      return false
    else
      return true
  checkStatus: ->
    if @availableRoles.length == 0 or @gameEngine.started is true
      return false
    else
      return true
  outOfQueue: ->
    @inQueue = false
  addPlayer: (socket, playerInfo)->
#    console.log playerInfo, 'playerinfo in game engine add player'
    console.log 'in game engine add player'
    if @checkStatus()
      @playersInfo[socket.playerName] = playerInfo
      role = @availableRoles.pop()
      playerGameInfo = {
        name: playerInfo.name
        role: role
      }
      @gameEngine.addPlayer(playerGameInfo, socket)
      @addGameListeners(socket)

      @ioNamespace.emit('joined', @playersInfo)
    else
      socket.emit('join_failed')
  removePlayer: (socket)->
#    console.log @gameEngine.playersInfo
    if not @gameEngine.started
      @availableRoles.push(@gameEngine.getPlayerRole(socket.playerName))
    delete @playersInfo[socket.playerName]
    @gameEngine.deletePlayer(socket.playerName)
    if not @inQueue and not @gameEngine.started
      @queue.addToQueue({
        game: @
        namespace: @ioNamespace
      })
    @ioNamespace.emit('left', @playersInfo)
  addGameListeners: (socket)->
    do(lobby=@)->
      socket.on('disconnect', ->
        lobby.removePlayer(socket)
      )

exports.GameLobby = GameLobby



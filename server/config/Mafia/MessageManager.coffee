class MessageManager
  constructor: (io, ioNamespace, gameEngine)->
    @gameEngine = gameEngine
    @publicState = gameEngine.getAllPublicState()
    @ioNamespace = ioNamespace
    @io = io
#    console.log ioNamespace

  nextTurn: ->
    @synchChats()
  addPlayer: ->
    @synchChats()

# should already be removed from namespace by GameLobbyManager
  removePlayer: (playerName)->
#    @synchChats()

#Joins appropriate rooms
  synchChats: ->
    for socket in @ioNamespace.sockets
      playerPublicState = @publicState[socket.playerName]
      if playerPublicState isnt undefined
        for room, inside of playerPublicState.chats
          if inside
            socket.join(room)

  sendMessage: (socket, messageObject)->
    if @gameEngine.getTurn() % 2 isnt 0
      @io.to('public').emit(messageObject.message)
    else
      if messageObject.room in @publicState[socket.playerName]
        @io.to(messageObject.room).emit('chat', messageObject.message)


exports.MessageManager = MessageManager
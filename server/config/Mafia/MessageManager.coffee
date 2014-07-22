class MessageManager
  constructor: (io, ioNamespace, gameEngine)->
    @gameEngine = gameEngine
    @publicState = gameEngine.getAllPublicState()
    @ioNamespace = ioNamespace
    @commandManager = @gameEngine.getCommandManager()
    @gameEnd = false
    @io = io
    @votes = {
      lynch: {}
      mafia: {}
    }
    @throttle = {}
#    console.log ioNamespace

  endGame: (wins)->
    @gameEnd = true
    @ioNamespace.emit('endGame', wins)

  voteResolve: ->
    if @gameEngine.getTurn() % 2 is 0
      voteKey = 'lynch'
    else
      voteKey = 'mafia'
    voteCount = {}
    thereIsVote = false
    for own person, vote of @votes[voteKey]
      if vote
        thereIsVote = true
        if not voteCount[vote]
          voteCount[vote] = 0
        voteCount[vote] += 1
    if thereIsVote
      voteArray = []
      for vote in Object.keys(voteCount)
        newO = {}
        newO.votes = voteCount[vote]
        newO.name = vote
        voteArray.push(newO)
      voteArray.sort((a, b)->
        return a.votes - b.votes
      )
      chosen = voteArray.pop()
      second = voteArray.pop()
      console.log voteCount, voteKey, voteArray
      if not second
        second = {votes: 0}
      if chosen.votes > second.votes
        console.log chosen, 'chosen by votes'
        if voteKey is 'lynch'
          @gameEngine.lynch(chosen.name)
        else if voteKey is 'mafia'
          for own voter, vote of @votes[voteKey]
            if vote is chosen.name
              @commandManager.preValidateActive('active', {targetname: chosen.name}, voter)
    delete @votes
    @votes = {
      lynch: {}
      mafia: {}
    }
  nextTurn: ->
    delete @votes
    @votes = {
      lynch: {}
      mafia: {}
    }
    @ioNamespace.in('public').emit('voteUpdate', @votes)
    @synchChats()
    @pushPublicStates()
  addPlayer: (socket)->
    do(messager=@)->
      socket.on('checkState', ->
        if not messager.gameEnd
          if messager.gameEngine.started
            messager.gameEngine.nextTurn()
      )
      socket.on('voteLynch', (target)->
        if not messager.gameEnd
          if messager.gameEngine.started
            if messager.gameEngine.getTurn() % 2 is 0 and target of messager.publicState
              console.log target, 'lynch'
              messager.votes.lynch[socket.playerName] = target
              messager.ioNamespace.in('public').emit('voteUpdate', messager.votes)
      )
      socket.on('action', (actionObject)->
        if not messager.gameEnd
#        quick hack for voting recognition
          if messager.gameEngine.started
            if messager.publicState[socket.playerName].role == 'mafia' and messager.gameEngine.getTurn() % 2 isnt 0 and actionObject.args.targetname of messager.publicState
              messager.votes.mafia[socket.playerName] = actionObject.args.targetname
              messager.ioNamespace.in('mafia').emit('voteUpdate', messager.votes)
            else if actionObject.action in messager.publicState[socket.playerName].legalActions
              messager.commandManager.preValidateActive(actionObject.action, actionObject.args, socket.playerName)
      )
      socket.on('chat', (chatMessage)->
        current = new Date()
        if socket.playerName not of messager.throttle
          messager.throttle[socket.playerName] = new Date()
        else
#          Chat throttle to 300ms min between chats
          if (current - messager.throttle[socket.playerName]) < 300
            socket.emit('slowChat', {time: new Date()})
          else
            messager.throttle[socket.playerName] = new Date()
            if not messager.gameEngine.started or messager.gameEnd
              chatMessage.room = 'public'
            chatMessage.playerName = socket.playerName
            console.log('received', chatMessage, ' from ', socket.playerName)
            if chatMessage.message isnt ''
              messager.gameEngine.sendMessage(socket, chatMessage)
      )
    @synchChats()
    @throttle[socket.playerName] = new Date()

# should already be removed from namespace by GameLobby
#  and killed by GameEngine
  removePlayer: (playerName)->
    @pushPublicStates()

#Joins appropriate rooms
  synchChats: ->
    for socket in @ioNamespace.sockets
      playerPublicState = @publicState[socket.playerName]
      if playerPublicState isnt undefined
        for room in socket.rooms
          if not playerPublicState.chats[room]
            socket.leave(room)
        for room, inside of playerPublicState.chats
          if inside
            socket.join(room)

  pushPublicStates: ->
    for socket in @ioNamespace.sockets
      if socket
        playerPublicState = @publicState[socket.playerName]
        if playerPublicState
          if @gameEngine.started
            socket.emit('gameUpdate', playerPublicState)
          else
            tempstate = JSON.parse(JSON.stringify(playerPublicState))
            delete tempstate['role']
            socket.emit('gameUpdate', tempstate)
        else
          socket.emit('dead', @publicState)
  sendMessage: (socket, messageObject)->
    newChat = {
      who: socket.playerName
      message: messageObject.message
      room: messageObject.room
      time: new Date()
    }
    if @gameEngine.getTurn() % 2 isnt 0 and messageObject.room isnt 'public'
      if @publicState[socket.playerName].chats[messageObject.room]
        console.log 'emitting in ', @ioNamespace.name, messageObject.room
        @io.of(@ioNamespace.name).in(messageObject.room).emit('newChat', newChat)
    else if messageObject.room is 'public'
      if @publicState[socket.playerName]
        console.log 'emitting in ', @ioNamespace.name, messageObject.room
        @io.of(@ioNamespace.name).in('public').emit('newChat', newChat)



exports.MessageManager = MessageManager
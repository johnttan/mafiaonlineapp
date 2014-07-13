randomName = require('sillyname')
uuid = require('node-uuid')
class UserManager
  constructor: ->
    @userMap = {}

  setUser: (socket, playerInfo)->
    if not playerInfo.name
      playerInfo.name = randomName()
      iterationCounter = 0
      while playerInfo.name not of @userMap
        playerInfo.name = randomName()
        iterationCounter += 1
        if iterationCounter > 10
          playerInfo.name = playerInfo.name + String(Math.random().toString(36).substring(2, 5))
    timeAdded = new Date()
    user = {
      socketID: socket.id
      name: playerInfo.name
      sessionID: uuid.v4()
      timeAdded: timeAdded
      game: undefined
    }
    socket.playerName = playerInfo.name
    @userMap[socket.id] = user
    socket.emit('playerFound', user)
  getUser: (socketID)->
    return @userMap[socketID]
  updateUser: (socket, playerInfo)->
    playerFound = false
    user = @userMap[playerInfo.name]
    if user
      if @playerInfo.sessionID is user.sessionID
        playerFound = true
      if playerFound
        user.socketID = socket.id
        if user.game
          if user.game.checkGameEnd(playerInfo.name)
            socket.emit('gameEnded', user.game.getID())
          else
            socket.emit('gameAt', user.game.getID())
    else
      @setUser(socket, playerInfo)


exports.UserManager = new UserManager()


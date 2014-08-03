randomName = require('sillyname')
uuid = require('node-uuid')
class UserManager
  constructor: ->
    @userMap = {}

  setUser: (socket, playerInfo)->
    if not playerInfo.name
      playerInfo.name = randomName()
      playerInfo.name = playerInfo.name
    timeAdded = new Date()
    user = {
      name: playerInfo.name
      timeAdded: timeAdded
      game: undefined
    }
    socket.playerName = playerInfo.name
    @userMap[socket.id] = user
#    console.log(socket.id, 'set user', user)
    socket.emit('playerFound', user)
  getUser: (socketID)->
    return @userMap[socketID]


exports.UserManager = new UserManager()


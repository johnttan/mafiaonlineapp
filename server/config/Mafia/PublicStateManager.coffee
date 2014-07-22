class PublicStateManager
  constructor: ->
    @publicState = {}

  nextTurn: (turn)->
    for own playername, player of @publicState
      player.turn = turn
  addPlayer: (playerObject, gameEngine, config)->
    @publicState[playerObject.currentState.name] = playerObject.roleObject.publicStateInitialize(playerObject, gameEngine, config)
    for own playername, player of @publicState
      if playerObject.currentState.name not in player.publicPlayers
        player.publicPlayers[playerObject.currentState.name] = {}
    return true

  removePlayer: (playerName, role)->
    if playerName of @publicState
      delete @publicState[playerName]
      for own player, playerO of @publicState
        delete playerO.publicPlayers[playerName]
        if not playerO.grave
          playerO.grave = {}
        playerO.grave[playerName] = {role: role}
      return true
    else
      return false
  getAllPublicState: ->
    return @publicState
  getPublicState: (playername)->
    return @publicState[playername]


exports.PublicStateManager = PublicStateManager
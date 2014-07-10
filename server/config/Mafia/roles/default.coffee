class DefaultRole
  actions: ['visit', 'death']
  initializeState: (currentRoleState)->
    currentRoleState.roleID = @roleID
    currentRoleState.allegiance = @allegiance

    currentRoleState.dead = false
    currentRoleState.causeOfDeath = undefined
    currentRoleState.killer = undefined
    currentRoleState.vest = 0
    currentRoleState.visited = {
      1: []
    }
    currentRoleState.visitors = {
      1: []
    }

  publicStateInitialize: (playerObject, gameEngine, config)->
    newState = {}
    newState.name = playerObject.currentState.name
    newState.role = playerObject.currentState.roleID
    newState.publicPlayers = {}
    for own player, playerobject of gameEngine.getGameState().players
      newState.publicPlayers[player] = {}
    newState.reports = {}
    newState.legalActions = []
    newState.chats = {
      public: true
    }
    newState.turn = 1
    return newState

  death: {
    priority: 5
    func: (args, currentState, gameEngine)->
      gameState = gameEngine.getGameState()
      currentState.dead = true
      currentState.causeOfDeath = args.how
      currentState.killer = args.who
      gameState.grave.push(currentState.name)
      return false
  }

  visit: {
    priority: 1
    func: (args, currentState, gameEngine)->
      playerObject = gameEngine.getPlayerObject(currentState.name)
      playerObject.addToVisitors(args.who)
      return true
  }

exports.DefaultRole = DefaultRole
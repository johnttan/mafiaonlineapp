
DefaultRole = require('./default').DefaultRole

class MafiaRole extends DefaultRole
  roleID: 'mafia'
  allegiance: 'mafia'
  publicStateInitialize: (playerObject, gameEngine, config)->
    newstate = super(playerObject, gameEngine, config)
    newstate.chats.mafia = true
    newstate.legalActions.push('active')
    return newstate
# Mafia kill

  active: {
    immediate: false
    priority: 3
    func: (args, currentState, gameEngine)->
      gameState = gameEngine.getGameState()
      targetname = args.targetname
      target = gameState.players[targetname]
      visitObject = {
        who: currentState.name
      }
      gameEngine.getPlayerObject(currentState.name).addToVisited(args.targetname)
      target.on('visit', visitObject)
      targetargs = {
        who: currentState.name
        how: 'mafia_kill'
      }
      target.on('death', targetargs)
      console.log('finished mafia kill', target)
  }
  winCondition: {
    role: 'mafia'
    check: (gameState)->
      numMafia = 0
      numVillager = 0
      for own player, playerObj of gameState.players
        if playerObj.getCurrentState().dead isnt true
          all = playerObj.getCurrentState().allegiance
          if all == 'mafia'
            numMafia += 1
          else if all == 'village'
            numVillager += 1
      if numMafia > 0 and numVillager == 0
        return true
      else
        return false

  }
  validateActive: (args, currentState, gameEngine)->
#    currentState refers to the mafia state
    valid = true
    if gameEngine.getTurn() % 2 is 0
      valid = false
    if currentState.blocked
      valid = false
    if currentState.dead
      valid = false
    if gameEngine.getPlayerObject(args.targetname).currentState.dead
      valid = false
    if gameEngine.getPlayerObject(args.targetname).currentState.allegiance is 'mafia'
      valid = false
    return valid

exports.mafia = new MafiaRole()

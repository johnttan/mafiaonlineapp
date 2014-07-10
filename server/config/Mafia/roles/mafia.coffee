
DefaultRole = require('./default').DefaultRole

class MafiaRole extends DefaultRole
  roleID: 'mafia'
  allegiance: 'mafia'
  publicStateInitialize: (playerObject, gameEngine, config)->
    newstate = super(playerObject, gameEngine, config)
    newstate.chats.mafia = true
    newstate.legalActions = ['action']
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
  }

  validateActive: (args, currentState, gameEngine)->
#    currentState refers to the mafia state
    valid = true
    if currentState.blocked
      valid = false
    if currentState.dead
      valid = false
    if gameEngine.getPlayerObject(args.targetname).currentState.dead
      valid = false
    return valid

exports.mafia = new MafiaRole()

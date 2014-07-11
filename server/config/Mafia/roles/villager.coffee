log = ->
  for thelog in arguments
    console.log thelog

DefaultRole = require('./default').DefaultRole

class VillagerRole extends DefaultRole
  roleID: 'villager'
  allegiance: 'village'
  winCondition: {
    role: 'villager'
    check: (gameState)->
      numMafia = 0
      numVillager = 0
      for own player, playerObj of gameState.players
        all = playerObj.getCurrentState().allegiance
        if all == 'mafia'
          numMafia += 1
        else if all == 'village'
          numVillager += 1
      if numMafia == 0 and numVillager > 0
        return true
      else
        return false
  }
exports.villager = new VillagerRole()


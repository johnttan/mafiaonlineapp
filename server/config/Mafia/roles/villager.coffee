log = ->
  for thelog in arguments
    console.log thelog

DefaultRole = require('./default').DefaultRole

class VillagerRole extends DefaultRole
  roleID: 'villager'
  allegiance: 'village'

exports.villager = new VillagerRole()


roles = require('./roles')

class Config
  constructor: (availableRoles, random)->
    @roles = roles
    @availableRoles = availableRoles
    @maxTurns = 12
  defaultGameState: (gameState)->
    gameState.turn = 1
    gameState.players = {}
    gameState.grave = {}
  generateRandomRoles: (number)->

exports.Config = Config
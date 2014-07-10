
class Config
  constructor: ->

  defaultGameState: (gameState)->
    gameState.turn = 1
    gameState.players = {}
    gameState.grave = []


exports.Config = Config
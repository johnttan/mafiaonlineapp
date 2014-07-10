
roles = require('./roles')
PlayerGame = require('./PlayerGame').PlayerGame
CommandManager = require('./CommandManager').CommandManager
PublicStateManager = require('./PublicStateManager').PublicStateManager
MessageManager = require('./MessageManager').MessageManager
class GameEngine
  constructor: (io, ioNamespace, Config)->
    @config = new Config()
    @gameState = {}
    @config.defaultGameState(@gameState)
    @playersObject = {}
    @manager = new CommandManager(@)
    @publicStateManager = new PublicStateManager()
    @messageManager = new MessageManager(io, ioNamespace, @)


  nextTurn: ->
    @gameState.turn += 1
    for own player, playerObject of @gameState.players
      playerObject.endTurn(@gameState.turn)
    @publicStateManager.nextTurn(@gameState.turn)
    @messageManager.nextTurn()


  addPlayer: (playerInfo)->
    @playersObject[playerInfo.name] = playerInfo
    @gameState.players[playerInfo.name] = new PlayerGame(roles[playerInfo.role], playerInfo, @, @config)
    @publicStateManager.addPlayer(@gameState.players[playerInfo.name], @, @config)
    @messageManager.addPlayer()


  deletePlayer: (playerName)->
    delete @playersObject[playerName]
    delete @gameState.players[playerName]
    @publicStateManager.removePlayer(playerName)
    @messageManager.removePlayer(playerName)
  getChatManager: ->
    return
  getCommandManager: ->
    return @manager
  getAllPublicState: ->
    return @publicStateManager.getAllPublicState()
  getPublicState: (player)->
    return @publicStateManager.getPublicState(player)
  getGameState: ->
    return @gameState
  getAllPlayers: ->
    return @playersObject
  getPlayerInfo: (player)->
    return @playersObject[player]
  getPlayerObject: (player)->
    return @gameState.players[player]
  getTurn: ->
    return @gameState.turn

exports.GameEngine = GameEngine
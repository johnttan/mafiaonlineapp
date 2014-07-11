PlayerGame = require('./PlayerGame').PlayerGame
CommandManager = require('./CommandManager').CommandManager
PublicStateManager = require('./PublicStateManager').PublicStateManager
MessageManager = require('./MessageManager').MessageManager
class GameEngine
  constructor: (io, ioNamespace, playersInfo, config)->
    @ioNamespace = ioNamespace
    @config = config
    @roles = config.roles
    @gameState = {}
    @config.defaultGameState(@gameState)
    @playersInfo = playersInfo
    @manager = new CommandManager(@)
    @publicStateManager = new PublicStateManager()
    @messageManager = new MessageManager(io, ioNamespace, @)
    @started = false
    @winConditions = {}
  nextTurn: ->
    if @started
      @manager.nextTurn()
      @gameState.turn += 1
      @cleanupDead()
      for own player, playerObject of @gameState.players
        playerObject.endTurn(@gameState.turn)
      @publicStateManager.nextTurn(@gameState.turn)
      @messageManager.nextTurn()
      wins = {}
      for own role, wincondition of @winConditions
        if wincondition.check(@gameState)
          wins[role] = true
      console.log(wins, 'wins')
      if Object.keys(wins).length > 0
        @wins = wins
        @messageManager.endGame(@wins)

  lynch: (player)->
    @gameState.players[player].getCurrentState().dead = true
    @gameState.players[player].getCurrentState().causeofdeath = 'lynch'
    @cleanupDead()
    console.log 'lynched', 'player'
  cleanupDead: ->
    for player, playerObj of @gameState.players
      if playerObj.getCurrentState().dead and player not of @gameState.grave
        console.log playerObj.getCurrentState()
        @gameState.grave[player] = {
          role: playerObj.getCurrentState().role
        }
        @publicStateManager.removePlayer(player)
        @messageManager.removePlayer(player)
  startGame: ->
    if not @started
      @started = true
      @pushPublicStates()
  pushPublicStates: ->
    if @started
      @messageManager.pushPublicStates()
  addPlayer: (playerInfo, socket)->
    if not @started
      @gameState.players[playerInfo.name] = new PlayerGame(@roles[playerInfo.role], playerInfo, @, @config)
      @publicStateManager.addPlayer(@gameState.players[playerInfo.name], @, @config)
      @messageManager.addPlayer(socket)
  addWinCondition: (winCondition)->
    if winCondition.role not of @winConditions
      @winConditions[winCondition.role] = winCondition
  removeWinCondition: (role)->
    delete @winConditions[role]

  sendMessage: (socket, chatMessage)->
    @messageManager.sendMessage(socket, chatMessage)
  deletePlayer: (playerName)->
    if @started
      console.log 'game already started', 'killing', playerName
      @gameState.players[playerName].getCurrentState().dead = true
      @cleanupDead()
    else
      delete @gameState.players[playerName]
      @publicStateManager.removePlayer(playerName)
      @messageManager.removePlayer(playerName)
  getMessageManager: ->
    return @messageManager
  getCommandManager: ->
    return @manager
  getAllPublicState: ->
    return @publicStateManager.getAllPublicState()
  getPublicState: (player)->
    return @publicStateManager.getPublicState(player)
  getGameState: ->
    return @gameState
  getAllPlayers: ->
    return @playersInfo
  getPlayerInfo: (player)->
    return @playersInfo[player]
  getPlayerRole: (player)->
    return @getPlayerObject(player).playerInfo.role
  getPlayerObject: (player)->
    return @gameState.players[player]
  getTurn: ->
    return @gameState.turn

exports.GameEngine = GameEngine
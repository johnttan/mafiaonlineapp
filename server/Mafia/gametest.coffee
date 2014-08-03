log = ->
  for thelog in arguments
    console.log thelog

GameEngine = require('./GameEngine').GameEngine
Config = require('./config').Config


villagerInfo = (name)->
  @name = name
  @role = 'villager'

mafiaInfo = (name)->
  @name = name
  @role = 'mafia'




time1 = new Date()
for i in [1...2000]
  newgame = new GameEngine(io, ioNamespace, new Config)
  players = []
  for i in [1...10]
    players.push([Math.random().toString(36).substring(7), Math.random().toString(36).substring(7)])
  for playerSet in players
    villager = playerSet[0]
    mafia = playerSet[1]
    newgame.addPlayer(new villagerInfo(villager))
    newgame.addPlayer((new mafiaInfo(mafia)))
  for playerSet1 in players
    villager1 = playerSet1[0]
    mafia1 = playerSet1[1]
    for playerSet2 in players
      villager2 = playerSet2[0]
      mafia2 = playerSet2[1]
      newgame.getCommandManager().preValidateActive('active', {targetname: villager2}, mafia1, false)

  for playerSet1 in players
    newgame.nextTurn()
    villager1 = playerSet1[0]
    mafia1 = playerSet1[1]
    newgame.getCommandManager().preValidateActive('active', {targetname: villager1}, mafia1, false)
  newgame.getCommandManager().callActives()
time2 = new Date()
log 'time', time2-time1, 'time'
#log newgame.gameState.players
#log newgame.getGameState()




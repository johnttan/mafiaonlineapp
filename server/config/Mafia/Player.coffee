class Player
  constructor: (playerInfo, roleObjects)->
    @role = roleObjects[playerInfo.role]
    @name = playerInfo.name
    @roletring = @role.rolestring

    @alive = true
    @knowswho = []
    @deathinfo = {}

    #        function stacks
    @visitstack = []




bomb = {
  'rolestring': 'bomb'
  'die': (who, how)->
    log this

}

villager = {
  'rolestring': 'villager'
}

roleObjects = {
  'bomb': bomb
  'villager': villager
}

bombInfo = {
  'name': 'SwaggerBomb'
  'role': 'bomb'
}

villagerInfo = {
  'name': 'YoloVillager'
  'role': 'villager'
}

players = []

players.push(new Player(bombInfo, roleObjects))

#players.push(new Player(villagerInfo, roleObjects))

  player.die('village', 'lynch')

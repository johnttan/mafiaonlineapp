Heap = require('heap')


class CommandManager
  constructor: (gameEngine)->
    @gameEngine = gameEngine
    @activeQueue = new Heap(
      (a, b)->
        return if a.priority < b.priority then 1 else -1
    )


# Called from MessageManager
# Validates that command is legal based on current state
  preValidateActive: (active, args, player)->
    result = @gameEngine.getPlayerObject(player).on(active, args)
    valid = result[0]
    immediate = result[1]
    if valid
      if immediate
        @callActives()


# Called from PlayerGame
  addActive: (priority, boundActive, currentState, boundValidate)->
    queueObject = {
      priority: priority
      active: boundActive
#      Action owner
      currentState: currentState
      validate: boundValidate
    }
    @activeQueue.push(queueObject)

  callActives: ->
    while @activeQueue.size() > 0
      activeObject = @activeQueue.pop()
      if activeObject.validate()
        activeObject.active()

exports.CommandManager = CommandManager
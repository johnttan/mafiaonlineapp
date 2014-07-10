Heap = require('heap')

log = ->
  for thelog in arguments
    console.log thelog

class PlayerGameParent
  constructor: (roleObject, playerInfo, gameEngine, config)->
    @roleObject = roleObject
    @config = config

    @playerInfo = playerInfo
    @gameEngine = gameEngine
#   Init event object and event buffer
    @events = {}
    @_buffer = []
    #Initialize currentState
    @currentState = {}
    roleObject.initializeState(@currentState)
    @currentState.name = playerInfo.name
    #   Set instance variables to roleObject specifics
    @active = roleObject.active
    @validateActive = roleObject.validateActive

    for action in roleObject.actions
      @addToBuffer(action, roleObject[action])

    @_flushBuffer()

  getCurrentState: ->
    return @currentState
  on: (action, args)->
    if action == 'active'
      if @validateActive(args, @currentState, @gameEngine)
        activeBound = @active.func.bind(undefined, args, @currentState, @gameEngine)
        validateBound = @validateActive.bind(undefined, args, @currentState, @gameEngine)
        @gameEngine.getCommandManager().addActive(@active.priority, activeBound, @currentState, validateBound)
#       Returns true if valid
        return [true, @active.immediate]
      return [false, @active.immediate]
    else
      while @events[action].size() > 0
        action_object = @events[action].pop()
        #      Reaction call with args object
        persistent = action_object.func(args, @currentState, @gameEngine)
        if persistent
          @addToBuffer(action, action_object)
      @_flushBuffer()

  addToBuffer: (action, action_object)->
    @_buffer.push([action, action_object])

  _flushBuffer: ()->
    while @_buffer.length > 0
      buffered = @_buffer.pop()
      action = buffered[0]
      reaction = buffered[1]
      if not @events[action]
        @events[action] = new Heap(
          (a, b)->
            return if a.priority < b.priority then 1 else -1
        )
      @events[action].push(reaction)
  _add: (action, actionsobject)->
    if not @events[action]
      @events[action] = new Heap(
        (a, b)->
          return if a.priority < b.priority then 1 else -1
      )
    @events[action].push(actionsobject)

  endTurn: (turn)->
    @._flushBuffer()


class PlayerGame extends PlayerGameParent
  constructor: (roleObject, playerInfo, gameEngine, config)->
    super(roleObject, playerInfo, gameEngine, config)
  # Helper function for effects that need additional logic
  #  Role Changers are usually last to be called
  changeRole: (roleObject)->
    for own action, action_heap of @.actions
      while action_heap.size() > 0
        action_object = action_heap.pop()
        if action_object.roleID is not @.roleID
          @.addToBuffer(action, action_object)
      delete @.actions[action]
    for action in roleObject.actions
      @addToBuffer(action, roleObject[action])
    @_flushBuffer()

    if not roleObject.initializeState
      @initializeState = @config.defaultInitializeState
    else
      @initializeState = roleObject.initializeState

    @initializeState(@currentState)


  addToVisited: (target)->
    currentTurn = @gameEngine.getTurn()
    if not @currentState.visited[currentTurn]
      @currentState.visited[currentTurn] = []
    @currentState.visited[currentTurn].push(target)

  addToVisitors: (visitor)->
    currentTurn = @gameEngine.getTurn()
    if not @currentState.visitors[currentTurn]
      @currentState.visitors[currentTurn] = []
    @currentState.visitors[currentTurn].push(visitor)




exports.PlayerGame = PlayerGame
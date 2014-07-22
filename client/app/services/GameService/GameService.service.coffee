'use strict'

angular.module('mafiaOnlineApp').service 'GameService', [
  class Game
    constructor: ->
      @matchmakingSocket = undefined
      @gameSocket = undefined
      @mainSocket = io('/')
      @user = {name: undefined}
      @playerFound = false
      @gameUpdate = {}
      do(game=@)->
        game.mainSocket.on('playerNotFound', ->
            console.log 'playerNotFound'
            game.playerFound = false
            if game.user.name
              game.addPlayer(game.user.name)

        )
        game.mainSocket.on('playerFound', (user)->
            game.user = user
            game.playerFound = true
            console.log user
        )

    addPlayer: (name)->
      do(game=@)->
        console.log 'adding', name
        game.user.name = name
        if not game.playerFound
          game.mainSocket.emit('addPlayer', game.user)

    startQueue: ->
      do(game=@)->
        if game.playerFound
          game.matchmakingSocket = io('/matchmaking')
          console.log 'queuestart'
          game.matchmakingSocket.on('playerNotFound', ->
            console.log 'playerNotFound matchmaking'
            game.matchmakingSocket.emit('addPlayer', game.user)
          )
          game.matchmakingSocket.on('playerFound', (user)->
            game.user = user
            game.gameUpdate.user = user
            game.update(game.gameUpdate)
            console.log user, 'matchmaking'
            console.log 'queue joined'
            game.joinQueue()
          )
      
    joinQueue: ->
        do(game=@)->
          game.matchmakingSocket.on('match_found', (namespace)->
            game.matchmakingSocket.disconnect(true)
            game.matchmakingSocket = null
            game.gotGame()
            console.log namespace, 'found'
            game.gameSocket = io(namespace)
            console.log 'match_found and connected'

            game.gameSocket.on('endGame', (wins)->
              game.gameUpdate.wins = wins
              game.update(game.gameUpdate)

            )
            game.gameSocket.on('joined', (playersInfo)->
              game.gameUpdate.playersInfo = playersInfo
              game.ingame = true
              game.update(game.gameUpdate)

            )
            game.gameSocket.on('left', (playersInfo)->
              game.gameUpdate.playersInfo = playersInfo
              console.log('left in service')
              game.update(game.gameUpdate)

            )

            game.gameSocket.on('slowChat', (timeO)->
              chatMessage = {
                who: 'System'
                room: 'public'
                message: 'You can only chat every 300ms'
                time: timeO.time
              }
              game.newChat(chatMessage)
            )

            game.gameSocket.on('join_failed', ->
              console.log 'join_failed', 'retrying queue'
              game.gameSocket.disconnect(true)
              game.joinQueue()
              game.update(game.gameUpdate)

            )

            game.gameSocket.on('gameUpdate', (gameState)->
              game.gameState = gameState
              console.log 'gameupdate received'
              if gameState isnt null
                game.gameUpdate.ingame = true
              if gameState.turn % 2 != 0 and game.gameState.legalActions.length isnt 0
                game.gameUpdate.showAction = true
              game.gameUpdate.gameState = gameState
              game.gameUpdate.user.role = gameState.role
              game.gameUpdate.playersInfo = gameState.publicPlayers
              game.update(game.gameUpdate)

            )

            game.gameSocket.on('voteUpdate', (votes)->
              console.log 'voteUpdate in service'
              game.gameUpdate.votes = votes
              game.update(game.gameUpdate)
            )

            game.gameSocket.on('newChat', (newChat)->
              console.log 'gotchat', newChat
              game.newChat(newChat)
            )
          )
          game.matchmakingSocket.emit('joinQueue')
          console.log 'emit joinQueue'
    startGame: ->
      do(game=@)->
        game.gameSocket.emit('startGame')

    action: (actionObject)->
      do(game=@)->
        console.log 'doing action ', actionObject
        game.gameSocket.emit('action', actionObject)
    lynch: (target)->
      do(game=@)->
        if target
          console.log 'sending lynch vote in service'
          game.gameSocket.emit('voteLynch', target)

    sendChat: (chatMessage)->
      do(game=@)->
        console.log 'chatting', chatMessage
        if chatMessage.room
          game.gameSocket.emit('chat', chatMessage)
          console.log game.gameSocket
]
  # AngularJS will instantiate a singleton by calling 'new' on this function
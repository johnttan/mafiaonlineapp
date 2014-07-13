'use strict'

angular.module('mafiaOnlineApp').controller 'MainCtrl', ['$scope', '$http', '$state',($scope, $http, $state) ->
  socket = io('/')
  socket.on('playerNotFound', ->
    console.log 'playerNotFound'
    socket.emit('addPlayer', {name: 'loltest'})
  )
  socket.on('playerFound', (user)->
    $scope.user = user
    console.log user
    $scope.joinQueue()
  )


  $scope.ingame = false
  $scope.changeRoute = (route)->
    $state.go(route)

  $scope.joinQueue = ->
    socket = io('/matchmaking')
    socket.on('match_found', (namespace)->
      socket.disconnect(true)
      console.log namespace, 'found'
      $scope.gameSocket = io(namespace)
      console.log 'match_found and connected'

      $scope.gameSocket.on('endGame', (wins)->
        $scope.wins = wins
        $scope.$digest()
      )
      $scope.gameSocket.on('joined', (playersInfo)->
        $scope.playersInfo = playersInfo
        $scope.ingame = true
        $scope.$digest()
      )
      $scope.gameSocket.on('left', (playersInfo)->
        $scope.playersInfo = playersInfo
        $scope.$digest()
      )

      $scope.gameSocket.on('join_failed', ->
        console.log 'join_failed', 'retrying queue'
        $scope.gameSocket.disconnect(true)
        $scope.joinQueue()
      )

      $scope.gameSocket.on('gameUpdate', (gameState)->
        $scope.gameState = gameState
        console.log 'gameupdate received'
        if gameState isnt null
          $scope.ingame = true
        if gameState.turn % 2 != 0 and $scope.gameState.legalActions.length isnt 0
          $scope.showAction = true
        $scope.$digest()
      )

      $scope.gameSocket.on('voteUpdate', (votes)->
        $scope.votes = votes
        $scope.$digest()
      )
      $scope.gameSocket.on('newChat', (newChat)->
        console.log 'gotchat', newChat
        $scope.newChat(newChat)
        $scope.$digest()
      )
    )

  $scope.action = ->
    if $scope.actionTarget of $scope.gameState.publicPlayers
      actionObject = {
        args: {
          targetname: $scope.actionTarget
        }
        action: 'active'
      }
      console.log 'doing action ', actionObject
      $scope.gameSocket.emit('action', actionObject)
  $scope.startGame = ->
    $scope.gameSocket.emit('startGame')

  $scope.voteLynch = ->
    if $scope.lynchTarget
      console.log 'sending lynch vote'
      $scope.gameSocket.emit('voteLynch', $scope.lynchTarget)
  $scope.chats = []
  $scope.setRole = (role)->
    $scope.role = role
  $scope.loadTest = ()->
    lol = ()->
      socket.emit('checkState')
    $scope.load = setInterval(lol, $scope.loadtime)
  $scope.newChat = (newChat)->
    $scope.chats.push(newChat)
  $scope.sendChat = ->
    if $scope.latestChat isnt '' or ' '
      if not $scope.gameState
        room = 'public'
      else
        if $scope.gameState.turn % 2 == 0
          room = 'public'
        else if $scope.gameState.role is 'mafia'
          room = 'mafia'
      chatMessage = {
        message: $scope.latestChat
        room: room
      }
      console.log 'chatting', chatMessage
      if chatMessage.room
        $scope.gameSocket.emit('chat', chatMessage)
        $scope.latestChat = ''
        console.log $scope.gameSocket
  $scope.checkState = ->
    $scope.gameSocket.emit('checkState')

  $scope.addThing = ->
    console.log('sending addme')
    socket.emit('addMe', {
      name: $scope.name
      role: $scope.role
    })

  $scope.deleteThing = (thing) ->
    $http.delete '/api/things/' + thing._id

  $scope.$on '$destroy', ->
    socket.unsyncUpdates 'thing'

]
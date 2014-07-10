'use strict'

angular.module('mafiaOnlineApp').controller 'MainCtrl', ['$scope', '$http', ($scope, $http) ->
  $scope.ingame = false
  socket = io('/tested')
  socket.on('gameUpdate', (gameState)->
    $scope.gameState = gameState
    console.log 'gameupdate received'
    if gameState isnt null
      $scope.ingame = true
    $scope.$digest()
  )
  socket.on('newChat', (newChat)->
      console.log 'gotchat', newChat
      $scope.newChat(newChat)
      $scope.$digest()
  )
  $scope.chats = []
  $scope.loadTest = ()->
    lol = ()->
      socket.emit('checkState')
    $scope.loadTest = setInterval(lol, $scope.loadtime)
  $scope.newChat = (newChat)->
    $scope.chats.push(newChat)
  $scope.sendChat = ->
    if $scope.gameState.turn % 2 == 0
      room = 'public'
    else
      room = 'mafia'
    chatMessage = {
      message: $scope.latestChat
      room: room
    }
    console.log 'chatting', chatMessage
    socket.emit('chat', chatMessage)
    $scope.latestChat = ''
    console.log socket
  $scope.checkState = ->
    socket.emit('checkState')

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
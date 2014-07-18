'use strict'

angular.module('mafiaOnlineApp').controller 'GameCtrl', ['$scope', 'GameService', ($scope, GameService) ->
  $scope.chats = []
  $scope.newChat = (newChat)->
    $scope.chats.push(newChat)
    console.log('pushing chat onto view', newChat)
    $scope.$digest()
  GameService.newChat = $scope.newChat

  $scope.sendChat = ->
    if $scope.latestChat isnt '' and $scope.latestChat.length > 0
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
        GameService.sendChat(chatMessage)
        $scope.latestChat = ''

  $scope.message = 'Hello'
  $scope.voteLynch = ->
    if $scope.lynchTarget
      console.log 'sending lynch vote'
      GameService.lynch($scope.lynchTarget)
  $scope.action = ->
    if $scope.actionTarget of $scope.gameState.publicPlayers
      actionObject = {
        args: {
          targetname: $scope.actionTarget
        }
        action: 'active'
      }
      console.log 'doing action ', actionObject
      GameService.action(actionObject)
  $scope.players = [

  ]

]
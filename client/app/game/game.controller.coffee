'use strict'

angular.module('mafiaOnlineApp').controller 'GameCtrl', ['$scope', 'GameService', ($scope, GameService) ->
  $scope.chats = []
  $scope.Math = window.Math
  $scope.targetActive = (name)->
    if $scope.targetname is name
      return 'active'
    else
      return 'inactive'
  $scope.newChat = (chats)->
    $scope.chats = chats
    console.log('pushing chat onto view', chats[-1])
    $scope.$digest()
  GameService.newChat = $scope.newChat
  $scope.target = (targetname)->
    console.log 'targetting', targetname
    $scope.targetname = targetname
  $scope.sendChat = ->
    if $scope.latestChat isnt '' and $scope.latestChat.length > 0
      if not $scope.gameState
        room = 'public'
      else
        if $scope.gameState.turn % 2 == 0
          room = 'public'
        else if $scope.gameState.role is 'mafia'
          room = 'mafia'
      if $scope.gameOver
        room = 'public'
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
    if $scope.targetname
      console.log 'sending lynch vote'
      GameService.lynch($scope.targetname)
  $scope.action = ->
    if $scope.targetname of $scope.gameState.publicPlayers
      actionObject = {
        args: {
          targetname: $scope.targetname
        }
        action: 'active'
      }
      console.log 'doing action ', actionObject
      GameService.action(actionObject)

  $scope.players = [

  ]

]
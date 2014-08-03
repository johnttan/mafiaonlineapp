'use strict'
#All of this needs to be put into a service.
#Temporary code for testing socket events.
angular.module('mafiaOnlineApp').controller 'MainCtrl', ['$scope', '$http', '$state', 'GameService', ($scope, $http, $state, GameService) ->
  $scope.GameService = GameService
  $scope.nextTurn = ->
    GameService.gameSocket.emit('checkState')
  GameService.gotGame = ->
    $scope.playButton = 'GAME'
  $scope.playButton = 'PLAY'
  $scope.countTime = 30
  $scope.countDown = ->
    if $scope.countTime > 1
      $scope.countTime -= 1
      setTimeout($scope.countDown, 1000)
      $scope.$digest()
  $scope.previousTurn = 0
  $scope.gameUpdate = (gameUpdate)->
    $scope.wins = gameUpdate.wins
    $scope.gameState = gameUpdate.gameState
    if $scope.gameState and gameUpdate.ingame
      if $scope.gameState.turn > $scope.previousTurn
        console.log 'setting timeout'
        $scope.countTime = 30
        $scope.countDown()
      $scope.previousTurn = $scope.gameState.turn
    $scope.ingame = gameUpdate.ingame
    $scope.votes = gameUpdate.votes
    $scope.playersInfo = gameUpdate.playersInfo
    $scope.user = gameUpdate.user
    console.log(gameUpdate)
    if gameUpdate.wins
      $scope.winAnnouncements = Object.keys(gameUpdate.wins)[0]
      if $scope.winAnnouncements == 'villager'
        $scope.winAnnouncements = 'Village'
      else
        $scope.winAnnouncements = 'Mafia'
      $scope.gameOver = true
      $scope.playButton = 'PLAY AGAIN'
    else
      $scope.gameOver = false
      $scope.winAnnouncements = undefined

    $scope.$digest()
  GameService.update = $scope.gameUpdate
  $scope.changeRoute = (route)->
    $state.go(route)
  $scope.playerFound = (player)->
    $scope.$digest()
  GameService.playerFoundScope = $scope.playerFound
  $scope.startQueue = ->
    if GameService.playerFound and $scope.playButton == 'PLAY' or $scope.playButton == 'PLAY AGAIN'
      if $scope.playButton == 'PLAY AGAIN'
        rematch = true
        $scope.chats = []
        $scope.previousTurn = 0
      $scope.playButton = 'Finding Match'
      console.log rematch
      $state.go('main.game')
      GameService.startQueue(rematch)
    else if $scope.playButton == 'GAME'
      $state.go('main.game')
    else if $scope.playButton == 'GO BACK TO GAME'
      $scope.playButton = 'GAME'
      $state.go('main.game')
  $scope.goToHowTo = ->
    if $scope.playButton == 'GAME'
      $scope.playButton = 'GO BACK TO GAME'
    $state.go('main.howto')


  $scope.addPlayer = ->
    $scope.playerSent = true
    GameService.addPlayer($scope.name)


]
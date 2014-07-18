'use strict'
#All of this needs to be put into a service.
#Temporary code for testing socket events.
angular.module('mafiaOnlineApp').controller 'MainCtrl', ['$scope', '$http', '$state', 'GameService', ($scope, $http, $state, GameService) ->
  $scope.GameService = GameService

  $scope.gameUpdate = (gameUpdate)->
    $scope.wins = gameUpdate.wins
    $scope.gameState = gameUpdate.gameState
    $scope.ingame = gameUpdate.ingame
    $scope.votes = gameUpdate.votes
    $scope.playersInfo = gameUpdate.playersInfo
    $scope.user = gameUpdate.user
    console.log($scope.user)
    $scope.$digest()
  GameService.update = $scope.gameUpdate
  $scope.changeRoute = (route)->
    $state.go(route)
  $scope.startQueue = ->
    if GameService.playerFound
      $state.go('main.game')
      GameService.startQueue()


  $scope.startGame = ->
    GameService.startGame()
  $scope.addPlayer = ->
    $scope.playerSent = true
    GameService.addPlayer($scope.name)

]
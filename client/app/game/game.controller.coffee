'use strict'

angular.module('mafiaOnlineApp').controller 'GameCtrl', ($scope) ->
  $scope.message = 'Hello'
  console.log('controller match instantiated')
  socket1 = io('/')
  socket2 = io('/matchmaking')
  console.log socket1
  console.log socket2
  $scope.players = [

  ]
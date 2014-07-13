'use strict'

angular.module('mafiaOnlineApp').config ($stateProvider) ->
  $stateProvider.state 'main.game',
    url: 'game'
    templateUrl: 'app/game/game.html'
    controller: 'GameCtrl'

'use strict'

angular.module('mafiaOnlineApp').config ($stateProvider) ->
  $stateProvider.state 'main.howto',
    url: '/howto'
    templateUrl: 'app/howto/howto.html'
    controller: 'HowtoCtrl'

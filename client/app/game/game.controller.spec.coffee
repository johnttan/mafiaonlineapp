'use strict'

describe 'Controller: GameCtrl', ->

  # load the controller's module
  beforeEach module('mafiaOnlineApp')
  GameCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject(($controller, $rootScope) ->
    scope = $rootScope.$new()
    GamegCtrl = $controller('GameCtrl',
      $scope: scope
    )
  )
  it 'should ...', ->
    expect(1).toEqual 1

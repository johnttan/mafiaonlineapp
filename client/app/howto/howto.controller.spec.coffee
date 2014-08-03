'use strict'

describe 'Controller: HowtoCtrl', ->

  # load the controller's module
  beforeEach module('mafiaOnlineApp')
  HowtoCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject(($controller, $rootScope) ->
    scope = $rootScope.$new()
    HowtoCtrl = $controller('HowtoCtrl',
      $scope: scope
    )
  )
  it 'should ...', ->
    expect(1).toEqual 1

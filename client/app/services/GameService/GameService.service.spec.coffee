'use strict'

describe 'Service: Gameservice', ->

  # load the service's module
  beforeEach module('mafiaOnlineApp')

  # instantiate service
  Gameservice = undefined
  beforeEach inject((_Gameservice_) ->
    Gameservice = _Gameservice_
  )
  it 'should do something', ->
    expect(!!Gameservice).toBe true

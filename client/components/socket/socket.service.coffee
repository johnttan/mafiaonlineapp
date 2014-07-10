# global io 

'use strict'

angular.module('mafiaOnlineApp').factory 'socket', ->

#  ioSocket = io('/tested')
#  socket = ioSocket
#  socket: ioSocket
#
#  ###
#  Register listeners to sync an array with updates on a model
#
#  Takes the array we want to sync, the model name that socket updates are sent from,
#  and an optional callback function after new items are updated.
#
#  @param {String} modelName
#  @param {Array} array
#  @param {Function} cb
#  ###
#  syncUpdates: (modelName, array, cb) ->
#    cb = cb or angular.noop
#
#    ###
#    Syncs item creation/updates on 'model:save'
#    ###
#    socket.on modelName + ':save', (item) ->
#      oldItem = _.find(array,
#        _id: item._id
#      )
#      index = array.indexOf(oldItem)
#      event = 'created'
#
#      # replace oldItem if it exists
#      # otherwise just add item to the collection
#      if oldItem
#        array.splice index, 1, item
#        event = 'updated'
#      else
#        array.push item
#      cb event, item, array
#
#    ###
#    Syncs removed items on 'model:remove'
#    ###
#    socket.on modelName + ':remove', (item) ->
#      event = 'deleted'
#      _.remove array,
#        _id: item._id
#
#      cb event, item, array
#
#  ###
#  Removes listeners for a models updates on the socket
#
#  @param modelName
#  ###
#  unsyncUpdates: (modelName) ->
#    socket.removeAllListeners modelName + ':save'
#    socket.removeAllListeners modelName + ':remove'
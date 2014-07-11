/**
 * Socket.io configuration
 */
var QueueManager = require('./Mafia/QueueManager').QueueManager
'use strict';
var config = require('./environment');
var util = require('util')
// When the user disconnects.. perform this
function onDisconnect(socket) {
}

// When the user connects.. perform this
function onConnect(socket) {
  // When the client emits 'info', this listens and executes
  socket.on('info', function (data) {
    console.info('[%s] %s', socket.address, JSON.stringify(data, null, 2));
  });

  // Insert sockets below
  require('../api/thing/thing.socket').register(socket);
}

module.exports = function (socketio) {

  // The amount of detail that the server should output to the logger.
  // 0 - error
  // 1 - warn
  // 2 - info
  // 3 - debug
  socketio.set('log level', 2);
  new QueueManager(socketio)
  // We can authenticate socket.io users and access their token through socket.handshake.decoded_token
  //
  // 1. You will need to send the token in `client/components/socket/socket.service.js`
  //
  // 2. Require authentication here:
  // socketio.set('authorization', require('socketio-jwt').authorize({
  //   secret: config.secrets.session,
  //   handshake: true
  // }));
//
//var roles = require('./Mafia/roles')
//  socketio.of('/tested').on('connection', function (socket) {
////    socket.address = socket.handshake.address.address + ':' +
////                     socket.handshake.address.port;
//    var nspname = socket.nsp.name
//    socket.connectedAt = new Date();
//    if(!games[nspname].gameengine){
//      games[nspname].gameengine = new GameEngine(socketio, games[nspname].namespace, Config)
//    };
//
//    socket.on('addMe', function(playerInfo){
//        if(playerInfo.name && playerInfo.role in roles){
//            socket.playerName = playerInfo.name
//
//            games[nspname].gameengine.addPlayer(playerInfo)
//        }
//    })
//
//    // Call onDisconnect.
//    socket.on('disconnect', function () {
//        games[nspname].gameengine.deletePlayer(socket.playerName)
////        var gengine = util.inspect(games['test'].gameengine.getGameState())
////        console.log(gengine)
//      onDisconnect(socket);
//      console.info('[%s] DISCONNECTED', socket.address);
//    });
//
//    // Call onConnect.
//    onConnect(socket);
//    console.info('[%s] CONNECTED', socket.address);
//  });
};
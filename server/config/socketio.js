/**
 * Socket.io configuration
 */

'use strict';
var Config = new require('./Mafia/config').Config
var GameEngine = require('./Mafia/GameEngine').GameEngine
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
  var newNamespace = socketio.of('/tested')
  var games = {
  'test': {
    'namespace': newNamespace,
    'gameengine': undefined
  }
  }
  // The amount of detail that the server should output to the logger.
  // 0 - error
  // 1 - warn
  // 2 - info
  // 3 - debug
  socketio.set('log level', 2);

  // We can authenticate socket.io users and access their token through socket.handshake.decoded_token
  //
  // 1. You will need to send the token in `client/components/socket/socket.service.js`
  //
  // 2. Require authentication here:
  // socketio.set('authorization', require('socketio-jwt').authorize({
  //   secret: config.secrets.session,
  //   handshake: true
  // }));

var roles = require('./Mafia/roles')
  socketio.of('/tested').on('connection', function (socket) {
//    socket.address = socket.handshake.address.address + ':' +
//                     socket.handshake.address.port;
    socket.connectedAt = new Date();
    if(!games['test'].gameengine){
      games['test'].gameengine = new GameEngine(socketio, games['test'].namespace, Config)
    };
    socket.on('checkState', function(){
        games['test'].gameengine.nextTurn()
        var publicState = games['test'].gameengine.getAllPublicState()
        for(var j=0;j<games['test'].namespace.sockets.length;j++){
            var player = games['test'].namespace.sockets[j]
            if(player != undefined){
                var playerstate = publicState[player.playerName]
                player.emit('gameUpdate', playerstate)
                if(playerstate != undefined){
                    console.log(playerstate)
                }
            }

        }
        var gengine = util.inspect(games['test'].gameengine.getGameState())
        console.log(gengine)
    })
    socket.on('chat', function(chatMessage){
        console.log('received', chatMessage)
        var newChat = {
            'who': socket.playerName,
            'message': chatMessage.message,
            'time': new Date()
        }
        if(games['test'].gameengine.getTurn() % 2 == 0){
            console.log('sentpublic', newChat)
            socketio.of('/tested').in('public').emit('newChat', newChat)
        }else{
            var availablechats = games['test'].gameengine.getPublicState(socket.playerName).chats
            console.log(availablechats)
            if(Object.keys(availablechats).indexOf(chatMessage.room) >= 0){
                console.log('sentnight', newChat)
                var room = chatMessage.room
                socketio.of('/tested').in(room).emit('newChat', newChat)
            }
        }
    })
    socket.on('addMe', function(playerInfo){
        if(playerInfo.name && playerInfo.role in roles){
            socket.playerName = playerInfo.name

            games['test'].gameengine.addPlayer(playerInfo)
            var publicState = games['test'].gameengine.getAllPublicState()
            for(var player in games['test'].namespace.sockets){
                var playerobj = games['test'].namespace.sockets[player]
                var playerstate = publicState[playerobj.playerName]
                playerobj.emit('gameUpdate', playerstate)

            }
        }
    })

    // Call onDisconnect.
    socket.on('disconnect', function () {
        games['test'].gameengine.deletePlayer(socket.playerName)
//        var gengine = util.inspect(games['test'].gameengine.getGameState())
//        console.log(gengine)
      onDisconnect(socket);
      console.info('[%s] DISCONNECTED', socket.address);
    });

    // Call onConnect.
    onConnect(socket);
    console.info('[%s] CONNECTED', socket.address);
  });
};
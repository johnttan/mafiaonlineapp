// Generated by CoffeeScript 1.6.3
(function() {
  var UserManager, randomName, uuid;

  randomName = require('sillyname');

  uuid = require('node-uuid');

  UserManager = (function() {
    function UserManager() {
      this.userMap = {};
    }

    UserManager.prototype.setUser = function(socket, playerInfo) {
      var iterationCounter, timeAdded, user;
      if (!playerInfo.name) {
        playerInfo.name = randomName();
        iterationCounter = 0;
        while (!(playerInfo.name in this.userMap)) {
          playerInfo.name = randomName();
          iterationCounter += 1;
          if (iterationCounter > 10) {
            playerInfo.name = playerInfo.name + String(Math.random().toString(36).substring(2, 5));
          }
        }
      }
      timeAdded = new Date();
      user = {
        socketID: socket.id,
        name: playerInfo.name,
        sessionID: uuid.v4(),
        timeAdded: timeAdded,
        game: void 0
      };
      socket.playerName = playerInfo.name;
      this.userMap[socket.id] = user;
      return socket.emit('playerFound', user);
    };

    UserManager.prototype.getUser = function(socketID) {
      return this.userMap[socketID];
    };

    UserManager.prototype.updateUser = function(socket, playerInfo) {
      var playerFound, user;
      playerFound = false;
      user = this.userMap[playerInfo.name];
      if (user) {
        if (this.playerInfo.sessionID === user.sessionID) {
          playerFound = true;
        }
        if (playerFound) {
          user.socketID = socket.id;
          if (user.game) {
            if (user.game.checkGameEnd(playerInfo.name)) {
              return socket.emit('gameEnded', user.game.getID());
            } else {
              return socket.emit('gameAt', user.game.getID());
            }
          }
        }
      } else {
        return this.setUser(socket, playerInfo);
      }
    };

    return UserManager;

  })();

  exports.UserManager = new UserManager();

}).call(this);

/*
//@ sourceMappingURL=UserManager.map
*/
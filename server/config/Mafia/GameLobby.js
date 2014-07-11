// Generated by CoffeeScript 1.6.3
(function() {
  var GameEngine, GameLobby;

  GameEngine = require('./GameEngine').GameEngine;

  GameLobby = (function() {
    function GameLobby(io, ioNamespace, queue, config) {
      var _i, _j, _ref, _ref1;
      this.queue = queue;
      this.ioNamespace = ioNamespace;
      this.io = io;
      this.config = config;
      this.playersInfo = {};
      this.gameEngine = new GameEngine(io, ioNamespace, this.playersInfo, config);
      this.availableRoles = config.availableRoles;
      this.inQueue = true;
      for (_i = _j = _ref = this.availableRoles.length - 1; _ref <= 1 ? _j <= 1 : _j >= 1; _i = _ref <= 1 ? ++_j : --_j) {
        _j = Math.floor(Math.random() * (_i + 1));
        _ref1 = [this.availableRoles[_j], this.availableRoles[_i]], this.availableRoles[_i] = _ref1[0], this.availableRoles[_j] = _ref1[1];
      }
      console.log(this.availableRoles);
      (function(lobby) {
        ioNamespace.on('connection', function(socket) {
          var playerInfo, playername;
          playername = (Math.random() + 1).toString(36).substring(7);
          playerInfo = {
            name: playername
          };
          socket.playerName = playername;
          return lobby.addPlayer(socket, playerInfo);
        });
        ioNamespace.on('disconnect', function(socket) {
          return lobby.removePlayer(socket.playerName);
        });
        return ioNamespace.on('endGame', function(wins) {
          return console.log('lobby got endGame', wins);
        });
      })(this);
    }

    GameLobby.prototype.checkStatus = function() {
      if (this.availableRoles.length === 0 || this.gameEngine.started === true) {
        return false;
      } else {
        return true;
      }
    };

    GameLobby.prototype.outOfQueue = function() {
      return this.inQueue = false;
    };

    GameLobby.prototype.addPlayer = function(socket, playerInfo) {
      var playerGameInfo, role;
      if (this.checkStatus()) {
        this.playersInfo[socket.playerName] = playerInfo;
        role = this.availableRoles.pop();
        playerGameInfo = {
          name: playerInfo.name,
          role: role
        };
        this.gameEngine.addPlayer(playerGameInfo, socket);
        this.addGameListeners(socket);
        return this.ioNamespace.emit('joined', this.playersInfo);
      } else {
        return socket.emit('join_failed');
      }
    };

    GameLobby.prototype.removePlayer = function(socket) {
      if (!this.gameEngine.started) {
        this.availableRoles.push(this.gameEngine.getPlayerRole(socket.playerName));
      }
      delete this.playersInfo[socket.playerName];
      this.gameEngine.deletePlayer(socket.playerName);
      if (!this.inQueue && !this.gameEngine.started) {
        this.queue.addToQueue({
          game: this,
          namespace: this.ioNamespace
        });
      }
      return this.ioNamespace.emit('left', this.playersInfo);
    };

    GameLobby.prototype.addGameListeners = function(socket) {
      return (function(lobby) {
        return socket.on('disconnect', function() {
          return lobby.removePlayer(socket);
        });
      })(this);
    };

    return GameLobby;

  })();

  exports.GameLobby = GameLobby;

}).call(this);

/*
//@ sourceMappingURL=GameLobby.map
*/

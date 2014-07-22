// Generated by CoffeeScript 1.6.3
(function() {
  var CommandManager, GameEngine, MessageManager, PlayerGame, PublicStateManager,
    __hasProp = {}.hasOwnProperty;

  PlayerGame = require('./PlayerGame').PlayerGame;

  CommandManager = require('./CommandManager').CommandManager;

  PublicStateManager = require('./PublicStateManager').PublicStateManager;

  MessageManager = require('./MessageManager').MessageManager;

  GameEngine = (function() {
    function GameEngine(io, ioNamespace, playersInfo, config) {
      this.ioNamespace = ioNamespace;
      this.config = config;
      this.roles = config.roles;
      this.gameState = {};
      this.config.defaultGameState(this.gameState);
      this.playersInfo = playersInfo;
      this.manager = new CommandManager(this);
      this.publicStateManager = new PublicStateManager();
      this.messageManager = new MessageManager(io, ioNamespace, this);
      this.started = false;
      this.winConditions = {};
    }

    GameEngine.prototype.nextTurn = function() {
      var player, playerObject, role, wincondition, wins, _ref, _ref1;
      if (this.started) {
        this.manager.nextTurn();
        this.gameState.turn += 1;
        this.cleanupDead();
        _ref = this.gameState.players;
        for (player in _ref) {
          if (!__hasProp.call(_ref, player)) continue;
          playerObject = _ref[player];
          playerObject.endTurn(this.gameState.turn);
        }
        this.publicStateManager.nextTurn(this.gameState.turn);
        this.messageManager.nextTurn();
        wins = {};
        _ref1 = this.winConditions;
        for (role in _ref1) {
          if (!__hasProp.call(_ref1, role)) continue;
          wincondition = _ref1[role];
          if (wincondition.check(this.gameState)) {
            wins[role] = true;
          }
        }
        console.log(wins, 'wins');
        if (Object.keys(wins).length > 0) {
          this.wins = wins;
          return this.messageManager.endGame(this.wins);
        }
      }
    };

    GameEngine.prototype.lynch = function(player) {
      this.gameState.players[player].getCurrentState().dead = true;
      this.gameState.players[player].getCurrentState().causeofdeath = 'lynch';
      this.cleanupDead();
      return console.log('lynched', 'player');
    };

    GameEngine.prototype.cleanupDead = function() {
      var player, playerObj, _ref, _results;
      _ref = this.gameState.players;
      _results = [];
      for (player in _ref) {
        playerObj = _ref[player];
        if (playerObj.getCurrentState().dead && !(player in this.gameState.grave)) {
          console.log(playerObj.getCurrentState());
          this.gameState.grave[player] = {
            role: playerObj.getCurrentState().roleID
          };
          this.publicStateManager.removePlayer(player, playerObj.getCurrentState().roleID);
          _results.push(this.messageManager.removePlayer(player));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    GameEngine.prototype.startGame = function() {
      if (!this.started) {
        this.started = true;
        return this.pushPublicStates();
      }
    };

    GameEngine.prototype.pushPublicStates = function() {
      if (this.started) {
        return this.messageManager.pushPublicStates();
      }
    };

    GameEngine.prototype.addPlayer = function(playerInfo, socket) {
      if (!this.started) {
        this.gameState.players[playerInfo.name] = new PlayerGame(this.roles[playerInfo.role], playerInfo, this, this.config);
        this.publicStateManager.addPlayer(this.gameState.players[playerInfo.name], this, this.config);
        console.log(this.playersInfo);
        return this.messageManager.addPlayer(socket);
      }
    };

    GameEngine.prototype.addWinCondition = function(winCondition) {
      if (!(winCondition.role in this.winConditions)) {
        return this.winConditions[winCondition.role] = winCondition;
      }
    };

    GameEngine.prototype.removeWinCondition = function(role) {
      return delete this.winConditions[role];
    };

    GameEngine.prototype.sendMessage = function(socket, chatMessage) {
      return this.messageManager.sendMessage(socket, chatMessage);
    };

    GameEngine.prototype.deletePlayer = function(playerName) {
      if (this.started) {
        console.log('game already started', 'killing', playerName);
        this.gameState.players[playerName].getCurrentState().dead = true;
        return this.cleanupDead();
      } else {
        delete this.gameState.players[playerName];
        this.publicStateManager.removePlayer(playerName);
        return this.messageManager.removePlayer(playerName);
      }
    };

    GameEngine.prototype.getMessageManager = function() {
      return this.messageManager;
    };

    GameEngine.prototype.getCommandManager = function() {
      return this.manager;
    };

    GameEngine.prototype.getAllPublicState = function() {
      return this.publicStateManager.getAllPublicState();
    };

    GameEngine.prototype.getPublicState = function(player) {
      return this.publicStateManager.getPublicState(player);
    };

    GameEngine.prototype.getGameState = function() {
      return this.gameState;
    };

    GameEngine.prototype.getAllPlayers = function() {
      return this.playersInfo;
    };

    GameEngine.prototype.getPlayerInfo = function(player) {
      return this.playersInfo[player];
    };

    GameEngine.prototype.getPlayerRole = function(player) {
      return this.getPlayerObject(player).playerInfo.role;
    };

    GameEngine.prototype.getPlayerObject = function(player) {
      return this.gameState.players[player];
    };

    GameEngine.prototype.getTurn = function() {
      return this.gameState.turn;
    };

    return GameEngine;

  })();

  exports.GameEngine = GameEngine;

}).call(this);

/*
//@ sourceMappingURL=GameEngine.map
*/

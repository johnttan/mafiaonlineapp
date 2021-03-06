// Generated by CoffeeScript 1.6.3
(function() {
  var MessageManager,
    __hasProp = {}.hasOwnProperty,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  MessageManager = (function() {
    function MessageManager(io, ioNamespace, gameEngine) {
      this.gameEngine = gameEngine;
      this.publicState = gameEngine.getAllPublicState();
      this.ioNamespace = ioNamespace;
      this.commandManager = this.gameEngine.getCommandManager();
      this.gameEnd = false;
      this.io = io;
      this.votes = {
        lynch: {},
        mafia: {}
      };
      this.throttle = {};
    }

    MessageManager.prototype.endGame = function(wins) {
      this.gameEnd = true;
      return this.ioNamespace.emit('endGame', wins);
    };

    MessageManager.prototype.voteResolve = function() {
      var chosen, newO, person, second, thereIsVote, vote, voteArray, voteCount, voteKey, voter, _i, _len, _ref, _ref1, _ref2;
      if (this.gameEngine.getTurn() % 2 === 0) {
        voteKey = 'lynch';
      } else {
        voteKey = 'mafia';
      }
      voteCount = {};
      thereIsVote = false;
      _ref = this.votes[voteKey];
      for (person in _ref) {
        if (!__hasProp.call(_ref, person)) continue;
        vote = _ref[person];
        if (vote) {
          thereIsVote = true;
          if (!voteCount[vote]) {
            voteCount[vote] = 0;
          }
          voteCount[vote] += 1;
        }
      }
      if (thereIsVote) {
        voteArray = [];
        _ref1 = Object.keys(voteCount);
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          vote = _ref1[_i];
          newO = {};
          newO.votes = voteCount[vote];
          newO.name = vote;
          voteArray.push(newO);
        }
        voteArray.sort(function(a, b) {
          return a.votes - b.votes;
        });
        chosen = voteArray.pop();
        second = voteArray.pop();
        console.log(voteCount, voteKey, voteArray);
        if (!second) {
          second = {
            votes: 0
          };
        }
        if (chosen.votes > second.votes) {
          console.log(chosen, 'chosen by votes');
          if (voteKey === 'lynch') {
            this.gameEngine.lynch(chosen.name);
          } else if (voteKey === 'mafia') {
            _ref2 = this.votes[voteKey];
            for (voter in _ref2) {
              if (!__hasProp.call(_ref2, voter)) continue;
              vote = _ref2[voter];
              if (vote === chosen.name) {
                this.commandManager.preValidateActive('active', {
                  targetname: chosen.name
                }, voter);
              }
            }
          }
        }
      }
      delete this.votes;
      return this.votes = {
        lynch: {},
        mafia: {}
      };
    };

    MessageManager.prototype.nextTurn = function() {
      delete this.votes;
      this.votes = {
        lynch: {},
        mafia: {}
      };
      this.ioNamespace["in"]('public').emit('voteUpdate', this.votes);
      this.synchChats();
      this.pushPublicStates();
      return (function(messager) {
        var turnfunc;
        turnfunc = function() {
          if (!messager.gameEngine.wins) {
            return messager.gameEngine.nextTurn();
          }
        };
        return setTimeout(turnfunc, 30000);
      })(this);
    };

    MessageManager.prototype.addPlayer = function(socket) {
      (function(messager) {
        socket.on('voteLynch', function(target) {
          if (!(socket.playerName in messager.publicState[socket.playerName].grave)) {
            if (!messager.gameEnd) {
              if (messager.gameEngine.started) {
                if (messager.gameEngine.getTurn() % 2 === 0 && target in messager.publicState) {
                  console.log(target, 'lynch');
                  messager.votes.lynch[socket.playerName] = target;
                  return messager.ioNamespace["in"]('public').emit('voteUpdate', messager.votes);
                }
              }
            }
          }
        });
        socket.on('action', function(actionObject) {
          var _ref;
          if (!(socket.playerName in messager.publicState[socket.playerName].grave)) {
            if (!messager.gameEnd) {
              if (messager.gameEngine.started) {
                if (messager.publicState[socket.playerName].role === 'mafia' && messager.gameEngine.getTurn() % 2 !== 0 && actionObject.args.targetname in messager.publicState) {
                  messager.votes.mafia[socket.playerName] = actionObject.args.targetname;
                  return messager.ioNamespace["in"]('mafia').emit('voteUpdate', messager.votes);
                } else if (_ref = actionObject.action, __indexOf.call(messager.publicState[socket.playerName].legalActions, _ref) >= 0) {
                  return messager.commandManager.preValidateActive(actionObject.action, actionObject.args, socket.playerName);
                }
              }
            }
          }
        });
        return socket.on('chat', function(chatMessage) {
          var current;
          if (!(socket.playerName in messager.publicState[socket.playerName].grave)) {
            current = new Date();
            if (!(socket.playerName in messager.throttle)) {
              return messager.throttle[socket.playerName] = new Date();
            } else {
              if ((current - messager.throttle[socket.playerName]) < 300) {
                return socket.emit('slowChat', {
                  time: new Date()
                });
              } else {
                messager.throttle[socket.playerName] = new Date();
                if (!messager.gameEngine.started || messager.gameEnd) {
                  chatMessage.room = 'public';
                }
                chatMessage.playerName = socket.playerName;
                console.log('received', chatMessage, ' from ', socket.playerName);
                if (chatMessage.message !== '') {
                  return messager.gameEngine.sendMessage(socket, chatMessage);
                }
              }
            }
          }
        });
      })(this);
      this.synchChats();
      return this.throttle[socket.playerName] = new Date();
    };

    MessageManager.prototype.removePlayer = function(playerName) {
      return this.pushPublicStates();
    };

    MessageManager.prototype.synchChats = function() {
      var inside, playerPublicState, room, socket, _i, _j, _len, _len1, _ref, _ref1, _results;
      _ref = this.ioNamespace.sockets;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        socket = _ref[_i];
        playerPublicState = this.publicState[socket.playerName];
        if (playerPublicState !== void 0) {
          _ref1 = socket.rooms;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            room = _ref1[_j];
            if (!playerPublicState.chats[room]) {
              socket.leave(room);
            }
          }
          _results.push((function() {
            var _ref2, _results1;
            _ref2 = playerPublicState.chats;
            _results1 = [];
            for (room in _ref2) {
              inside = _ref2[room];
              if (inside) {
                _results1.push(socket.join(room));
              } else {
                _results1.push(void 0);
              }
            }
            return _results1;
          })());
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    MessageManager.prototype.pushPublicStates = function(init) {
      var playerPublicState, socket, tempstate, _i, _len, _ref;
      if (!this.gameEnd) {
        _ref = this.ioNamespace.sockets;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          socket = _ref[_i];
          if (socket) {
            playerPublicState = this.publicState[socket.playerName];
            if (playerPublicState) {
              if (this.gameEngine.started) {
                if (init) {
                  playerPublicState.started = true;
                }
                socket.emit('gameUpdate', playerPublicState);
              } else {
                tempstate = JSON.parse(JSON.stringify(playerPublicState));
                delete tempstate['role'];
                socket.emit('gameUpdate', tempstate);
              }
            }
          }
        }
        return (function(messager) {
          var turnfunc;
          if (init) {
            turnfunc = function() {
              if (!messager.gameEngine.wins) {
                return messager.gameEngine.nextTurn();
              }
            };
            console.log('setinit timeout');
            return setTimeout(turnfunc, 30000);
          }
        })(this);
      }
    };

    MessageManager.prototype.sendMessage = function(socket, messageObject) {
      var newChat;
      newChat = {
        who: socket.playerName,
        message: messageObject.message,
        room: messageObject.room,
        time: new Date()
      };
      if (this.gameEngine.getTurn() % 2 !== 0 && messageObject.room !== 'public') {
        if (this.publicState[socket.playerName].chats[messageObject.room]) {
          console.log('emitting in ', this.ioNamespace.name, messageObject.room);
          return this.io.of(this.ioNamespace.name)["in"](messageObject.room).emit('newChat', newChat);
        }
      } else if (messageObject.room === 'public') {
        if (this.publicState[socket.playerName]) {
          console.log('emitting in ', this.ioNamespace.name, messageObject.room);
          return this.io.of(this.ioNamespace.name)["in"]('public').emit('newChat', newChat);
        }
      }
    };

    return MessageManager;

  })();

  exports.MessageManager = MessageManager;

}).call(this);

/*
//@ sourceMappingURL=MessageManager.map
*/

// Generated by CoffeeScript 1.6.3
(function() {
  var DefaultRole, MafiaRole, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  DefaultRole = require('./default').DefaultRole;

  MafiaRole = (function(_super) {
    __extends(MafiaRole, _super);

    function MafiaRole() {
      _ref = MafiaRole.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    MafiaRole.prototype.roleID = 'mafia';

    MafiaRole.prototype.allegiance = 'mafia';

    MafiaRole.prototype.publicStateInitialize = function(playerObject, gameEngine, config) {
      var newstate;
      newstate = MafiaRole.__super__.publicStateInitialize.call(this, playerObject, gameEngine, config);
      newstate.chats.mafia = true;
      newstate.legalActions = ['action'];
      return newstate;
    };

    MafiaRole.prototype.active = {
      immediate: false,
      priority: 3,
      func: function(args, currentState, gameEngine) {
        var gameState, target, targetargs, targetname, visitObject;
        gameState = gameEngine.getGameState();
        targetname = args.targetname;
        target = gameState.players[targetname];
        visitObject = {
          who: currentState.name
        };
        gameEngine.getPlayerObject(currentState.name).addToVisited(args.targetname);
        target.on('visit', visitObject);
        targetargs = {
          who: currentState.name,
          how: 'mafia_kill'
        };
        return target.on('death', targetargs);
      }
    };

    MafiaRole.prototype.validateActive = function(args, currentState, gameEngine) {
      var valid;
      valid = true;
      if (currentState.blocked) {
        valid = false;
      }
      if (currentState.dead) {
        valid = false;
      }
      if (gameEngine.getPlayerObject(args.targetname).currentState.dead) {
        valid = false;
      }
      return valid;
    };

    return MafiaRole;

  })(DefaultRole);

  exports.mafia = new MafiaRole();

}).call(this);

/*
//@ sourceMappingURL=mafia.map
*/

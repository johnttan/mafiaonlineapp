// Generated by CoffeeScript 1.6.3
(function() {
  var Config, roles;

  roles = require('./roles');

  Config = (function() {
    function Config(availableRoles, random) {
      this.roles = roles;
      this.availableRoles = availableRoles;
      this.maxTurns = 12;
    }

    Config.prototype.defaultGameState = function(gameState) {
      gameState.turn = 1;
      gameState.players = {};
      return gameState.grave = {};
    };

    Config.prototype.generateRandomRoles = function(number) {};

    return Config;

  })();

  exports.Config = Config;

}).call(this);

/*
//@ sourceMappingURL=config.map
*/

(function() {
  var expect, routes;

  expect = require("chai").expect;

  routes = require('../routes');

  describe('Testing mariadb', function() {
    return it('connection', function() {
      return expect(2).to.equal(2);
    });
  });

  describe('Testing getSetsList()', function() {
    return it('is correct', function() {
      return routes.getSetsList().then(function(blocks) {
        return expect(blocks['Ravnica Cycle'].expsName[2]).to.equal('Ravnica: City of Guilds');
      });
    });
  });

}).call(this);

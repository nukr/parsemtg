expect = require("chai").expect
routes = require('../routes')

describe 'Testing mariadb', ->
  it 'connection', ->
    expect(2).to.equal(2)

describe 'Testing getSetsList()', ->
  it 'is correct', ->
    routes.getSetsList().then (blocks) ->
      expect(blocks['Ravnica Cycle'].expsName[2]).to.equal('Ravnica: City of Guilds')

(function() {
  var Client, Q, cheerio, first, getCardsDetail, getCardsList, getSetsList, inspect, jsdom, mariaDb, readReturnValue, request, updateSets;

  inspect = require('util').inspect;

  request = require("request");

  cheerio = require("cheerio");

  jsdom = require("jsdom");

  Client = require("mariasql");

  Q = require("q");

  first = function() {
    var deferred;
    deferred = Q.defer();
    console.log("inside first function");
    deferred.resolve("resolved");
    return deferred.promise;
  };

  exports.mariaDb = mariaDb = function() {
    var c;
    c = new Client();
    c.connect({
      host: '127.0.0.1',
      user: 'root',
      password: 'damnit',
      db: 'mtg_database'
    });
    c.on('connect', function() {
      return console.log("Mariasql connected");
    }).on('error', function(err) {
      return console.log("Client error " + err);
    }).on('close', function(hadError) {
      return console.log("Client closed");
    });
    return c.query("SHOW DATABASES").on("result", function(res) {
      return res.on("row", function(row) {
        return console.log(inspect(row));
      });
    });
  };

  exports.getSetsList = getSetsList = function() {
    var deferred, mtgAllBlks, url;
    deferred = Q.defer();
    url = "http://magiccards.info/sitemap.html";
    mtgAllBlks = {};
    request(url, function(err, resp, body) {
      var $, abbr, blk, blockName, blocks, mtgBlk, name, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;
      $ = cheerio.load(body);
      blocks = $('table').eq(1).find('td>ul>li');
      for (_i = 0, _len = blocks.length; _i < _len; _i++) {
        blk = blocks[_i];
        mtgBlk = {};
        blockName = $(blk).html().replace(/<.*>/g, "");
        mtgBlk.expNum = $(blk).find('a').length;
        mtgBlk.expsName = [];
        mtgBlk.expsAbbr = [];
        _ref = $(blk).find('a');
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          name = _ref[_j];
          mtgBlk.expsName.push($(name).html());
        }
        _ref1 = $(blk).find('small');
        for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
          abbr = _ref1[_k];
          mtgBlk.expsAbbr.push($(abbr).html());
        }
        mtgAllBlks[blockName] = mtgBlk;
      }
      return deferred.resolve(mtgAllBlks);
    });
    return deferred.promise;
  };

  exports.updateSets = updateSets = function(blocks) {
    var deferred;
    deferred = Q.defer();
    return deferred.promise;
  };

  getCardsList = function(set) {
    var deferred, url;
    deferred = Q.defer();
    url = "http://magiccards.info/" + set + "/en.html";
    request(url, function(err, resp, body) {
      var $, anchors, link, links, _i, _len;
      $ = cheerio.load(body);
      anchors = $('table').eq(3).find('a');
      links = [];
      for (_i = 0, _len = anchors.length; _i < _len; _i++) {
        link = anchors[_i];
        links.push($(link).attr('href'));
      }
      return deferred.resolve(links);
    });
    return deferred.promise;
  };

  getCardsDetail = function(links, callback) {
    var link, prices, url, _i, _len, _ref, _results;
    prices = [];
    _ref = links.value;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      link = _ref[_i];
      url = "http://magiccards.info" + link;
      jsdom.env({
        url: url,
        scripts: ["http://code.jquery.com/jquery.js"],
        features: {
          FetchExternalResources: ["script"],
          ProcessExternalResources: true
        },
        done: function(errors, window) {
          var $, price;
          $ = window.$;
          price = $('table').eq(3).find('.TCGPHiLoMid a');
          if (price != null) {
            return prices.push($(price).html().substr(1));
          } else {
            return prices.push("N/A");
          }
        }
      });
      if (link === links.value[links.value.length]) {
        _results.push(callback(prices));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  readReturnValue = function(blocks, links) {
    return getPrices(links, function(prices) {
      return console.log(prices);
    });
  };

  exports.index = function(req, res) {
    return getSetsList().then(function(blocks) {
      return res.json(blocks);
    });
  };

}).call(this);

inspect = require('util').inspect
request = require "request"
cheerio = require "cheerio"
jsdom = require "jsdom"
Client = require "mariasql"
Q = require "q"

first = ->
    deferred = Q.defer()
    console.log ("inside first function")
    deferred.resolve("resolved")
    deferred.promise

exports.mariaDb = mariaDb = ->
    c = new Client()
    c.connect
        host: '127.0.0.1'
        user: 'root'
        password: 'damnit'
        db: 'mtg_database'
    c.on 'connect', ->
        console.log "Mariasql connected"
    .on 'error', (err) ->
        console.log "Client error #{err}"
    .on 'close', (hadError) ->
        console.log "Client closed"

    c.query("SHOW DATABASES")
    .on "result", (res) ->
        res.on "row", (row) ->
            console.log inspect row

exports.getSetsList = getSetsList = ->
    deferred = Q.defer()
    url = "http://magiccards.info/sitemap.html"
    mtgAllBlks = {}

    request url, (err, resp, body) ->
        $ = cheerio.load(body)
        blocks = $('table').eq(1).find('td>ul>li')

        for blk in blocks
            mtgBlk = {}
            blockName = $(blk).html().replace(/<.*>/g, "")
            mtgBlk.expNum = $(blk).find('a').length

            mtgBlk.expsName = []
            mtgBlk.expsAbbr = []
            mtgBlk.expsName.push $(name).html() for name in $(blk).find('a')
            mtgBlk.expsAbbr.push $(abbr).html() for abbr in $(blk).find('small')

            mtgAllBlks[blockName] = mtgBlk


        deferred.resolve(mtgAllBlks)
    deferred.promise

exports.updateSets = updateSets = (blocks) ->
    deferred = Q.defer()
    deferred.promise

getCardsList = (set) ->
    deferred = Q.defer()
    url = "http://magiccards.info/#{set}/en.html"
    request url, (err, resp, body) ->
        $ = cheerio.load body
        anchors = $('table').eq(3).find('a')
        links = []
        links.push $(link).attr('href') for link in anchors
        deferred.resolve(links)
    deferred.promise

getCardsDetail = (links, callback) ->
    prices = []
    for link in links.value
        url = "http://magiccards.info#{link}"
        jsdom.env
            url: url
            scripts: ["http://code.jquery.com/jquery.js"]
            features:
                FetchExternalResources: ["script"]
                ProcessExternalResources: true
            done: (errors, window) ->
                $ = window.$
                price = $('table').eq(3).find('.TCGPHiLoMid a')
                if price? then prices.push $(price).html().substr(1) else prices.push "N/A"
        if link is links.value[links.value.length]
            callback(prices)

readReturnValue = (blocks, links) ->
    getPrices links, (prices) ->
        console.log prices

exports.index = (req, res) ->

    getSetsList().then (blocks) ->

        res.json blocks

    # q.allSettled([updateSets(), requestCheckList("ths")])
    # .spread(readReturnValue)
    # .then ->
    #   console.log "fulfilled"
    # , ->
    #   console.log "rejected"
    # .done ->
    #   res.render("index", {title: "Express"})
    #   console.log "done"

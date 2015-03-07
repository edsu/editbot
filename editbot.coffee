#!/usr/bin/env coffee

Twit          = require 'twit'
cheerio       = require 'cheerio'
request       = require 'request'
minimist      = require 'minimist'
wikichanges   = require 'wikichanges'

class EditBot

  constructor: (@config) ->
    @pages = {}

  run: ->
    this._update @config.refresh
    wikipedia = new wikichanges.WikiChanges
      ircNickname: @config.nick
      wikipedias: ["#en.wikipedia"]
    wikipedia.listen (edit) =>
      this.inspect(edit)

  inspect: (edit) ->
    console.log "inspecting " + edit.page
    # is it a page we are watching?
    if not @pages[edit.page]
      return
    # is it a bot?
    else if edit.robot
      return
    # ok lets announce it!
    else
      status = this._getStatus edit
      console.log status
      twitter = new Twit @config
      twitter.post 'statuses/update', status: status, (err) ->
        console.log err if err

  _getStatus: (edit) ->
    title = edit.page
    user = if edit.anonymous then "Anonymous" else edit.user
    status = "#{title} Wikipedia article edited by #{user} "
    # shorten the title if status is going to be too big
    statusLength = status.length + 22 # after t.co url added
    if statusLength > 140
      titleLength = title.length - (statusLength - 140)
      title = title[0..titleLength]
    status = "#{title} Wikipedia article edited by #{user} " + edit.url
    
  _update: (refresh) ->
    newPages = []
    this._getPages (pages) =>
      @pages = pages
      console.log "monitoring #{ Object.keys(@pages).length } pages"

      # if refresh is a callback call it
      if refresh instanceof Function
        refresh()
      # otherwise it's the number of seconds to sleep till next update
      else
        doUpdate = =>
          this._update(refresh)
        setTimeout doUpdate, refresh * 1000

  _getPages: (callback) ->
    pages = {}
    this._getDom @config.page, ($) ->
      for a in $('a[href]')
        if $(a).attr('href').match(/^\/wiki\/(.+)$/)
          pages[$(a).attr 'title'] = true
      callback pages

  _getDom: (url, callback) ->
    request url, (err, response, body) =>
      if err
        console.log err
        return
      callback cheerio.load body

loadJson = (path) ->
  if path[0] != '/' and path[0..1] != './'
    path = './' + path
  require path

argv = minimist process.argv.slice(2), default:
  config: './config.json'
  list: false

main = ->
  config = loadJson argv.config
  c = new EditBot config
  # if list was selected just write out what pages we would monitor
  if argv.list
    c._update ->
      for page in c.pages
        console.log page
  # otherwise run!
  else
    c.run()
  
if require.main == module
  main()

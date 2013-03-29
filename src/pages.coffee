{compile} = require 'coffeecup'

helpers =
  layout: (partial) ->
    doctype 5
    html ->
      head ->
        script src: '/socket.io/socket.io.js'
        script src: '//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js'

        script src: '/jquery.rdio.js'

      body ->
        partial()

pages =
  home: ->
    layout =>
      h1 @title
      div '#gaga', -> ''

      coffeescript ->
        $ ->
          socket = io.connect()
          socket.on 'gaga', (data) -> console.log data

  error: ->
    layout =>
      p @message

  redirect: ->
    layout =>
      h3 @message

      input {type: 'hidden', id: 'redirect', value: @redirect}
      coffeescript ->
        redirect = ->
          url = $('#redirect').val()
          window.location.href = url

        setTimeout redirect, 3000

  player: ->
    layout =>
      div '#rdio', -> @playbackToken

      input {type: 'hidden', id: 'playbackToken', value: @playbackToken}
      coffeescript ->
        playbackToken = $('#playbackToken').val()
        $('#rdio').rdio playbackToken

        $('#rdio').on 'rdio.ready', (e, user) -> console.log user

# Precompile pages and export.
module.exports[name] = compile page, hardcode: helpers for name, page of pages

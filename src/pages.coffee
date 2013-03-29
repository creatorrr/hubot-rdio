{compile} = require 'coffeecup'

pages =
  home: ->
    doctype 5
    html ->
      body ->
        h1 @title
        div '#gaga', -> ''

        script src: '/socket.io/socket.io.js'
        script src: '/jquery.js'
        script src: '/jquery.rdio.js'
        coffeescript ->
          $ ->
            socket = io.connect()
            socket.on 'gaga', (data) -> console.log data

  error: ->
    body ->
      p @message

  redirect: ->
    h3 @message

    input {type: 'hidden', id: 'redirect', value: @redirect}
    coffeescript ->
      redirect = ->
        url = (document.getElementById 'redirect').value
        window.location.href = url

      setTimeout redirect, 3000

  player: ->
    div -> @playbackToken

# Precompile pages and export.
module.exports[name] = compile page for name, page of pages

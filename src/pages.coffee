{compile} = require 'coffeecup'

helpers =
  layout: (partial) ->
    doctype 5
    html ->
      head ->
        script src: '/socket.io/socket.io.js'
        script src: '//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js'
        script src: '//ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js'

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
      h1 'Rdio Playback API simple example'
      div '#apiswf', -> ''

      input '#play_key', value: 'a997982'
      button '#play', -> 'Play'
      button '#stop', -> 'stop'
      button '#pause', -> 'pause'
      button '#previous', -> 'previous'
      button '#next', -> 'next'


      input type: 'hidden', id: 'playback_token', value: @playbackToken
      coffeescript ->
        window.playback_token = $('#playback_token').val()
        window.domain = window.location.hostname

      script src: 'https://raw.github.com/rdio/hello-web-playback/master/hello.js'

      coffeescript ->
        socket = io.connect()
        socket.on 'pause', -> $('#pause').click()
        socket.on 'play', (track) ->
          console.log track
          $('#play_key').val track.key
          $('#play').click()

# Precompile pages and export.
module.exports[name] = compile page, hardcode: helpers for name, page of pages

{compile} = require 'coffeecup'

module.exports = pages =
  home: compile ->
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

  error: compile ->
    body ->
      p @message

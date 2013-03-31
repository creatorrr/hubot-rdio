# External libraries
{inspect} = require 'util'
Rdio = require 'node-rdio'

# Load globals
{RDIO_CONSUMER, RDIO_SECRET, DOMAIN, CALLBACK} = require './globals'

# Helpers
# Returns true if obj is a string.
isString = (obj) ->
  Object::toString.call(obj) is '[object String]'

# Returns a random integer between min and max.
random = (min, max) -> min + Math.floor Math.random()*(max - min + 1)

# Get random element from arr.
getRandom = (arr) -> arr[random 0, arr.length-1]

# Return capitalized string.
capitalize = (str) -> (str.charAt 0).toUpperCase() + str[1..]

# Capture robot instance in a closure and return interface.
module.exports = listeners = (robot) ->
  getRdio = ->
    accessToken = robot.brain.get 'RdioAccessToken'
    accessSecret = robot.brain.get "RdioAccessSecret-#{accessToken}"

    if not accessToken and accessSecret
      return msg.send 'Please login to your rdio account first.'

    rdio = new Rdio [
      RDIO_CONSUMER
      RDIO_SECRET
    ], [
      accessToken
      accessSecret
    ]

    rdio

  return {
    init: (msg) ->
      rdio = new Rdio [
        RDIO_CONSUMER
        RDIO_SECRET
      ]

      rdio.beginAuthentication DOMAIN+CALLBACK, (error, authUrl) ->
        if error
          robot.logger.debug error
          return msg.send "Error: #{ error }"

        requestToken  = rdio.token[0]
        requestSecret = rdio.token[1]

        robot.brain
          .set('RdioRequestToken', requestToken)
          .set("RdioRequestSecret-#{requestToken}", requestSecret)
          .save()

        msg.send "Go to #{ authUrl } to verify your rdio account."

    test: (msg) ->
      rdio = getRdio()
      rdio.call 'currentUser', (error, {result}) ->
        if error
          robot.logger.debug "Error: #{ error }"
          return msg.send "Error: #{ error }"

        msg.send "Success: #{ inspect result }"

    pause: (msg) ->
      robot.emit 'player:send', 'pause'
      msg.send 'Song paused.'

    playWhatever: (msg) ->
      rdio = getRdio()
      rdio.call 'getTopCharts', {type: 'Track'}, (error, {result}) ->
        if error
          robot.logger.debug "Error: #{ error }"
          return msg.send "Error: #{ error }"

        track = getRandom result
        robot.emit 'player:send', 'play', track

        msg.send "Playing track #{ track.name }"

    play: (msg) ->
      mode = capitalize msg.match[1].toLowerCase()
      query = msg.match[2]

      rdio = getRdio()
      rdio.call 'search', { types: mode, query: query }, (error, {result}) ->
        if error
          robot.logger.debug "Error: #{ error }"
          return msg.send "Error: #{ error }"

        track = result.results[0]
        robot.emit 'player:send', 'play', track

        msg.send "Playing track #{ track.name }"
  }

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

# Check if arr empty.
isEmpty = (arr) -> arr.length is 0

# Return capitalized string.
capitalize = (str) -> (str.charAt 0).toUpperCase() + str[1..]

# Capture robot instance in a closure and return interface.
module.exports = listeners = (robot) ->
  # Get rdio client (signed if access token available).
  getRdio = ->
    accessToken = robot.brain.get 'RdioAccessToken'
    accessSecret = robot.brain.get "RdioAccessSecret-#{accessToken}"

    if accessToken and accessSecret
      rdio = new Rdio [
        RDIO_CONSUMER
        RDIO_SECRET
      ], [
        accessToken
        accessSecret
      ]

    else
      rdio = new Rdio [
        RDIO_CONSUMER
        RDIO_SECRET
      ]

  # Return listeners interface.
  return {
    init: (msg) ->
      rdio = getRdio()

      rdio.beginAuthentication DOMAIN+CALLBACK, (error, authUrl) ->
        if error
          robot.logger.debug error
          return msg.send "Error: #{ error }"

        # Get request token and save it.
        requestToken  = rdio.token[0]
        requestSecret = rdio.token[1]

        robot.brain
          .set('RdioRequestToken', requestToken)
          .set("RdioRequestSecret-#{requestToken}", requestSecret)
          .save()

        # Redirect user to rdio auth url.
        msg.send "Go to #{ authUrl } to verify your rdio account."

    pause: (msg) ->
      robot.emit 'player:send', 'pause'
      msg.send 'Song paused.'

    playRandom: (msg) ->
      rdio = getRdio()

      # Get top charts on rdio.
      rdio.call 'getTopCharts', {type: 'Track'}, (error, {result}) ->
        if error
          robot.logger.debug "Error: #{ error }"
          return msg.send "Error: #{ error }"

        # Pick random track from results and send it off to player.
        track = getRandom result
        robot.emit 'player:send', 'play', track

        msg.send "Playing track #{ track.name }"

    play: (msg) ->
      # Parse `hubot play <mode> <query>`
      mode = msg.match[1].toLowerCase()
      query = msg.match[2]

      rdio = getRdio()

      # Callback for playing tracks.
      playTrack = (result) ->
        track = switch mode
          when 'track', 'album' then result

          # If mode is 'artist' then get artist station.
          when 'artist'
            key:  result.topSongsKey
            name: result.name

        msg.send "Playing #{ mode } - #{ track.name }"
        robot.emit 'player:send', 'play', track

      # Search query.
      rdio.call 'search', { types: (capitalize mode), query: query }, (error, {result}) ->
        if error
          robot.logger.debug "Error: #{ error }"
          return msg.send "Error: #{ error }"

        if isEmpty result.results
          msg.send "No results found for '#{ query }'"

        else playTrack result.results[0]
  }

# External libraries
Rdio = require 'node-rdio'

# Load globals
{RDIO_CONSUMER, RDIO_SECRET, DOMAIN, CALLBACK} = require './globals'

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
      rdio.call 'currentUser', (error, data) ->
        if error
          robot.logger.warn "Error: #{ error }"
          return msg.send "Error: #{ error }"

        msg.send "Success: #{ (require 'utils').inspect data }"

    pause: ->
      robot.emit 'player:send', 'pause'

    playWhatever: (msg) ->
      rdio = getRdio()
      rdio.call 'getTopCharts', {type: 'Track'}, (error, data) ->
        if error
          robot.logger.warn "Error: #{ error }"
          return msg.send "Error: #{ error }"

        try
          track = (JSON.parse data)[0]
        catch e
          track = key: 'a997982'
        finally
          robot.emit 'player:send', 'play', track
  }

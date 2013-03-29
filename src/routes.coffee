# External libraries
Rdio = require 'node-rdio'

# Modules
pages = require './pages'

# Load globals
{RDIO_CONSUMER, RDIO_SECRET, DOMAIN} = require './globals'

module.exports = routes = (robot) ->
  home: (req, res) ->
    res.writeHead 200,
      'Content-Type': 'text/html'

    res.end pages.home
      title: 'Pataku?'

  auth: (req, res) ->
    res.writeHead 200,
      'Content-Type': 'text/html'

    requestToken  = req.query['oauth_token']
    requestSecret = robot.brain.get "RdioRequestSecret-#{requestToken}"

    verifier = req.query['oauth_verifier']

    unless requestToken and requestSecret and verifier
      return res.end pages.error
        message: 'Error: Invalid request token'

    rdio = new Rdio [
      RDIO_CONSUMER
      RDIO_SECRET
    ], [
      requestToken
      requestSecret
    ]

    rdio.completeAuthentication verifier, (error) ->
      if error
        robot.logger.debug error
        return msg.send "Error: #{ error }"

      oldAccessToken = robot.brain.get 'RdioAccessToken'

      accessToken  = rdio.token[0]
      accessSecret = rdio.token[1]

      robot.brain
        .remove('RdioRequestToken')
        .remove("RdioRequestSecret-#{requestToken}")

        .remove('RdioAccessToken')
        .remove("RdioAccessSecret-#{oldAccessToken}")

        .set('RdioAccessToken', accessToken)
        .set("RdioAccessSecret-#{accessToken}", accessSecret)
        .save()

      res.end pages.redirect
        message: "Yay! Your access token is #{ accessToken }"
        redirect: '/'

  player: (req, res) ->
    res.writeHead 200,
      'Content-Type': 'text/html'

    accessToken  = robot.brain.get 'RdioAccessToken'
    accessSecret = robot.brain.get "RdioAccessSecret-#{accessToken}"

    unless accessToken and accessSecret
      return res.end pages.redirect
        message: 'Please authorize rdio first.'
        redirect: '/'

    rdio = new Rdio [
      RDIO_CONSUMER
      RDIO_SECRET
    ], [
      accessToken
      accessSecret
    ]

    rdio.call 'currentUser', (error) ->
      if error
        res.end pages.redirect
          message: 'Please authorize rdio first.'
          redirect: '/'

      else
        rdio.call 'getPlaybackToken', {domain: DOMAIN}, (error, data) ->
          if error
            res.end pages.error
              message: "Error: #{ error }"

          else
            res.end pages.player
              playbackToken: data

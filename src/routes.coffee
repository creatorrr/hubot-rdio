# External libraries
{parse} = require 'url'
Rdio = require 'node-rdio'

# Modules
pages = require './pages'

# Load globals
{RDIO_CONSUMER, RDIO_SECRET, DOMAIN, CALLBACK} = require './globals'

module.exports = routes = (robot) ->
  home: (req, res) ->
    res.writeHead 200,
      'Content-Type': 'text/html'

    res.end pages.home
      title: 'Pataku?'

  login: (req, res) ->
    rdio = new Rdio [
      RDIO_CONSUMER
      RDIO_SECRET
    ]

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
      res.redirect authUrl

  auth: (req, res) ->
    res.writeHead 200,
      'Content-Type': 'text/html'

    # Retrieve params required for obtaining access token.
    requestToken  = req.query['oauth_token']
    requestSecret = robot.brain.get "RdioRequestSecret-#{requestToken}"

    verifier = req.query['oauth_verifier']

    unless requestToken and requestSecret and verifier
      return res.end pages.error
        message: 'Error: Invalid request token'

    # Init rdio with the request token.
    rdio = new Rdio [
      RDIO_CONSUMER
      RDIO_SECRET
    ], [
      requestToken
      requestSecret
    ]

    # Exchange request token for access token.
    rdio.completeAuthentication verifier, (error) ->
      if error
        robot.logger.debug error
        return msg.send "Error: #{ error }"

      oldAccessToken = robot.brain.get 'RdioAccessToken'

      accessToken  = rdio.token[0]
      accessSecret = rdio.token[1]

      # Remove obsolete keys and persist the access token.
      robot.brain
        .remove('RdioRequestToken')
        .remove("RdioRequestSecret-#{requestToken}")

        .remove('RdioAccessToken')
        .remove("RdioAccessSecret-#{oldAccessToken}")

        .set('RdioAccessToken', accessToken)
        .set("RdioAccessSecret-#{accessToken}", accessSecret)
        .save()

      # Send user to the player.
      res.end pages.redirect
        message: "Yay! Your access token is #{ accessToken }"
        redirect: '/player'

  player: (req, res) ->
    res.writeHead 200,
      'Content-Type': 'text/html'

    accessToken  = robot.brain.get 'RdioAccessToken'
    accessSecret = robot.brain.get "RdioAccessSecret-#{accessToken}"

    # Ask user to authorize app if access token not available.
    unless accessToken and accessSecret
      return res.end pages.redirect
        message: 'Please authorize rdio first.'
        redirect: '/login'

    # Init rdio with the access token.
    rdio = new Rdio [
      RDIO_CONSUMER
      RDIO_SECRET
    ], [
      accessToken
      accessSecret
    ]

    # Make sure user session still valid.
    rdio.call 'currentUser', (error) ->
      if error
        res.end pages.redirect
          message: 'Please authorize rdio first.'
          redirect: '/login'

      else
        {hostname} = parse DOMAIN

        # Request playback token from rdio.
        rdio.call 'getPlaybackToken', { domain: hostname }, (error, data) ->
          res.end page =
            if error
              pages.error message: "Error: #{ error }"

            else
              # Embed playback token for the playback api.
              pages.player playbackToken: data.result

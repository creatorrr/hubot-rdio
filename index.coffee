# hubot
#
# search rdio for song

# External libraries
Rdio    = require 'node-rdio'
sockets = require 'hubot.io'

# Modules
pages = require './pages'

module.exports = (robot) ->
  # Initialize socket.io
  io = sockets robot

  # Get config.
  {RDIO_CONSUMER, RDIO_SECRET, HEROKU_URL} = process.env
  throw new Error 'Invalid rdio credentials' unless RDIO_CONSUMER and RDIO_SECRET

  CALLBACK = 'auth'

  # Initialize this thing.
  robot.respond /init rdio/i, (msg) ->
    rdio = new Rdio [
      RDIO_CONSUMER
      RDIO_SECRET
    ]

    rdio.beginAuthentication HEROKU_URL+CALLBACK, (error, authUrl) ->
      if error
        robot.logger.debug error
        return msg.send "Error: #{ error }"

      requestToken  = rdio.token[0]
      requestSecret = rdio.token[1]

      robot.brain.set('RdioRequestToken', requestToken)
        .set("RdioRequestSecret-#{requestToken}", requestSecret)
        .save()

      msg.send "Go to #{ authUrl } to verify your rdio account."

  robot.router.get "/#{ CALLBACK }", (req, res) ->
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

      accessToken  = rdio.token[0]
      accessSecret = rdio.token[1]

      robot.brain
        .remove('RdioAccessToken')
        .remove("RdioRequestSecret-#{requestToken}")

        .set('RdioAccessToken', accessToken)
        .set("RdioAccessSecret-#{accessToken}", accessSecret)
        .save()

        res.end pages.home
          title: "Yay! Your access token is #{ accessToken }"

  robot.router.get '/', (req, res) ->
    res.writeHead 200,
      'Content-Type': 'text/html'

    res.end pages.home
      title: 'Pataku?'

  robot.respond /test rdio/i, (msg) ->
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

    rdio.call 'currentUser', (error, data) ->
      if error
        robot.logger.warn "Error: #{ error }"
        return msg.send "Error: #{ error }"

      msg.send "Success: #{ data }"


  #   client.post "#{ RDIO_API_ENDPOINT }",
  #     accessToken,
  #     accessSecret,
  #     'method=getOfflineTracks',
  #     'application/x-www-form-urlencoded',
  #     (error, data) -> msg.send error, data

# rdio init
#   get accesstoken and store init

# rdio play me x
#   get song id
#   send it to client

# /
#   serve page with playback_token
#   listen to socket.io
#     - on 'connect'
#       * on 'play', data -> play
#       * on 'pause' -> pause

# /auth
#   get verifier and exchange for access playback_token
#   store it.

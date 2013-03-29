# hubot
#
# search rdio for song

# External libraries
sockets = require 'hubot.io'

# Load globals
{CALLBACK} = require './globals'

module.exports = (robot) ->
  # Initialize socket.io
  robot.io = sockets robot

  # Load modules
  pages     = require './pages'
  routes    = (require './routes') robot
  listeners = (require './listeners') robot

  # Initialize this thing.
  robot.respond /init rdio/i, listeners.init
  robot.respond /test rdio/i, listeners.test

  robot.router.get '/', routes.home
  robot.router.get "/#{ CALLBACK }", routes.auth

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

# hubot
#
# search rdio for song

# External libraries
sockets = require 'hubot.io'

# Load globals
{CALLBACK} = require './globals'

module.exports = (robot) ->
  # Initialize socket.io
  io = sockets robot

  # Load modules
  routes           = (require './routes') robot
  listeners        = (require './listeners') robot
  socketController = (require './socket-controller') robot

  # Initialize this thing.
  robot.respond /init rdio/i, listeners.init
  # robot.respond /test rdio/i, listeners.test

  robot.respond /play (track|artist|album) (["'\w: \-_]+).*$/i, listeners.play
  robot.respond /play whatever/i, listeners.playWhatever
  robot.respond /pause( music){0,1}/i, listeners.pause

  robot.router.get '/', routes.home
  robot.router.get '/login', routes.login
  robot.router.get "/#{ CALLBACK }", routes.auth
  robot.router.get '/player', routes.player

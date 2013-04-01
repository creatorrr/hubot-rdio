# Description:
#   Rdio remote control for hubot.
#
# Dependencies:
#   "hubot.io":  ">= 0.1.3"
#   "node-rdio": ">= 0.1.1"
#   "coffeecup": "0.3.x"
#
# Configuration:
#   NODE_ENV:      'production'
#   RDIO_CONSUMER: '<your rdio consumer key>'
#   RDIO_SECRET:   '<your rdio consumer secret>'
#
# Commands:
#   hubot init rdio - Authenticate rdio.
#   hubot play (track|artist|album) <name> - Search and play songs.
#   hubot play random - Pick a random song off top charts and play it.
#   hubot pause - Pause currently playing song.
#
# Author:
#   creatorrr

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

  # Listeners
  robot.respond /init rdio/i, listeners.init

  robot.respond /play (track|artist|album) (["'\w: \-_]+).*$/i, listeners.play
  robot.respond /play random/i, listeners.playRandom
  robot.respond /pause( music){0,1}/i, listeners.pause

  # Routes
  robot.router.get '/', routes.home
  robot.router.get '/login', routes.login
  robot.router.get "/#{ CALLBACK }", routes.auth
  robot.router.get '/player', routes.player

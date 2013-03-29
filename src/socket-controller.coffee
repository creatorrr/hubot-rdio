module.exports = (robot) ->
  new ->
    @sockets = []
    robot.on 'sockets:connection', (socket) ->
      socket.on 'event', (args...) ->
        robot.emit 'player:receive', args...

      @sockets.push socket

    robot.on 'player:send', (args...) ->
      socket.emit args... for socket in @sockets

    # Return instance
    this

# Helpers
extend = (dest, sources...) ->
  for src in sources
    dest[key] = value for own key, value of src

  dest

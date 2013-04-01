# Helpers
# Extend dest object with sources.
extend = (dest, sources...) ->
  for src in sources
    dest[key] = value for own key, value of src

  dest

module.exports = (robot) ->
  # Return singleton interface.
  new ->
    # Internal store for socket connections.
    @sockets = []

    # Event emitter API for interfacing with other scripts.
    robot.on 'sockets:connection', (socket) =>
      socket.on 'event', (args...) ->
        robot.emit 'player:receive', args...

      @sockets.push socket

    robot.on 'player:send', (args...) =>
      socket.emit args... for socket in @sockets

    this

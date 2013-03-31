# Helpers
pick = (obj, keys...) ->
  copy = {}
  copy[key] = obj[key] for key in keys

  copy

extend = (dest, sources...) ->
  for src in sources
    dest[key] = value for own key, value of src

  dest

# Get config
rdio = pick process.env, 'RDIO_CONSUMER', 'RDIO_SECRET', 'HEROKU_URL'
misc =
  DOMAIN: process.env.DOMAIN or process.env.HEROKU_URL
  CALLBACK: 'auth'

# Export globals
module.exports = globals = extend {}, rdio, misc

# Check for valid Rdio credentials.
unless globals.RDIO_CONSUMER and globals.RDIO_SECRET
  throw new Error 'Invalid rdio credentials'

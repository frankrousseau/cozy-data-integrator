http = require 'http'
express = require 'express'
init = require './init'
router = require './server/router'
configure = require './server/config'
{realtimeInitializer} = require './server/initializers/realtime'
deduplicate = require './server/patchs/deduplicate'
unencrypt = require './server/patchs/unencrypt'
useTracker = require './server/lib/use-tracker'

module.exports = app = express()
configure app
router app

if not module.parent
    init (err) -> # ./init.coffee
        if err?
            console.log "Initialization failed, not starting"
            console.log err.stack
            return

        port = process.env.PORT or 9260
        host = process.env.HOST or "127.0.0.1"
        server = http.createServer(app).listen port, host, ->
            console.log "Server listening on %s:%d within %s environment",
                host, port, app.get 'env'
            realtimeInitializer app, server
            deduplicate.apply()
            unencrypt.apply()
            useTracker.poll()

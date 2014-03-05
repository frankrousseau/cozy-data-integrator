moment = require 'moment'
async = require 'async'
Client = require('request-json').JsonClient

MesInfosIntegrator = require '../models/mesinfosintegrator'
UseTracker = require '../models/usetracker'
retriever = require './retriever'

LIMIT = 250

sendTracks = (tracks, callback) -> retriever.sendTracks tracks, callback

markAsSent = (track, callback) ->
    track.updateAttributes sent: true, (err) -> callback err

endOfTransmission = ->
    console.log "End use tracker transmission."
    module.exports.poll()

transmit = ->

    console.log "Start use tracker transmission..."
    MesInfosIntegrator.getConfig (err, integrator) ->
        retriever.init integrator.password

        UseTracker.getSome LIMIT, (err, tracks) ->
            console.log err if err?

            if tracks.length > 0
                console.log "got tracks to transmit", tracks.length

                sendTracks tracks, (err) ->
                    if err?
                        endOfTransmission()
                    else
                        async.each tracks, markAsSent, (err) ->
                            console.log "tracks mark as sent"
                            endOfTransmission()
            else
                endOfTransmission()

module.exports.poll = ->

    delta =  Math.floor(Math.random() * 2 * 60)
    now = moment()
    patchTime = now.clone().add(6, 'hours')
                        .minutes(delta)
                        .seconds(0)
    patchTime = now.clone().add(5, 'seconds') # dev mode
    setTimeout(
        -> transmit()
    , patchTime.diff(now))

    format = "DD/MM/YYYY [at] HH:mm:ss"
    console.log "> Next use tracker transmission at #{patchTime.format(format)}"











#! /usr/bin/env coffee

express  = require 'express'
optimist = require 'optimist'
path     = require 'path'

{argv} = optimist
  .default('v', 1)
  .alias('v', 'verbosity')

{exit} = process

fatal = (s) ->
  console.error s
  exit 1

unless 0 <= argv.v <= 3
  fatal "Invalid verbosity: #{argv.v} (should be between 0 and 3)"

class DoppioServer
  constructor: ->
    @port = 8000
    @set_options()

  set_options: (args) ->
    @options =
      verbosity: argv.verbosity
      logdir: './logs'

    @p3 "Input options: \n#{(key + ': ' + val for key, val of @options).join '\n'}"

  p1: (m) -> @pn 1, m
  p2: (m) -> @pn 2, m
  p3: (m) -> @pn 3, m
  pn: (n, m) -> console.log m if n <= @options.verbosity

  start: ->
    @p1 "Creating server."

    app = express()

    @p1 "Starting server"

    root = path.resolve __dirname, '..'
    app.use(express.static(root))
    app.listen(@port)

    @p1 "Serving #{root} at http://localhost:#{@port}"

doppio = new DoppioServer()
doppio.start()

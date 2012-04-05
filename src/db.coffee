http   = require 'http'
util   = require 'util'

Cursor = require './cursor'
RestClient = require './rest_client'
RpcClient = require './rpc_client'

class DB

  constructor: (@database) ->
    throw new Error("default database must be passed to new") unless @database

  _initOptions: (options) ->
    args = {}
    args.DB = options.database or @database
    args.xt = options.expires if options.expires?
    args

  open: (@host = 'localhost', @port = 1978) ->
    http.globalAgent.maxSockets = 1;

    @rpcClient = new RpcClient(@port, @host)
    @restClient = new RestClient(@port, @host)
    this

  close: (callback) ->
    # Make a dummy request with connection close specified
    request =
      host: @host
      path: '/rpc/echo'
      port: @port
      headers:
        'Connection': 'close'
    http.get request, (response) ->
      response.on 'end', ->
        callback()
    .on 'error', (error) ->
      callback error

  defaultDatabase: (database) ->
    @database = database if database
    @database

  echo: (input, callback) ->
    @rpcClient.call 'echo', input, (error, status, output) ->
      if error?
        callback error, output
      else if status != 200
        error = new Error("Unexpected response from server: #{status}")
        callback error, output
      else
        callback undefined, output

  report: (callback) ->
    @rpcClient.call 'report', {}, (error, status, output) ->
      if error?
        callback error, output
      else if status != 200
        error = new Error("Unexpected response from server: #{status}")
        callback error, output
      else
        callback undefined, output

  status: (args...) ->
    switch args.length
      when 1
        options  = {}
        callback = args[0]
      when 2
        options  = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to status");

    rpc_args = this._initOptions options
    @rpcClient.call 'status', rpc_args, (error, status, output) ->
      if error?
        callback error, output
      else if status != 200
        error = new Error("Unexpected response from server: #{status}")
        callback error, output
      else
        callback undefined, output

  # Remove all values
  clear: (args...) ->
    switch args.length
      when 1
        options  = {}
        callback = args[0]
      when 2
        options  = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to clear");

    rpc_args = {}
    rpc_args.DB = options.database or @database
    @rpcClient.call 'clear', rpc_args, (error, status, output) ->
      if error?
        callback error, output
      else if status != 200
        error = new Error("Unexpected response from server: #{status}")
        callback error, output
      else
        callback undefined, output

  # Note: value can be a string or Buffer for utf-8 strings it should be a Buffer
  set: (key, value, args...) ->
    switch args.length
      when 1
        options  = {}
        callback = args[0]
      when 2
        options  = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to set");

    params = this._initOptions options
    @restClient.put key, value, params, (error) ->
      callback error

  # Add a record if it doesn't already exist
  add: (key, value, args...) ->
    switch args.length
      when 1
        options  = {}
        callback = args[0]
      when 2
        options  = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to add");

    rpc_args       = this._initOptions options
    rpc_args.key   = key
    rpc_args.value = value
    @rpcClient.call 'add', rpc_args, (error, status, output) ->
      if error?
        callback error, output
      else if status == 200
        callback undefined, output
      else if status == 450
        callback (new Error("Record exists")), output
      else
        callback new Error("Unexpected response from server: #{status}"), output

  # Replace an existsing record
  replace: (key, value, args...) ->
    switch args.length
      when 1
        options  = {}
        callback = args[0]
      when 2
        options  = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to replace");

    rpc_args       = this._initOptions options
    rpc_args.key   = key
    rpc_args.value = value
    @rpcClient.call 'replace', rpc_args, (error, status, output) ->
      if error?
        callback error, output
      else if status == 200
        callback undefined, output
      else if status == 450
        callback (new Error("Record does not exist")), output
      else
        callback new Error("Unexpected response from server: #{status}"), output

  append: (key, value, args...) ->
    switch args.length
      when 1
        options = {}
        callback = args[0]
      when 2
        options  = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to append");

    rpc_args       = this._initOptions options
    rpc_args.key   = key
    rpc_args.value = value
    @rpcClient.call 'append', rpc_args, (error, status, output) ->
      if error?
        callback error, output
      else if status != 200
        error = new Error("Unexpected response from server: #{status}")
        callback error, output
      else
        callback undefined, output

  increment: (key, num, args...) ->
    switch args.length
      when 1
        options  = {}
        callback = args[0]
      when 2
        options = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to increment");

    rpc_args     = this._initOptions options
    rpc_args.key = key
    rpc_args.num = num
    @rpcClient.call 'increment', rpc_args, (error, status, output) ->
      if error?
        callback error, output
      else if status == 200
        callback undefined, output
      else if status == 450
        callback (new Error("The existing record was not compatible")), output
      else
        callback new Error("Unexpected response from server: #{status}"), output

  incrementDouble: (key, num, args...) ->
    switch args.length
      when 1
        options  = {}
        callback = args[0]
      when 2
        options  = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to incrementDouble");

    rpc_args     = this._initOptions options
    rpc_args.key = key
    rpc_args.num = num
    @rpcClient.call 'increment_double', rpc_args, (error, status, output) ->
      if error?
        callback error, output
      else if status == 200
        callback undefined, output
      else if status == 450
        callback (new Error("The existing record was not compatible")), output
      else
        callback new Error("Unexpected response from server: #{status}"), output

  cas: (key, oval, nval, args...) ->
    switch args.length
      when 1
        options  = {}
        callback = args[0]
      when 2
        options  = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to cas");

    rpc_args      = this._initOptions options
    rpc_args.key  = key
    rpc_args.oval = oval if oval?
    rpc_args.nval = nval if nval?
    @rpcClient.call 'cas', rpc_args, (error, status, output) ->
      if error?
        callback error, output
      else if status == 200
        callback undefined, output
      else if status == 450
        callback (new Error("Record has changed")), output
      else
        callback new Error("Unexpected response from server: #{status}"), output

  remove: (key, args...) ->
    switch args.length
      when 1
        options  = {}
        callback = args[0]
      when 2
        options  = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to remove");

    params = this._initOptions options
    @restClient.delete key, params, (error) ->
      callback error

  exists: (key, args...) ->
    switch args.length
      when 1
        options  = {}
        callback = args[0]
      when 2
        options  = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to exists");

    params = this._initOptions options
    @restClient.head key, params, (error, headers) ->
      callback error, headers?

  # key, [database], callback
  get: (key, args...) ->
    switch args.length
      when 1
        options  = {}
        callback = args[0]
      when 2
        options  = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to get");

    params = this._initOptions options
    @restClient.get key, params, (error, value, expires) ->
      callback error, value, expires

  setBulk: (records, args...) ->
    switch args.length
      when 1
        options  = {}
        callback = args[0]
      when 2
        options  = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to setBulk");

    rpc_args = this._initOptions options
    rpc_args["_#{key}"] = value for key, value of records

    @rpcClient.call 'set_bulk', rpc_args, (error, status, output) ->
      if error?
        callback error, output
      else if status == 200
        callback undefined, output
      else
        callback new Error("Unexpected response from server: #{status}"), output

  removeBulk: (keys, args...) ->
    switch args.length
      when 1
        options  = {}
        callback = args[0]
      when 2
        options  = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to removeBulk");

    rpc_args = this._initOptions options
    rpc_args["_#{key}"] = '' for key in keys

    @rpcClient.call 'remove_bulk', rpc_args, (error, status, output) ->
      if error?
        callback error, output
      else if status == 200
        callback undefined, output
      else
        callback new Error("Unexpected response from server: #{status}"), output

  getBulk: (keys, args...) ->
    switch args.length
      when 1
        options  = {}
        callback = args[0]
      when 2
        options  = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to getBulk");

    rpc_args = this._initOptions options
    rpc_args["_#{key}"] = '' for key in keys

    @rpcClient.call 'get_bulk', rpc_args, (error, status, output) ->
      if error?
        return callback error, output
      else if status != 200
        error = new Error("Unexpected response from server: #{status}")
        return callback error, output

      results = {}
      for key, value of output
        results[key[1...key.length]] = value if key.length > 0 and key[0] == '_'
      callback undefined, results

  _matchUsing: (procedure, pattern, args) ->
    options = {}
    switch args.length
      when 1
        callback = args[0]
      when 2
        max      = args[0]
        callback = args[1]
      when 3
        max      = args[0]
        options  = args[1]
        callback = args[2]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to #{procedure}");

    rpc_args = this._initOptions options
    if procedure == 'match_prefix'
      rpc_args.prefix = pattern
    else
      rpc_args.regex = pattern
    rpc_args.max = max if max?

    @rpcClient.call procedure, rpc_args, (error, status, output) ->
      if error?
        return callback error, output
      else if status != 200
        error = new Error("Unexpected response from server: #{status}")
        return callback error, output

      results = []
      for key, value of output
        results.push(key[1...key.length]) if key.length > 0 and key[0] == '_'
      callback undefined, results

  # prefix, [max], [database], callback
  matchPrefix: (prefix, args...) ->
    this._matchUsing 'match_prefix', prefix, args

  # regex, [max], [database], callback
  matchRegex: (regex, args...) ->
    this._matchUsing 'match_regex', regex, args

  # [key], [options], callback
  getCursor: (args...) ->
    switch args.length
      when 1
        options  = {}
        callback = args[0]
      when 2
        options  = {}
        key      = args[0]
        callback = args[1]
      when 3
        [key, options, callback] = args
      else
        throw new Error("Invalid number of arguments (#{args.length}) to getCursor");

    cursor = new Cursor(this)
    cursor.jump key, options, (error) ->
      callback error, cursor

module.exports = DB

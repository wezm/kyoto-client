http   = require 'http'
util   = require 'util'

Cursor = require './cursor'
RestClient = require './rest_client'
RpcClient = require './rpc_client'

class DB

  # constructor: (x) ->
  #   # not sure we need to do anything here

  open: (@host = 'localhost', @port = 1978) ->
    @client = http.createClient(@port, @host)
    this

  close: (callback) ->
    # Make a dummy request with connection close specified
    request = @client.request 'GET', '/rpc/echo',
      'Connection': 'close'
    request.end()

    request.on 'end', ->
      callback()

  echo: (input, callback) ->
    RpcClient.call @client, 'echo', input, (error, status, output) ->
      if error?
        callback error, output
      else if status != 200
        error = new Error("Unexpected response from server: #{status}")
        callback error, output
      else
        callback undefined, output

  report: (callback) ->
    RpcClient.call @client, 'report', {}, (error, status, output) ->
      if error?
        callback error, output
      else if status != 200
        error = new Error("Unexpected response from server: #{status}")
        callback error, output
      else
        callback undefined, output

  status: (args...) ->
    switch args.length
      when 1 then callback = args[0]
      when 2
        database = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to get");

    rpc_args = {}
    rpc_args.DB = database if database?
    RpcClient.call @client, 'status', rpc_args, (error, status, output) ->
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
      when 1 then callback = args[0]
      when 2
        database = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to clear");

    rpc_args = {}
    rpc_args.DB = database if database?
    RpcClient.call @client, 'clear', rpc_args, (error, status, output) ->
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
      when 1 then callback = args[0]
      when 2
        database = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to set");

    RestClient.put @client, key, value, (error) ->
      callback error

  # Add a record if it doesn't already exist
  add: (key, value, args...) ->
    switch args.length
      when 1 then callback = args[0]
      when 2
        database = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to add");

    rpc_args =
      key: key
      value: value
    rpc_args.DB = database if database?
    RpcClient.call @client, 'add', rpc_args, (error, status, output) ->
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
      when 1 then callback = args[0]
      when 2
        database = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to replace");

    rpc_args =
      key: key
      value: value
    rpc_args.DB = database if database?
    RpcClient.call @client, 'replace', rpc_args, (error, status, output) ->
      if error?
        callback error, output
      else if status == 200
        callback undefined, output
      else if status == 450
        callback (new Error("Record does not exist")), output
      else
        callback new Error("Unexpected response from server: #{status}"), output



  # key, database, callback
  get: (key, args...) ->
    switch args.length
      when 1 then callback = args[0]
      when 2
        database = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to get");

    RestClient.get @client, key, (error, value) ->
      callback error, value

  getBulk: (keys, args...) ->
    switch args.length
      when 1 then callback = args[0]
      when 2
        database = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to getBulk");

    rpc_args = {}
    rpc_args.DB = database if database?
    rpc_args["_#{key}"] = '' for key in keys

    RpcClient.call @client, 'get_bulk', rpc_args, (error, status, output) ->
      if error?
        return callback error, output
      else if status != 200
        error = new Error("Unexpected response from server: #{status}")
        return callback error, output

      results = {}
      for key, value of output
        results[key[1...key.length]] = value if key.length > 0 and key[0] == '_'
      callback undefined, results

  # [key], callback
  getCursor: (args...) ->
    switch args.length
      when 1 then callback = args[0]
      when 2
        key = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to getCursor");

    cursor = new Cursor(this)
    cursor.jump key, (error) ->
      callback error, cursor

module.exports = DB

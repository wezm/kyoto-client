http   = require 'http'
util   = require 'util'
csv    = require 'csv'
assert = require 'assert'

Cursor = require './cursor'
RestClient = require './rest_client'
RpcClient = require './rpc_client'

class DB

  # constructor: (x) ->
  #   # not sure we need to do anything here

  open: (@host, @port) ->
    @client = http.createClient(@port, @host)
    this

  close: (callback) ->
    # Make a dummy request with connection close specified
    request = @client.request 'GET', '/rpc/echo',
      'Connection': 'close'
    request.end()

    request.on 'end', ->
      callback()

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

  # Remove all values
  clear: (callback) ->
    request = @client.request 'GET', '/rpc/clear',
      'Connection': 'keep-alive'
    request.end()

    request.on 'response', (response) ->
      response.on 'end', ->
        switch response.statusCode
          when 200 then callback()
          else callback new Error("Unexpected response from server: #{response.statusCode}");

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

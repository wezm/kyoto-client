http = require 'http'
querystring = require 'querystring'
csv = require 'csv'
util = require 'util'
assert = require 'assert'
RpcClient = require './rpc_client'

class Cursor
  constructor: (@db) ->
    # Cursors have their own client so that the cursor id can be the same
    # for each one
    @client = http.createClient(@db.port, @db.host)
    this

  _jumpUsing: (procedure, args) ->
    switch args.length
      when 1 then callback = args[0]
      when 2
        key      = args[0]
        callback = args[1]
      when 3
        key      = args[0]
        database = args[1]
        callback = args[2]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to #{procedure}");

    rpc_args = {CUR: 1}
    rpc_args.key = key if key?
    rpc_args.DB = database if database?

    RpcClient.call @client, procedure, rpc_args, (error, status, output) ->
      if error?
        callback error, output
      else if status == 200
        callback undefined, output
      else if status == 450
        callback new Error("Cursor has been invalidated"), output
      else if status == 501
        callback new Error("#{procedure} is not supported by this database type"), output
      else
        callback new Error("Unexpected response from server: #{status}"), output

  jump: (args...) ->
    this._jumpUsing 'cur_jump', args

  jumpBack: (args...) ->
    this._jumpUsing 'cur_jump_back', args

  _stepUsing: (procedure, callback) ->
    rpc_args = {CUR: 1}
    rpc_args.key = key if key?

    RpcClient.call @client, procedure, rpc_args, (error, status, output) ->
      if error?
        callback error, output
      else if status == 200
        callback undefined, output
      else if status == 450
        callback new Error("Cursor has been invalidated"), output
      else
        callback new Error("Unexpected response from server: #{status}"), output

  step: (callback) ->
    this._stepUsing 'cur_step', callback

  stepBack: (callback) ->
    this._stepUsing 'cur_step_back', callback

  setValue: (value, args...) ->
    switch args.length
      when 1 then callback = args[0]
      when 2
        step     = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to setValue");

    rpc_args = {CUR: 1, value: value}
    rpc_args.step = 1 if step?

    RpcClient.call @client, 'cur_set_value', rpc_args, (error, status, output) ->
      if error?
        callback error, output
      else if status == 200
        callback undefined, output
      else if status == 450
        callback new Error("Cursor has been invalidated"), output
      else
        callback new Error("Unexpected response from server: #{status}"), output

  # Remove the current cursor value
  remove: (callback) ->
    rpc_args = {CUR: 1}
    RpcClient.call @client, 'cur_remove', rpc_args, (error, status, output) ->
      if error?
        callback error, output
      else if status == 200
        callback undefined, output
      else if status == 450
        callback new Error("Cursor has been invalidated"), output
      else
        callback new Error("Unexpected response from server: #{status}"), output

  # All three of these functions accept a step argument that indicates whether to
  # step or not. It seems 450 is returned when the cursor gets to the end
  getKey: () ->

  getValue: () ->

  # Get current key and value of cursor
  get: (args...) ->
    switch args.length
      when 1 then callback = args[0]
      when 2
        step = args[0]
        callback = args[1]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to get");

    rpc_args = {CUR: 1}
    rpc_args.step = 1 if step?
    RpcClient.call @client, 'cur_get', rpc_args, (error, status, output) ->
      if error?
        callback error, output
      else if status == 200
        callback undefined, output
      else if status == 450
        callback new Error("Cursor has been invalidated"), output
      else
        callback new Error("Unexpected response from server: #{status}"), output

  # Enumerate all entries of the cursor, calling the callback for each one
  each: (callback) ->
    process.nextTick =>
      this.get true, (error, output) =>
        if error
          callback error, output
        else if output != null
          callback undefined, output
          this.each(callback)
        else
          callback undefined, null

  delete: (callback) ->
    request = @client.request 'GET', '/rpc/cur_delete?CUR=1',
      'Connection': 'close'
    request.end()

    request.on 'end', ->
      callback()

module.exports = Cursor

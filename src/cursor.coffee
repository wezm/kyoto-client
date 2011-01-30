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

  _keepAliveRequest: (procedure, params) ->
    params.CUR = 1

    headers =
      'Connection': 'keep-alive '
    path = "/rpc/#{procedure}?#{querystring.stringify params}"

    request = @client.request 'GET', path, headers

  jump: (args...) ->
    switch args.length
      when 1 then callback = args[0]
      when 2
        key      = args[0]
        callback = args[1]
      when 2
        key      = args[0]
        database = args[1]
        callback = args[2]
      else
        throw new Error("Invalid number of arguments (#{args.length}) to jump");

    rpc_args = {CUR: 1}
    rpc_args.key = key if key?
    rpc_args.DB = database if database?

    RpcClient.call @client, 'cur_jump', rpc_args, (error, status, output) ->
      if error?
        callback error, output
      else if status == 200
        callback undefined, output
      else if status == 450
        callback new Error("Cursor has been invalidated"), output
      else
        callback new Error("Unexpected response from server: #{status}"), output

  jumpBack: () ->

  step: () ->

  stepBack: () ->

  setValue: (value) ->

  # Remove the current cursor value
  remove: (callback) ->

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
        throw new Error("Invalid number of arguments (#{args.length}) to jump");

    params = {}
    params.step = 1 if step?

    request = this._keepAliveRequest 'cur_get', params
    request.end()

    request.on 'response', (response) ->
      data = {}

      tsv = csv().fromStream response,
        delimiter: "\t"
        escape: ""
        encoding: 'ascii'
      .on 'data', (row, index) ->
        assert.ok row.length >= 2
        data[row[0]] = row[1]

      # Determine if the content is encoded
      [content_type, colenc] = response.headers['content-type'].split('; ')
      assert.ok content_type == "text/tab-separated-values", "response not in expected TSV format"
      if colenc?
        colenc = colenc.substr -1, 1

      switch colenc
        when 'U'
          tsv.transform (row, index) ->
            unescape(col) for col in row
        when 'B'
          throw new Error("Base64 encoding is not implemented")
        # Quoted-printable is never selected by the server
        # when 'Q'
        #   throw new Error("Quoted-printable encoding is not implemented")

      response.on 'end', ->
        switch response.statusCode
          when 200 then callback(undefined, data.key, data.value)
          when 450
            # X-Kt-Error
            # callback new Error("Cursor has been invalidated")
            callback undefined, null
          else
            callback new Error("Unexpected response from server: #{response.statusCode}")
    # callback undefined

  # Enumerate all entries of the cursor, calling the callback for each one
  each: (callback) ->
    process.nextTick =>
      this.get true, (error, key, value) =>
        if error
          callback error, key, value
        else if key != null
          callback undefined, key, value
          this.each(callback)
        else
          callback undefined, null

  # The rpc call is delete
  close: (callback) ->
    request = @client.request 'GET', '/rpc/cur_delete',
      'Connection': 'close'
    request.end()

    request.on 'end', ->
      callback()

module.exports = Cursor

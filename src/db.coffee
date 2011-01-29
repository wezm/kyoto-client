http   = require 'http'
util   = require 'util'
csv    = require 'csv'
assert = require 'assert'

Cursor = require './cursor'
RestClient = require './rest_client'

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
        throw new Error("Invalid number of arguments (#{args.length}) to get");

    value = ("_#{escape(key)}\t" for key in keys).join('\n')

    request = @client.request 'POST', '/rpc/get_bulk',
      'Content-Length': value.length
      'Connection': 'keep-alive '
      'Content-Type': 'text/tab-separated-values; colenc=U'
    request.end(value)

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

      keepIfResult = (row) ->
        # Exclude keys that aren't the values being looked up
        matches = row[0].match(/^_(.*)$/)
        if matches?
          row[0] = matches[1]
        else
          row = null
        row

      # Decode the data via a CSV transform
      switch colenc
        when 'U'
          tsv.transform (row, index) ->
            keepIfResult (unescape(col) for col in row)

        when 'B'
          throw new Error("Base64 encoding is not implemented yet")
        # Quoted-printable is never selected by the server
        # when 'Q'
        #   throw new Error("Quoted-printable encoding is not implemented")
        else
          tsv.transform (row, index) ->
            keepIfResult row

      response.on 'end', ->
        # X-Kt-Error header has error message if not 200
        switch response.statusCode
          when 200 then callback undefined, data
          else callback new Error("Unexpected response from server: #{response.statusCode}");

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

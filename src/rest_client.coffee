http = require 'http'

# Manages REST style requests
class RestClient
  constructor: (@port, @host) ->
    this

  _extractArgs: (args) ->
    switch args.length
      when 1 then return [{}, args[0]]
      when 2 then return args
      else
        throw new Error("Invalid number of arguments (#{args.length})");

  _expirationTime: (date_or_number) ->
    if typeof date_or_number == 'number'
      Math.round((Date.now() + (1000 * date_or_number)) / 1000)
    else if date_or_number instanceof Date
      date_or_number.toUTCString()
    else
      throw new Error("Invalid expires value, must be Date or Number")

  _buildPath: (params, key) ->
    path = "/#{encodeURIComponent(key)}"
    path = "/#{encodeURIComponent(params.DB)}" + path if params.DB
    path

  get: (key, args...) ->
    [params, callback] = this._extractArgs(args)

    request =
      host: @host
      port: @port
      path: this._buildPath params, key
      headers:
        'Content-Length': 0
        'Connection': 'keep-alive'

    http.get request, (response) ->
      # The whole response body will be buffered in memory
      # if large responses are expected it would be
      # better to write to a file if over some size threshold.
      content_length = parseInt(response.headers['content-length'], 10)
      expires        = if response.headers.hasOwnProperty 'x-kt-xt' then new Date(response.headers['x-kt-xt']) else null

      value = new Buffer(content_length)
      offset = 0

      response.on 'data', (chunk) ->
        chunk.copy(value, offset, 0)
        offset += chunk.length

      response.on 'end', ->
        switch response.statusCode
          when 200 then callback undefined, value, expires
          when 404 then callback undefined, null, expires
          else callback new Error("Unexpected response from server: #{response.statusCode}")
    .on 'error', (error) ->
      callback error

  head: (key, args...) ->
    [params, callback] = this._extractArgs(args)

    options =
      host: @host
      port: @port
      method: 'HEAD'
      path: this._buildPath params, key
      headers:
        'Content-Length': 0
        'Connection': 'keep-alive'

    http.request options, (response) ->
      response.on 'end', ->
        switch response.statusCode
          when 200 then callback undefined, response.headers
          when 404 then callback undefined, null
          else callback new Error("Unexpected response from server: #{response.statusCode}")
    .on 'error', (error) ->
      callback error
    .end()

  put: (key, value, args...) ->
    [params, callback] = this._extractArgs(args)

    options =
      host: @host
      port: @port
      method: 'PUT'
      path: this._buildPath params, key
      headers:
        'Content-Length': if typeof value == 'string' then Buffer.byteLength(value) else value.length
        'Connection': 'keep-alive'
    options.headers['X-Kt-Xt'] = this._expirationTime(params.xt) if params.xt?

    http.request options, (response) ->
      response.on 'end', ->
        switch response.statusCode
          when 201 then callback()
          else callback new Error("Unexpected response from server: #{response.statusCode}")
    .on 'error', (error) ->
      callback error
    .end(value)

  delete: (key, args...) ->
    [params, callback] = this._extractArgs(args)

    options =
      host: @host
      port: @port
      method: 'DELETE'
      path: this._buildPath params, key
      headers:
        'Content-Length': 0
        'Connection': 'keep-alive'

    http.request options, (response) ->
      response.on 'end', ->
        switch response.statusCode
          when 204 then callback()
          when 404 then callback new Error("Record not found")
          else callback new Error("Unexpected response from server: #{response.statusCode}")
    .on 'error', (error) ->
      callback error
    .end()

module.exports = RestClient

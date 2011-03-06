http = require 'http'

# Manages REST style requests
class RestClient
  constructor: (@port, @host) ->
    this

  get: (key, callback) ->
    request =
      host: @host
      port: @port
      path: "/#{escape(key)}"
      headers:
        'Content-Length': 0
        'Connection': 'keep-alive'

    http.get request, (response) ->
      # The whole response body will be buffered in memory
      # if large responses are expected it would be
      # better to write to a file if over some size threshold.
      content_length = parseInt(response.headers['content-length'], 10)
      value = new Buffer(content_length)
      offset = 0

      response.on 'data', (chunk) ->
        chunk.copy(value, offset, 0)
        offset += chunk.length

      response.on 'end', ->
        switch response.statusCode
          when 200 then callback undefined, value
          when 404 then callback undefined, null
          else callback new Error("Unexpected response from server: #{response.statusCode}")
    .on 'error', (error) ->
      callback error

  head: (key, callback) ->
    options =
      host: @host
      port: @port
      method: 'HEAD'
      path: "/#{escape(key)}"
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

  put: (key, value, callback) ->
    options =
      host: @host
      port: @port
      method: 'PUT'
      path: "/#{escape(key)}"
      headers:
        'Content-Length': if typeof value == 'string' then Buffer.byteLength(value) else value.length
        'Connection': 'keep-alive'

    http.request options, (response) ->
      response.on 'end', ->
        switch response.statusCode
          when 201 then callback()
          else callback new Error("Unexpected response from server: #{response.statusCode}")
    .on 'error', (error) ->
      callback error
    .end(value)

  delete: (key, callback) ->
    options =
      host: @host
      port: @port
      method: 'DELETE'
      path: "/#{escape(key)}"
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

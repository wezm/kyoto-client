# Manages an REST style request
module.exports =
  get: (client, key, callback) ->
    request = client.request 'GET', "/#{escape(key)}",
      'Connection': 'keep-alive'
    request.end()

    request.on 'response', (response) ->
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
          else callback new Error("Unexpected response from server: #{response.statusCode}");
  head: (client, key, callback) ->
    request = client.request 'HEAD', "/#{escape(key)}",
      'Connection': 'keep-alive'
    request.end()

    request.on 'response', (response) ->
      response.on 'end', ->
        switch response.statusCode
          when 200 then callback undefined, response.headers
          when 404 then callback undefined, null
          else callback new Error("Unexpected response from server: #{response.statusCode}");
  put: (client, key, value, callback) ->
    request = client.request 'PUT', "/#{escape(key)}",
      'Content-Length': value.length
      'Connection': 'keep-alive '
    request.end(value)

    request.on 'response', (response) ->
      response.on 'end', ->
        switch response.statusCode
          when 201 then callback()
          else callback new Error("Unexpected response from server: #{response.statusCode}");

  delete: (client, key, callback) ->

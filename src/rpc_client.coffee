# Manages an RPC style request
csv = require 'csv'
assert = require 'assert'
http = require 'http'
base64 = require 'base64'

class RpcClient
  constructor: (@port, @host) ->
    this

  call: (procedure, args, callback) ->
    body = ([encodeURIComponent(key), encodeURIComponent(value)].join("\t") for key, value of args).join("\n")
    options =
      host: @host
      port: @port
      method: 'POST'
      path: "/rpc/#{procedure}"
      headers:
        'Connection': 'keep-alive'
        'Content-Length': if typeof body == 'string' then Buffer.byteLength(body) else body.length
        'Content-Type': 'text/tab-separated-values; colenc=U'

    http.request options, (response) ->
      data = {}

      tsv = csv().fromStream response,
        delimiter: "\t"
        escape: ""
        encoding: 'ascii' # All content is ASCII safe (I.e. base64 or url-encoded)
      .on 'data', (row, index) ->
        assert.ok row.length >= 2 # TODO: Change this
        data[row[0]] = row[1]

      # Determine if the content is encoded
      [content_type, colenc] = response.headers['content-type'].split('; ')
      # TODO: Replace with an error callback
      assert.ok content_type == "text/tab-separated-values", "response not in expected TSV format: #{response.statusCode} #{content_type}"
      if colenc?
        colenc = colenc.substr -1, 1

      switch colenc
        when 'U'
          tsv.transform (row, index) ->
            decodeURIComponent(col) for col in row
        when 'B'
          tsv.transform (row, index) ->
            base64.decode(col) for col in row
        # Quoted-printable is never selected by the server
        # when 'Q'
        #   throw new Error("Quoted-printable encoding is not implemented")

      response.on 'end', ->
        callback undefined, response.statusCode, data
    .on 'error', (error) ->
      callback(error)
    .end(body)

module.exports = RpcClient

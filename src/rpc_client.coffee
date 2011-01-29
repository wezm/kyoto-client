# Manages an RPC style request
csv = require 'csv'
assert = require 'assert'

module.exports =
  call: (client, procedure, args, callback) ->
    body = ([escape(key), escape(value)].join("\t") for key, value of args).join("\n")
    headers =
      'Connection': 'keep-alive'
      'Content-Length': body.length
      'Content-Type': 'text/tab-separated-values; colenc=U'
    request = client.request 'POST', "/rpc/#{procedure}", headers
    request.end(body)

    request.on 'response', (response) ->
      data = {}

      tsv = csv().fromStream response,
        delimiter: "\t"
        escape: ""
        encoding: 'ascii'
      .on 'data', (row, index) ->
        assert.ok row.length >= 2 # TODO: Change this
        data[row[0]] = row[1]

      # Determine if the content is encoded
      [content_type, colenc] = response.headers['content-type'].split('; ')
      # TODO: Replace with an error callback
      assert.ok content_type == "text/tab-separated-values", "response not in expected TSV format"
      if colenc?
        colenc = colenc.substr -1, 1

      switch colenc
        when 'U'
          tsv.transform (row, index) ->
            unescape(col) for col in row
        when 'B'
        # TODO: Return a proper error
          throw new Error("Base64 encoding is not implemented")
        # Quoted-printable is never selected by the server
        # when 'Q'
        #   throw new Error("Quoted-printable encoding is not implemented")

      response.on 'end', ->
        callback undefined, response.statusCode, data

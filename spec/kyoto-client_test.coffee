vows = require 'vows'
kt = require '../lib/index'
util = require 'util'
assert = require 'assert'

db = new kt.Db()

vows.describe('kyoto-client').addBatch(
  'after successfully opening':
    topic: ->
      db.open 'localhost', 1978
      db.clear(this.callback)
      undefined

    'echo':
      topic: ->
        db.echo {test: "Value"}, this.callback
        undefined

      'returns the input': (error, output) ->
        assert.deepEqual output, {test: "Value"}

    'get non-existent value':
      topic: ->
        db.get 'not-here', this.callback
        undefined

      'returns null': (error, value) ->
        assert.isNull value

    'set':
      topic: ->
        db.set 'test', "Test Value", (error) =>
          db.get 'test', this.callback
        undefined

      'allows the value to be retrieved': (error, value) ->
          assert.equal value.toString('utf8'), "Test Value"

    'getBulk':
      topic: ->
        db.set 'bulk1', "Bulk Value 1", (error) =>
          db.set 'bulk2', "Bulk Value 2", (error) =>
            db.getBulk ['bulk1', 'bulk2', 'missing'], this.callback
        undefined

      'allows multiple values to be retrieved at once': (error, results) ->
        assert.equal results.bulk1, "Bulk Value 1"
        assert.equal results.bulk2, "Bulk Value 2"
        assert.isUndefined results.missing

    'getBulk with escaped values':
      topic: ->
        db.set 'bulk3', "Bulk\tValue", (error) =>
          db.set 'bulk4', "Bulk Value 2", (error) =>
            db.getBulk ['bulk3', 'bulk4'], this.callback
        undefined

      'allows multiple values to be retrieved at once': (error, results) ->
        assert.equal results.bulk3, "Bulk\tValue"
        assert.equal results.bulk4, "Bulk Value 2"
        assert.isUndefined results.missing

    'Cursor with starting key':
      topic: ->
        # Add a value for the cursor to retrieve
        db.set 'cursor-test', "Cursor\tValue", (error) =>
          db.getCursor 'cursor-test', this.callback
        undefined

      'get':
        topic: (cursor) ->
          cursor.get this.callback
          undefined

        'returns the key and value': (error, output) ->
          assert.equal output.key.toString('utf8'), "cursor-test"
          assert.equal output.value.toString('utf8'), "Cursor\tValue"

      'remove':
        topic: (cursor) ->
          cursor.remove this.callback
          undefined

        'completes without error': (error, output) ->
          assert.isFalse error?

      'each':
        topic: (cursor) ->
          count = 0
          cursor.each (error, output) =>
            if output.key?
              count++
            else
              this.callback(undefined, count)
          undefined

        'calls the callback': (error, count) ->
          assert.isTrue count > 0, "count is greater than zero"

    'Cursor without a starting key':
      topic: ->
        db.set 'cursor-test2', "Cursor\tValue", (error) =>
          db.getCursor this.callback
        undefined

      'each':
        topic: (cursor) ->
          count = 0
          cursor.each (error, output) =>
            if output.key?
              count++
            else
              this.callback(undefined, count)
          undefined

        'calls the callback': (error, count) ->
          assert.isTrue count > 0, "count is greater than zero"

).export(module)
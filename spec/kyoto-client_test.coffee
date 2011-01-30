vows = require 'vows'
kt = require '../lib/index'
util = require 'util'
assert = require 'assert'

vows.describe('kyoto-client').addBatch(
  'Db':
    'creating the client':
      topic: new kt.Db

      'after successfully opening':
        topic: (db) ->
          db.open 'localhost', 1978
          db.clear(this.callback)
          undefined

        'and clearing':
          topic: (error, db) ->
            db

          'get non-existent value':
            topic: (db) ->
              db.get 'not-here', this.callback
              undefined

            'returns null': (error, value) ->
              assert.isNull value

          'set':
            topic: (db) ->
              db.set 'test', "Test Value", (error) =>
                db.get 'test', this.callback
              undefined

            'allows the value to be retrieved': (error, value) ->
                assert.equal value.toString('utf8'), "Test Value"

          'getBulk':
            topic: (db) ->
              db.set 'bulk1', "Bulk Value 1", (error) =>
                db.set 'bulk2', "Bulk Value 2", (error) =>
                  db.getBulk ['bulk1', 'bulk2', 'missing'], this.callback
              undefined

            'allows multiple values to be retrieved at once': (error, results) ->
              assert.equal results.bulk1, "Bulk Value 1"
              assert.equal results.bulk2, "Bulk Value 2"
              assert.isUndefined results.missing

          'getBulk with escaped values':
            topic: (db) ->
              db.set 'bulk3', "Bulk\tValue", (error) =>
                db.set 'bulk4', "Bulk Value 2", (error) =>
                  db.getBulk ['bulk3', 'bulk4'], this.callback
              undefined

            'allows multiple values to be retrieved at once': (error, results) ->
              assert.equal results.bulk3, "Bulk\tValue"
              assert.equal results.bulk4, "Bulk Value 2"
              assert.isUndefined results.missing

          'Cursor with starting key':
            topic: (db) ->
              # Add a value for the cursor to retrieve
              db.set 'cursor-test', "Cursor\tValue", (error) =>
                db.getCursor 'cursor-test', this.callback
              undefined

            'current value can be retrieved': (error, cursor) ->
              cursor.get (error, output) ->
                assert.equal output.key.toString('utf8'), "cursor-test"
                assert.equal output.value.toString('utf8'), "Cursor\tValue"

            'current value can be removed': (error, cursor) ->
              cursor.remove (error, output) ->
                assert.isUndefined error

            'can be enumerated': (error, cursor) ->
              count = 0
              cursor.each (error, output) ->
                assert.isUndefined error
                if key?
                  count++
                else
                  assert.ok count > 0, "count is greater than zero"

            'Cursor with no start key':
              topic: (_, _, _, db) ->
                db.getCursor this.callback
                undefined

              'can be enumerated': (error, cursor) ->
                count = 0
                cursor.each (error, output) ->
                  assert.isUndefined error
                  if key?
                    count++
                  else
                    assert.ok count > 0, "count is greater than zero"

).export(module)
kt = require '../lib/index'
util = require 'util'
testCase = require('nodeunit').testCase

db = new kt.Db()
db.open()

dbClear = (callback) ->
  db.clear (error, output) ->
    callback()

module.exports =
  'Cursor with a starting key': testCase
    setUp: (callback) ->
      db.clear (error, output) =>
        db.set 'cursor-test', "Cursor\tValue", (error) =>
          db.getCursor (error, cursor) =>
            this.cursor = cursor
            callback()

    tearDown: (callback) ->
      this.cursor.delete()
      callback()

    get:
      'returns the key and value': (test) ->
        test.expect 2
        this.cursor.get (error, output) ->
          test.equal output.key.toString('utf8'), "cursor-test"
          test.equal output.value.toString('utf8'), "Cursor\tValue"
          test.done()

    remove:
      'removes the record': (test) ->
        test.expect 2
        this.cursor.remove (error, output) ->
          test.ifError error

          db.get 'cursor-test', (error, value) ->
            test.ok value == null
            test.done()

    each:
      'yields records on each iteration': (test) ->
        test.expect 1
        results = []

        runTest = =>
          this.cursor.jump (error) =>
            this.cursor.each (error, output) ->
              if output.key?
                results.push [output.key, output.value]
              else
                test.deepEqual [
                    [ '1', 'One' ]
                    [ '2', 'Two' ]
                    [ 'cursor-test', 'Cursor\tValue' ]
                  ],
                  results
                test.done()

        db.set '1', 'One', (error, output) ->
          db.set '2', 'Two', (error, output) ->
            runTest()

  'Cursor without a starting key': testCase
    setUp: (callback) ->
      db.clear (error, output) =>
        db.set 'cursor-test', "Cursor\tValue", (error) =>
          db.getCursor 'cursor-test', (error, cursor) =>
            this.cursor = cursor
            callback()

    tearDown: (callback) ->
      this.cursor.delete()
      callback()

    get:
      'returns the key and value': (test) ->
        test.expect 2
        this.cursor.get (error, output) ->
          test.equal output.key.toString('utf8'), "cursor-test"
          test.equal output.value.toString('utf8'), "Cursor\tValue"
          test.done()

    remove:
      'removes the record': (test) ->
        test.expect 2
        this.cursor.remove (error, output) ->
          test.ifError error

          db.get 'cursor-test', (error, value) ->
            test.ok value == null
            test.done()

    each:
      'yields records on each iteration': (test) ->
        test.expect 1
        results = []

        runTest = =>
          this.cursor.jump '1', (error) =>
            this.cursor.each (error, output) ->
              if output.key?
                results.push [output.key, output.value]
              else
                test.deepEqual [
                    [ '1', 'One' ]
                    [ '2', 'Two' ]
                    [ 'cursor-test', 'Cursor\tValue' ]
                  ],
                  results
                test.done()

        db.set '1', 'One', (error, output) ->
          db.set '2', 'Two', (error, output) ->
            runTest()

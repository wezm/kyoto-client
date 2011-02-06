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
            @cursor = cursor
            callback()

    tearDown: (callback) ->
      @cursor.delete()
      callback()

    get:
      'returns the key and value': (test) ->
        test.expect 2
        @cursor.get (error, output) ->
          test.equal output.key.toString('utf8'), "cursor-test"
          test.equal output.value.toString('utf8'), "Cursor\tValue"
          test.done()

    remove:
      'removes the record': (test) ->
        test.expect 2
        @cursor.remove (error, output) ->
          test.ifError error

          db.get 'cursor-test', (error, value) ->
            test.ok value == null
            test.done()

    each:
      'yields records on each iteration': (test) ->
        test.expect 2

        runTest = =>
          results = []
          @cursor.jump (error) =>
            @cursor.each (error, output) ->
              if output.key?
                results.push [output.key, output.value]
              else
                test.ifError error
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
      @records =
        'first': "Cursor\tValue"
        'last': "At the end"
      db.clear (error, output) =>
        db.setBulk @records, (error) =>
          db.getCursor 'cursor-test', (error, cursor) =>
            @cursor = cursor
            callback()

    tearDown: (callback) ->
      @cursor.delete()
      callback()

    jump:
      'allows traversal from the first record': (test) ->
        test.expect 2
        @cursor.jump (error, output) =>
          test.ifError error
          @cursor.getKey (error, output) ->
            test.equal output.key.toString('utf8'), "first"
            test.done()

      'step goes to the next record': (test) ->
        test.expect 1
        @cursor.jump (error, output) =>
          @cursor.step (error, output) =>
            @cursor.getKey (error, output) ->
              test.equal output.key.toString('utf8'), "last"
              test.done()

    jumpBack:
      'allows traversal from the last record': (test) ->
        test.expect 2
        @cursor.jumpBack (error, output) =>
          test.ifError error
          @cursor.getKey (error, output) ->
            test.equal output.key.toString('utf8'), "last"
            test.done()

      'stepBack goes to the previous record': (test) ->
        test.expect 1
        @cursor.jumpBack (error, output) =>
          @cursor.stepBack (error, output) =>
            @cursor.get (error, output) ->
              test.equal output.key.toString('utf8'), "first"
              test.done()

    setValue:
      'sets the value of the current record': (test) ->
        test.expect 2
        @cursor.setValue "New Value", (error, output) =>
          test.ifError error
          @cursor.getValue (error, output) ->
            test.equal output.value.toString('utf8'), "New Value"
            test.done()

      'allows stepping to the next record': (test) ->
        test.expect 2
        @cursor.setValue "New Value", true, (error, output) =>
          test.ifError error
          @cursor.getKey (error, output) ->
            test.equal output.key.toString('utf8'), 'last'
            test.done()

    remove:
      'removes the record': (test) ->
        test.expect 2
        @cursor.remove (error, output) ->
          test.ifError error

          db.get 'cursor-test', (error, value) ->
            test.ok value == null
            test.done()

    getKey:
      'returns the key of the current record': (test) ->
        test.expect 1
        @cursor.getKey (error, output) ->
          test.equal output.key.toString('utf8'), "first"
          test.done()

      'allows stepping to the next record': (test) ->
        test.expect 2
        @cursor.getKey true, (error, output) =>
          test.ifError error
          @cursor.get (error, output) ->
            test.equal output.key.toString('utf8'), 'last'
            test.done()

    getValue:
      'returns the value of the current record': (test) ->
        test.expect 1
        @cursor.getValue (error, output) ->
          test.equal output.value.toString('utf8'), "Cursor\tValue"
          test.done()

      'allows stepping to the next record': (test) ->
        test.expect 2
        @cursor.getValue true, (error, output) =>
          test.ifError error
          @cursor.get (error, output) ->
            test.equal output.key.toString('utf8'), 'last'
            test.done()

    get:
      'returns the key and value of the current record': (test) ->
        test.expect 2
        @cursor.get (error, output) ->
          test.equal output.key.toString('utf8'), "first"
          test.equal output.value.toString('utf8'), "Cursor\tValue"
          test.done()

      'allows stepping to the next record': (test) ->
        test.expect 2
        @cursor.get true, (error, output) =>
          test.ifError error
          @cursor.get (error, output) ->
            test.equal output.key.toString('utf8'), 'last'
            test.done()

    each:
      'yields records on each iteration': (test) ->
        test.expect 2

        runTest = =>
          results = []
          @cursor.jump '1', (error) =>
            @cursor.each (error, output) ->
              if output.key?
                results.push [output.key, output.value]
              else
                test.ifError error
                test.deepEqual [
                    [ '1', 'One' ]
                    [ '2', 'Two' ]
                    [ 'first', 'Cursor\tValue' ]
                    [ 'last', 'At the end' ]
                  ],
                  results
                test.done()

        db.set '1', 'One', (error, output) ->
          db.set '2', 'Two', (error, output) ->
            runTest()

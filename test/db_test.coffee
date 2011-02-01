kt = require '../lib/index'
util = require 'util'
testCase = require('nodeunit').testCase

db = new kt.Db()
db.open()

dbClear = (callback) ->
  db.clear (error, output) ->
    callback()

module.exports =
  echo: testCase
    setUp: dbClear

    'returns the supplied input': (test) ->
      test.expect 1
      db.echo {test: "Value"}, (error, output) ->
        test.deepEqual output, {test: "Value"}
        test.done()

  report: testCase
    setUp: dbClear

    'returns reporting information': (test) ->
      test.expect 4
      db.report (error, output) ->
        test.ok Object.keys(output).length > 0
        test.ok output.hasOwnProperty 'conf_kc_version'
        test.ok output.hasOwnProperty 'conf_kt_version'
        test.ok output.hasOwnProperty 'conf_os_name'
        test.done()

  status: testCase
    setUp: dbClear

    'returns status information about the database': (test) ->
      test.expect 2
      db.status (error, output) ->
        test.ok Object.keys(output).length > 0
        test.ok output.hasOwnProperty 'count'
        test.done()

  set: testCase
    setUp: dbClear

    'completes without error': (test) ->
      test.expect 1
      db.set 'test', "Test", (error, output) ->
        test.ifError error
        test.done()

  add: testCase
    setUp: dbClear

    'completes without error when the record does not exist': (test) ->
      test.expect 1
      db.add 'test', "Test", (error, output) ->
        test.ifError error
        test.done()

    'returns an error if the record exists': (test) ->
      test.expect 2
      db.add 'test', "Test", (error, output) ->
        db.add 'test', "Test", (error, output) ->
          test.ok error?
          test.equal error.message, "Record exists"
          test.done()

  replace: testCase
    setUp: dbClear

    'completes without error when the record exists': (test) ->
      test.expect 1
      db.add 'test', "Test", (error, output) ->
        db.replace 'test', "New Value", (error, output) ->
          test.ifError error
          test.done()

    'returns an error if the record does not exist': (test) ->
      test.expect 2
      db.replace 'test', "New Value", (error, output) ->
        test.ok error?
        test.equal error.message, "Record does not exist"
        test.done()

  append: testCase
    setUp: dbClear

    'appends to an existing value': (test) ->
      test.expect 2
      db.set 'test', "Test", (error, output) ->
        db.append 'test', " Value", (error, output) ->
          test.ifError error

          db.get 'test', (error, value) ->
            test.equal value, "Test Value"
            test.done()

    'sets a non-existent value': (test) ->
      test.expect 2
      db.append 'test', "Value", (error, output) ->
        test.ifError error

        db.get 'test', (error, value) ->
          test.equal value, "Value"
          test.done()

  get: testCase
    setUp: dbClear

    'returns null for non-existent key': (test) ->
      test.expect 1
      db.get 'test', (error, value) ->
        test.ok value == null
        test.done()

    'retrieves an existing key': (test) ->
      test.expect 1
      db.set 'test', "Test\tValue", (error) ->
        db.get 'test', (error, value) ->
          test.equal value, "Test\tValue"
          test.done()

  getBulk: testCase
    setUp: dbClear

    'allows multiple values to be retrieved at once': (test) ->
      test.expect 2
      db.set 'bulk1', "Bulk\tValue", (error) ->
        db.set 'bulk2', "Bulk Value 2", (error) ->
          db.getBulk ['bulk1', 'bulk3'], (error, results) ->
            test.equal results.bulk1, "Bulk\tValue"
            test.ok not results.hasOwnProperty 'bulk3'
            test.done()

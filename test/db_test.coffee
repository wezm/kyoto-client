kt = require '../lib/index'
util = require 'util'
testCase = require('nodeunit').testCase

db = new kt.Db()
db.open()

dbClear = (callback) ->
  db.clear (error, output) ->
    callback()

p = (item) ->
  util.log util.inspect item

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

  # TODO: set should accept numeric values and store them as such in Kyoto.
  # This would allow them to be incremented/decremented with the appropriate
  # functions.
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

  increment: testCase
    setUp: dbClear

    'increments compatible records': (test) ->
      test.expect 2
      db.increment 'inc', 1, (error, output) ->
        test.equal output.num, '1'

        db.increment 'inc', 4, (error, output) ->
          test.equal output.num, '5'
          test.done()

    'can increment by negative values': (test) ->
      test.expect 1
      db.increment 'inc', -5, (error, output) ->
        test.equal output.num, '-5'
        test.done()

    'returns an error if the record is incompatible': (test) ->
      # Only records set via increment appear to be manipulatable with it.
      test.expect 1
      db.set 'inc', '1', (error, output) ->
        db.increment 'inc', 1, (error, output) ->
          test.ok error?
          test.done()

  incrementDouble: testCase
    setUp: dbClear

    'increments compatible records': (test) ->
      test.expect 2
      db.incrementDouble 'inc', 1.5, (error, output) ->
        test.equal output.num, '1.500000'

        db.incrementDouble 'inc', 4.95, (error, output) ->
          test.equal output.num, '6.450000'
          test.done()

    'can increment by negative values': (test) ->
      test.expect 1
      db.incrementDouble 'inc', -1.25, (error, output) ->
        test.equal output.num, '-1.250000'
        test.done()

    'returns an error if the record is incompatible': (test) ->
      # Only records set via increment appear to be manipulatable with it.
      test.expect 1
      db.set 'inc', '1.3', (error, output) ->
        db.incrementDouble 'inc', 0.100000, (error, output) ->
          test.ok error?
          test.done()

  cas: testCase
    setUp: dbClear

    'sets the new value when the old value matches': (test) ->
      test.expect 2
      db.set 'test', 'old', ->
        db.cas 'test', 'old', 'new', (error, output) ->
          test.ifError error
          db.get 'test', (error, value) ->
            test.equal value, 'new'
            test.done()

    'doesn\'t set the new value when the old value differs': (test) ->
      test.expect 3
      db.set 'test', 'old', ->
        db.cas 'test', 'not old', 'new', (error, output) ->
          test.ok error?
          test.equal error.message, "Record has changed"
          db.get 'test', (error, value) ->
            test.equal value, 'old'
            test.done()

    'removes the record when the new value is null': (test) ->
      test.expect 2
      db.set 'test', 'old', ->
        db.cas 'test', 'old', null, (error, output) ->
          test.ifError error
          db.get 'test', (error, value) ->
            test.equal value, null
            test.done()

  remove: testCase
    setUp: dbClear

    'removes records that exist': (test) ->
      test.expect 2
      db.set 'test', 'old', ->
        db.remove 'test', (error) ->
          test.ifError error
          db.get 'test', (error, value) ->
            test.equal value, null
            test.done()

    'returns an error if the record doesn\'t exist': (test) ->
      test.expect 2
      db.remove 'test', (error) ->
        test.ok error?
        test.equal error.message, "Record not found"
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

  setBulk: testCase
    setUp: dbClear

    'allows multiple values to be set at once': (test) ->
      test.expect 2
      records =
        bulk1: "Bulk\tValue"
        bulk2: "Bulk Value 2"
      db.setBulk records, (error, output) ->
        test.ifError error
        test.equal output.num, '2'
        test.done()

  removeBulk: testCase
    setUp: dbClear

    'allows multiple values to be removed at once': (test) ->
      test.expect 3
      records =
        bulk1: "Bulk\tValue"
        bulk2: "Bulk Value 2"
      db.setBulk records, (error, output) ->
        test.equal output.num, '2'
        db.removeBulk records, (error, output) ->
          test.ifError error
          test.equal output.num, '2'
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

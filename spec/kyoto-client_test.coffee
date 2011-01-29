vows = require 'vows'
kt = require '../lib/index'
util = require 'util'
assert = require 'assert'

# Db = kt.Db

# count = 0
# valid_bookmark = ->
#   count++
#   {
#     href: "http://example.com/#{count}",
#     title: "Example Domain",
#     description: "This is an test domain",
#     tags: ["testing", "domain"],
#     time: '2011-01-01 00:00:00'
#     public: true
#   }
#
# updatesField = (field, value) ->
#   (error, bookmark) ->
#     assert.equal bookmark[field], value
#

vows.describe('kyoto-client').addBatch(
  'Db':
    'creating the client':
      topic: new kt.Db

      'after successfully opening':
        topic: (db) ->
          db.open 'localhost', 1978

        'getting a non-existent value':
          topic: (db) ->
            db.get 'not-here', this.callback
            undefined

          'returns null for the value': (error, value) ->
            assert.isNull value

        'setting a value':
          topic: (db) ->
            db.set 'test', "Test Value", (error) =>
              db.get 'test', this.callback
            undefined

          'allows the value to be retrieved': (error, value) ->
              assert.equal value.toString('utf8'), "Test Value"

        'Cursor':
          topic: (db) ->
            # Add a value for the cursor to retrieve
            db.set 'cursor-test', "Cursor\tValue", (error) =>
              db.getCursor 'cursor-test', (error, cursor) =>
                cursor.get this.callback

            undefined

          'current value can be retrieved': (error, key, value) ->
            assert.equal key.toString('utf8'), "cursor-test"
            assert.equal value.toString('utf8'), "Cursor\tValue"

      #     'and clearing the datastore':
      #       topic: (error, error, bookmarks) ->
      #         bookmarks
      #
      #       'saving a bookmark':
      #         topic: (bookmarks) ->
      #           bookmarks.save(valid_bookmark(), this.callback)
      #           undefined
      #
      #         'has no errors': (error, bookmark) ->
      #           assert.isNull error
      #
      #         'sets the id of the bookmark': (error, bookmark) ->
      #           assert.isNumber bookmark.id
      #
      #       'updating a bookmark':
      #         topic: (bookmarks) ->
      #           topic = this
      #           bookmarks.save valid_bookmark(), (error, bookmark) ->
      #             # Modify fields
      #             bookmark.href = "http://new.example.com/"
      #             bookmark.title = "Changed"
      #             bookmark.description = "A changed description"
      #             bookmark.public = false
      #             bookmark.tags = ["one", "two"]
      #
      #             bookmarks.save bookmark, (error, bookmark) ->
      #               # Retrieve the bookmark afresh
      #               bookmarks.get(bookmark.id, topic.callback)
      #           undefined
      #
      #         'updates the href': updatesField 'href', "http://new.example.com/"
      #         'updates the title': updatesField 'title', "Changed"
      #         'updates the description': updatesField 'description', 'A changed description'
      #         'updates the public status': (error, bookmark) ->
      #           assert.strictEqual bookmark.public, false
      #         'updates the tags': (error, bookmark) ->
      #           assert.deepEqual(bookmark.tags, ["one", "two"])

).export(module)
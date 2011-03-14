exports.Db = require './db'
exports.version = '0.2.0'

if not module.parent
  console.log exports.version

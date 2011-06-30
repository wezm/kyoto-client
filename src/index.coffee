exports.Db = require './db'
exports.version = '0.4.0'

if not module.parent
  console.log exports.version

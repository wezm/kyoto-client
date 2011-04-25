exports.Db = require './db'
exports.version = '0.3.0'

if not module.parent
  console.log exports.version

exports.Db = require './db'
exports.version = '0.1.1'

if not module.parent
  console.log exports.version

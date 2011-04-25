---
title: kyoto-client - Kyoto Tycoon client for node.js
---

<h1><span id="logo"></span> kyoto-client -- Kyoto Tycoon client for node.js</h1>

<a name="intro"></a>
Introduction
------------

kyoto-client is a [node.js][node] module that acts as a client to a [Kyoto
Tycoon][kyoto] server. Kyoto Tycoon is the server component of [Kyoto
Cabinet][cabinet], a fast, efficient key-value store developed by [FAL
labs][fallabs]. Records can be stored on disk or in memory using a hash table
or B+ tree.

[node]: http://nodejs.org/
[kyoto]: http://fallabs.com/kyototycoon/
[cabinet]: http://fallabs.com/kyotocabinet/
[fallabs]: http://fallabs.com/

<a name="install"></a>
Installation
------------

Installation via [npm] is recommended:

    npm install kyoto-client

[npm]: http://npmjs.org/

<a name="development"></a>
Development
------------

kyoto-client is implemented in [CoffeeScript][coffee] and uses [nodeunit] for
testing. Both are available via npm as `coffee-script` and `nodeunit`
respectfully. It is developed against the current stable node.js version.

The primary documentation for the project is its website, the source of which
is also included here. The website is built with [nanoc]. To get setup for
making documentation changes you'll need to install nanoc and some other
RubyGems:

* From the [doc] directory run `bundle install` (assumes you have previously
  installed [bundler]).
* Start the nanoc autocompiler with `bundle exec nanoc aco` and navigate to
  [http://localhost:3000/](http://localhost:3000/).

[nanoc]: http://nanoc.stoneship.org/
[bundler]: http://gembundler.com/
[doc]: https://github.com/wezm/kyoto-client/tree/master/doc

Contributions are welcome and should maintain the existing coding style and be
accompanied by tests and documentation. Bugs and desired features are tracked
in the [issue tracker][issues]. The tests can be run via `cake test`.

[coffee]: http://jashkenas.github.com/coffee-script/
[nodeunit]: https://github.com/caolan/nodeunit
[issues]: https://github.com/wezm/kyoto-client/issues

<a name="licence"></a>
Licence
-------

kyoto-client is licenced under the BSD licence. Refer to the [LICENCE] in the
repository for the full details.

[LICENCE]: https://github.com/wezm/kyoto-client/blob/master/LICENSE

<a name="api"></a>
API
---

<a name="db"></a>
### DB

The DB class is the primary interface to a Kyoto Tycoon database.

<a name="new"></a>
#### ◆ constructor `new(defaultDatabase)`

Constructs and returns a new DB object.

* `defaultDatabase` [String] or [Number] -- The default Kyoto Tycoon database
  to operate upon when not expicitly specified in a procedure. See also
  [defaultDatabase](#defaultDatabase).

##### Example
<pre class="highlight"><code class="language-js">var kt = require('kyoto-client');
var db = new kt.Db();

// With default database
var db = new kt.Db('default.kct');
</code></pre>

<a name="open"></a>
#### ◆ open `open(hostname='localhost', port=1978)`

Open a connection to the database. Returns the Db object.

* `hostname` [String] -- The hostname of the database.
* `port` [Number] -- The port to connect to on the host.

##### Examples
<pre class="highlight"><code class="language-js">db.open();

// on a different host
db.open('kyoto.example.com');
</code></pre>

<pre class="highlight"><code class="language-js">var kyoto = require('kyoto-client');

// Chained with new
var db = new kyoto.Db().open('example.com', 1978);
</code></pre>

<a name="close"></a>
#### ◆ close `close(callback)`

Close the connection to the database.

Internally kyoto-client uses a persistent connection to the database to make
requests faster. However to prevent your node application from hanging you
must call `db.close` when you are done so that this persistent connection is
closed.

* `callback(error)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`

##### Example
<pre class="highlight"><code class="language-js">
db.close(function(error) {
  // Connection is now closed. The db can't be used anymore.
});
</code></pre>

<a name="defaultDatabase"></a>
#### ◆ defaultDatabase `defaultDatabase([database])`

Set or get the default database.

A Tokyo Tycoon server can host multiple databases. Requests can be directed
at a particular database by name or number. E.g. `'users.kct'` or `1`.

For procedures that accept a database option the value of defaultDatabase
will be used if the option isn't specified.

* `database` [String] or [Number] -- database to make default.
  If not specified the current value for the default database is returned.

##### Example
<pre class="highlight"><code class="language-js">
// Set the default database
db.defaultDatabase('example.kct');

// Retrieve the current default database value
db.defaultDatabase();
</code></pre>

<a name="echo"></a>
#### ◆ echo `echo(input, callback)`

Echo back the input data as the output data

* `input` [Object] -- Arbitrary key-value pairs
* `callback(error, output)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Key-value pairs

##### Example
<pre class="highlight"><code class="language-js">
db.echo({test: "Value"}, function(error, output) {
  // output -> {test: "Value"}
});
</code></pre>

<a name="report"></a>
#### ◆ report `report(callback)`

Get a report on the server.

* `callback(error, output)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Key-value pairs

##### Example
<pre class="highlight"><code class="language-js">
db.report(function(error, output) {
/* output ->
 { conf_kc_features: '(atomic)(zlib)'
 , conf_kc_version: '1.2.30 (7.1)'
 , conf_kt_features: '(kqueue)(lua)'
 , conf_kt_version: '0.9.19 (1.25)'
 , conf_os_name: 'Mac OS X'
 , db_0: 'count=2 size=400128 path=tests.kct'
 , db_total_count: '2'
 , db_total_size: '400128'
 , serv_conn: '1'
 , serv_task: '0'
 , sys_mem_peak: '2777088'
 , sys_mem_rss: '2777088'
 , sys_mem_size: '2777088'
 , sys_proc_id: '70687'
 , sys_ru_stime: '73.651796'
 , sys_ru_utime: '90.519024'
 , sys_time: '351491.752587'
 }
*/
});
</code></pre>

<a name="play_script"></a>
#### ◆ playScript

Call a procedure of the script language ([Lua]) extension.

[Lua]: http://www.lua.org/

Not yet implemented.

<a name="tune_replication"></a>
#### ◆ tuneReplication

Configure the replication configuration.

Not yet implemented.

<a name="status"></a>
#### ◆ status `status([options], callback)`

Get miscellaneous status information about a database.

* `options` [Object] -- Options hash
  * `database` [String] or [Number] -- A database name or index.
    For example: `test.kct` or `1`.
* `callback(error, output)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Key-value pairs

##### Example
<pre class="highlight"><code class="language-js">
db.status(function(error, output) {
/* output ->
 { apow: '8'
 , bnum: '65536'
 , chksum: '188'
 , count: '2'
 , cusage: '66'
 , dfunit: '0'
 , first: '1'
 , flags: '1'
 , fmtver: '5'
 , fpow: '10'
 , frgcnt: '0'
 , icnt: '0'
 , ktcapcnt: '-1'
 , ktcapsiz: '-1'
 , ktopts: '0'
 , last: '1'
 , lcnt: '1'
 , librev: '1'
 , libver: '7'
 , msiz: '67108864'
 , opts: '0'
 , path: 'tests.kct'
 , pccap: '67108864'
 , pnum: '2'
 , psiz: '8192'
 , rcomp: 'lexical'
 , realsize: '400128'
 , realtype: '49'
 , recovered: '0'
 , reorganized: '0'
 , root: '1'
 , size: '400128'
 , trimmed: '0'
 , type: '49'
 }
*/
});

// For a specific database
db.status({database: "users.kct"}, function(error, output) {
  // output contains status info for the users database
});
</code></pre>

<a name="clear"></a>
#### ◆ clear `clear([options], callback)`

Remove all records from the database.

* `options` [Object] -- Options hash
  * `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, output)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Key-value pairs

##### Example
<pre class="highlight"><code class="language-js">
db.clear(function(error, output) {
  // output -> {}
});

// Clear a specific database
db.clear({database: "test.kct"}, function(error, output) {
  // output -> {}
});
</code></pre>

<a name="synchronize"></a>
#### ◆ synchronize

Synchronize updated contents with the file and the device

Not yet implemented.

<a name="set"></a>
#### ◆ set `set(key, value, [options], callback)`

Set value of a record.

* `key` [String] -- The key of the record
* `value` -- [String] or [Buffer] -- The value of the record
* `options` [Object] -- Options hash
  * `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
  * `expiry` [Date] or [Number] -- Set the expiry time of the record.
    When a date, this value will be when the record expires. When a number
    the record will expire in the the value specified seconds from now.
* `callback(error)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`

##### Example
<pre class="highlight"><code class="language-js">
db.set('test', "Value", function(error) {
});

// Set a record in a specific database
db.set('test', "Value", {database: "test.kct"}, function(error) {
  // error -> undefined
});

// Set the record to expire in one minute
db.set('test', "Value", {expiry: 60}, function(error) {
});

// Set the record to expire on 1 Jan 2020
var expires = new Date("1 Jan 2020");
db.set('test', "Value", {expiry: expires}, function(error) {
});
</code></pre>

<a name="add"></a>
#### ◆ add `add(key, value, [options], callback)`

Set value of a record. Returns an error if the record already exists.

* `key` [String] -- The key of the record
* `value` -- [String] or [Buffer] -- The value of the record
* `options` [Object] -- Options hash
  * `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, output)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Key-value pairs

##### Example
<pre class="highlight"><code class="language-js">
db.add('test', "Value", function(error, output) {
  // error -> undefined
});

// when value already exists
db.add('test', "Value", function(error, output) {
  db.add('test', "Value", function(error, output) {
    // error  -> Error("Record exists")
    // output -> { ERROR: 'DB: 6: record duplication: record duplication' }
  });
});
</code></pre>

<a name="replace"></a>
#### ◆ replace `replace(key, value, [options], callback)`

Replace the value of a record. Returns an error if the record does not exist.

* `key` [String] -- The key of the record
* `value` -- [String] or [Buffer] -- The value of the record
* `options` [Object] -- Options hash
  * `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, output)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Key-value pairs

##### Example
<pre class="highlight"><code class="language-js">
db.set('test', "Test", function(error, output) {
  db.replace('test', "Value", function(error, output) {
    // error  -> undefined
    // output -> {}
  });
});

// when the record doesn't exist
db.replace('test', "Value", function(error, output) {
  // error  -> Error("Record does not exist")
  // output -> { ERROR: 'DB: 7: no record: no record' }
});
</code></pre>

<a name="append"></a>
#### ◆ append `append(key, value, [options], callback)`

Append to the value of a record. Sets the record if it does not exist.

* `key` [String] -- The key of the record
* `value` -- [String] or [Buffer] -- The value to append to the record
* `options` [Object] -- Options hash
  * `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, output)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Key-value pairs

##### Example
<pre class="highlight"><code class="language-js">
db.set('test', "Test", function(error, output) {
  db.append('test', " Value", function(error, output) {
    // error  -> undefined
    // output -> {}
    db.get('test', function(error, value) {
      // value -> 'Test Value'
    })
  });
});

// when the record doesn't exist
db.append('test', "Value", function(error, output) {
  // error  -> Error("Record does not exist")
  // output -> {}
  db.get('test', function(error, value) {
    // value -> 'Value'
  })
});
</code></pre>

<a name="increment"></a>
#### ◆ increment `increment(key, num, [options], callback)`

Increment the integer value of a compatible record. Sets the record if it does
not exist.

**Note:** It appears that Kyoto Tycoon only allows records that were created
with `increment` to be incremented. Attempts to use this procedure on records
set by other means results in an error (Kyoto Tycoon 0.9.29 (2.1) on Mac OS X
(Kyoto Cabinet 1.2.39)).

* `key` [String] -- The key of the record
* `num` -- [Number] -- The amount to increment the record by. Should be a positive or negative integer.
* `options` [Object] -- Options hash
  * `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, output)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Result from the server
    * `num` -- the new value of the record

##### Example
<pre class="highlight"><code class="language-js">
db.increment('count', 1, function(error, output) {
  // error  -> undefined
  // output -> { num: '1' }
  db.increment('count', 1, function(error, output) {
    // error  -> undefined
    // output -> { num: '2' }
  });
});

// incrementing an incompatible record
db.set('incompatible', "1", function(error, output) {
  db.increment('incompatible', 1, function(error, output) {
    // error  -> Error("The existing record was not compatible")
    // output -> { ERROR: 'DB: 8: logical inconsistency: logical inconsistency' }
  });
});
</code></pre>

<a name="increment_double"></a>
#### ◆ incrementDouble `incrementDouble(key, num, [options], callback)`

Increment the double (floating point) value of a compatible record.
Sets the record if it does not exist.

See note about compatible values in [increment].

[increment]: #increment

* `key` [String] -- The key of the record
* `num` -- [Number] -- The amount to increment the record by. Can be positive or negative.
* `options` [Object] -- Options hash
  * `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, output)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Result from the server
    * `num` -- the new value of the record

##### Example
<pre class="highlight"><code class="language-js">
db.incrementDouble('count', 1.5, function(error, output) {
  // error  -> undefined
  // output -> { num: '1.500000' }
  db.incrementDouble('count', -0.25, function(error, output) {
    // error  -> undefined
    // output -> { num: '1.250000' }
  });
});

// incrementing an incompatible record
db.set('incompatible', "1", function(error, output) {
  db.incrementDouble('incompatible', 1, function(error, output) {
    // error  -> Error("The existing record was not compatible")
    // output -> { ERROR: 'DB: 8: logical inconsistency: logical inconsistency' }
  });
});
</code></pre>

<a name="cas"></a>
#### ◆ cas `cas(key, oval, nval, [options], callback)`

Performs a compare-and-swap operation. The value is only updated if the
assumed existing value matches.

* `key` [String] -- The key of the record
* `oval` -- [String] or [Buffer] -- The assumed old value. Set to `null` if the
  record does not currently have a value.
* `nval` -- [String] or [Buffer] -- The new value. Set to `null` to remove the
  record.
* `options` [Object] -- Options hash
  * `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, output)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Key-value pairs

##### Example
<pre class="highlight"><code class="language-js">
// sets the new value when the old value matches
db.set('test', 'old', function() {
  db.cas('test', 'old', 'new', function(error, output) {
    db.get('test', function(error, value) {
      // value -> 'new'
    });
  });
});

// doesn't set the new value when the old value differs
db.set('test', 'old', function() {
  db.cas('test', 'not old', 'new', function(error, output) {
    db.get('test', function(error, value) {
      // value -> 'old'
    });
  });
});

// removes the record when the new value is null
db.set('test', 'old', function() {
  db.cas('test', 'old', null, function(error, output) {
    db.get('test', function(error, value) {
      // value -> null
    });
  });
});
</code></pre>

<a name="remove"></a>
#### ◆ remove `remove(key, [options], callback)`

Removes a record.

* `key` [String] -- The key of the record to remove
* `options` [Object] -- Options hash
  * `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error)` [Function] -- Callback function
  * `error` [Error] -- `undefined` if the record was successfully removed.

##### Example
<pre class="highlight"><code class="language-js">
db.set('test', "Value", function() {
  db.remove('test', function(error) {
    // error -> undefined
  });
});

// Non-existent record
db.remove('non-existent', function(error) {
  // error -> Error("Record not found")
});
</code></pre>

<a name="get"></a>
#### ◆ get `get(key, [options], callback)`

Get the value of a record. Returns `null` if the record doesn't exist.

* `key` [String] -- The key of the record
* `options` [Object] -- Options hash
  * `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, value, expires)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `value` [Buffer] -- The value of the record
  * `expires` [Date] -- The date the record expires if set, otherwise `null`.

##### Example
<pre class="highlight"><code class="language-js">
db.set('test', "Value", function(error, output) {
  db.get('test', function(error, value) {
    // error  -> undefined
    // value  -> Buffer("Value")
  });
});

// Non-existent record
db.get('not here', function(error, value) {
  // error  -> undefined
  // value  -> null
});

// Record with an expiry date
db.set('key', "Will Expire", {expiry: 60}, function(error) {
  db.get('key', function(error, value, expires) {
    // error   -> undefined
    // value   -> "Will Expire"
    // expires -> Date(now + 60 seconds)
  });
});
</code></pre>

<a name="exists"></a>
#### ◆ exists `exists(key, [options], callback)`

Checks if a record with the specified key exists. Returns true if it does,
false otherwise.

* `key` [String] -- The key of the record
* `options` [Object] -- Options hash
  * `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, result)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `result` [Boolean] -- `true` if the record exists, `false` otherwise

##### Example
<pre class="highlight"><code class="language-js">
db.set('test', "Value", function(error, output) {
  db.exists('test', function(error, result) {
    // error  -> undefined
    // result -> true
  });
});

// Non-existent record
db.exists('not here', function(error, result) {
  // error  -> undefined
  // result -> false
});
</code></pre>

<a name="set_bulk"></a>
#### ◆ setBulk `setBulk(records, [options], callback)`

Set multiple records at once.

* `records` [Object] -- The records to set with keys and values set appropriately.
* `options` [Object] -- Options hash
  * `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, output)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Result from the server
    * `num` -- The number of records set

##### Example
<pre class="highlight"><code class="language-js">
var records = {
  bulk1: "Bulk\tValue",
  bulk2: "Bulk Value 2"
};
db.setBulk(records, function(error, output) {
  // output -> {num: '2'}
});
</code></pre>

<a name="remove_bulk"></a>
#### ◆ removeBulk `removeBulk(keys, [options], callback)`

Remove multiple records at once.

* `keys` [Array] -- An array of keys to remove
* `options` [Object] -- Options hash
  * `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, output)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Result from the server
    * `num` -- The number of records removed

##### Example
<pre class="highlight"><code class="language-js">
var records = {
  bulk1: "Bulk\tValue",
  bulk2: "Bulk Value 2"
};
db.setBulk(records, function(error, output) {
  db.removeBulk(Object.keys(records), function(error, output) {
    // output -> {num: '2'}
  })
});
</code></pre>

<a name="get_bulk"></a>
#### ◆ getBulk `getBulk(keys, [options], callback)`

Retrieve multiple records at once.

* `keys` [Array] -- An array of keys to retrieve
* `options` [Object] -- Options hash
  * `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, results)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `results` [Object] -- The values for each of the requested keys by key. Where a record
    doesn't exist for a key that key is absent from from the results object.

##### Example
<pre class="highlight"><code class="language-js">
db.set('bulk1', "Bulk\tValue", function () {
  db.set('bulk2', "Bulk Value 2", function() {
    db.getBulk(['bulk1', 'bulk2', 'bulk3'], function(error, results) {
      // error   -> undefined
      // results -> { bulk1: 'Bulk\tValue', bulk2: 'Bulk Value 2' }
    });
  });
});
</code></pre>

<a name="vacuum"></a>
#### ◆ vacuum `vacuum()`

Not yet implemented.

<a name="match_prefix"></a>
#### ◆ matchPrefix `matchPrefix(prefix, [max], [options], callback)`

Returns keys matching the supplied prefix.

**Note:** if 3 arguments are supplied they are assumed to be `prefix`, `max`
and `callback`.

* `prefix` [String] -- The prefix to match keys against
* `max` [Number] -- The maximum number of results to return. If null or less
  than 0 then no limit is applied.
* `options` [Object] -- Options hash
  * `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, results)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `results` [Array] -- The matching keys

##### Example
<pre class="highlight"><code class="language-js">
var records = {
  bulk1: "Bulk\tValue",
  bulk2: "Bulk Value 2",
  test: "Value",
  tulk: "Value"
};

db.setBulk(records, function(error, output) {
  db.matchprefix('bulk', function(error, output) {
    // output -> ['bulk1', 'bulk2']
  });
});

// with a limit
db.setBulk(this.records, function(error, output) {
  return db.matchPrefix('bulk', 1, function(error, output) {
    // output -> ['bulk1']
  });
});
</code></pre>

<a name="match_regex"></a>
#### ◆ matchRegex `matchRegex(regex, [max], [options], callback)`

Returns keys matching the supplied regular expression.

**Note:** if 3 arguments are supplied they are assumed to be `prefix`, `max`
and `callback`.

* `regex` [String] -- The regex to match keys against. **Note:** It isn't
  clear from the Kyoto Tycoon documentation what regular expression features
  are supported. It appears from some limited testing that character ranges
  (E.g. `[0-9]`), `'.'`, `'*'` are supported but not `'+'`.
* `max` [Number] -- The maximum number of results to return. If null or less
  than 0 then no limit is applied.
* `options` [Object] -- Options hash
  * `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, results)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `results` [Array] -- The matching keys

##### Example
<pre class="highlight"><code class="language-js">
var records = {
  bulk1: "Bulk\tValue",
  bulk2: "Bulk Value 2",
  test: "Value",
  tulk: "Value"
};

db.setBulk(records, function(error, output) {
  db.matchRegex('[0-9]', function(error, output) {
    // output -> ['bulk1', 'bulk2']
  });
});

// with a limit
db.setBulk(this.records, function(error, output) {
  return db.matchRegex('[0-9]', 1, function(error, output) {
    // output -> ['bulk1']
  });
});
</code></pre>

<a name="get_cursor"></a>
#### ◆ getCursor `getCursor([key], callback)`

Obtain a database cursor. A cursor allows you to scan forwards through the
records in the database.

**TODO:** This needs to be amended to accept a database

* `key` [String] -- The key to start scanning from.
* `callback(error, cursor)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `cursor` [Cursor] -- A cursor starting at `key`

##### Example
<pre class="highlight"><code class="language-js">
db.getCursor('bulk1', function(error, cursor) {
  cursor.get(function(error, output) {
    // output -> {key: 'bulk1', value: 'Some value'}
  });
});
</code></pre>

<a name="cursor"></a>
### Cursor

A cursor allows the records of the database to be traversed. Depending on the
type of database this will either be in order of insertion or order determined
by a hashing function. A `Cursor` object is retrieved via the [getCursor]
function.

[getCursor]: #get_cursor

<a name="cur_jump"></a>
#### ◆ jump `jump([key], [options], callback)`

Jump the cursor to the specified record or the first record if no key is
specified.

* `key` [String] -- The key to start scanning from. To start from the beginning
  specify `null`.
* `options` [Object] -- Options hash
  * `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, output)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Key-value pairs

##### Example
<pre class="highlight"><code class="language-js">
// Jump to first record
cursor.jump(function(error, output) {
});

// Jump to a specific record
cursor.jump('test', function(error, output) {
});
</code></pre>

<a name="cur_jump_back"></a>
#### ◆ jumpBack `jumpBack([key], [options], callback)`

Jump the cursor to the specified record or the last record if no key is
specified.

* `key` [String] -- The key to start scanning from.
* `options` [Object] -- Options hash
  * `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, value)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Key-value pairs

##### Example
<pre class="highlight"><code class="language-js">
// Jump to first record
cursor.jump(function(error, output) {
});

// Jump to a specific record
cursor.jump('test', function(error, output) {
});
</code></pre>

<a name="cur_step"></a>
#### ◆ step `step(callback)`

Steps the cursor to the next record.

* `callback(error, value)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Key-value pairs

##### Example
<pre class="highlight"><code class="language-js">
// Jump to first record
cursor.jump(function(error, output) {
  cursor.step(function(error, output) {
    // cursor is now on the second record
  });
});
</code></pre>

<a name="cur_step_back"></a>
#### ◆ stepBack `stepBack(callback)`

Steps the cursor to the previous record.

* `callback(error, value)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Key-value pairs

##### Example
<pre class="highlight"><code class="language-js">
// Jump to last record
cursor.jumpBack(function(error, output) {
  cursor.stepBack(function(error, output) {
    // cursor is now on the second last record
  });
});
</code></pre>

<a name="cur_set_value"></a>
#### ◆ setValue `setValue(value, [step], callback)`

Sets the value of the current record and optionally steps to the next
record.

* `value` [String] or [Buffer] -- The new value for the record
* `step` [Boolean] -- When `true` step the cursor to the next record
* `callback(error, value)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Cursor] -- Key-value pairs

##### Example
<pre class="highlight"><code class="language-js">
cursor.setValue("New Value", function(error, output) {
  // value updated
});

// set and step
cursor.setValue("New Value", true, function(error, output) {
  // value updated
});
</code></pre>

<a name="cur_remove"></a>
#### ◆ remove `remove(callback)`

Remove the current record.

* `callback(error, value)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Key-value pairs

##### Example
<pre class="highlight"><code class="language-js">
cursor.remove(function(error, output) {
});
</code></pre>

<a name="cur_get_key"></a>
#### ◆ getKey `getKey([step], callback)`

Get the key of the current record.

* `step` [Boolean] -- When `true` step the cursor to the next record.
* `callback(error, value)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Result from the server
    * `key` -- The key of the current record. Absent if the cursor has stepped
      past the last record.

##### Example
<pre class="highlight"><code class="language-js">
cursor.getKey(true, function(error, output) {
  // output -> {key: 'test'}
});
</code></pre>

<a name="cur_get_value"></a>
#### ◆ getValue `getValue([step], callback)`

Get the value of the current record.

* `step` [Boolean] -- When `true` step the cursor to the next record.
* `callback(error, value)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Result from the server
    * `value` -- The value of the current record. Absent if the cursor has stepped
      past the last record.

##### Example
<pre class="highlight"><code class="language-js">
cursor.getValue(true, function(error, output) {
  // output -> {value: "Value"}
});
</code></pre>

<a name="cur_get"></a>
#### ◆ get `get([step], callback)`

Get the key and value of the current record.

* `step` [Boolean] -- When `true` step the cursor to the next record.
* `callback(error, value)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Result from the server, empty if the cursor has
    stepped past the last record.
    * `key` -- The key of the current record
    * `value` -- The value of the current record

##### Example
<pre class="highlight"><code class="language-js">
cursor.get(true, function(error, output) {
  // output -> {key: 'test', value: "Value"}
});
</code></pre>

<a name="cur_delete"></a>
#### ◆ delete `delete(callback)`

Close the cursor's connection, invalidating it. It will not be valid for
subsequent operations.

**Note:** `delete` is a reserved word so the syntax for calling this procedure
is a little awkward. Refer to examples.

* `callback(error)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`

##### Example
<pre class="highlight"><code class="language-js">
cursor["delete"](true, function(error, output) {
  // deleted
});
</code></pre>

##### CoffeeScript Example

<pre class="highlight"><code class="language-coffeescript">
cursor.delete true, (error, output) ->
  // deleted
</code></pre>

<a name="cur_each"></a>
#### ◆ each `each(callback)`

Scan the cursor forward from its current record to the last record.

TODO: Add support for cancelling the traversal.

* `callback(error, output)` [Function] -- Callback function, called for each
  record.
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Contains `key` and `value` properties for the key and
    value of the record respectfully. With be an empty object when the last
    record has been reached. The callback is only called once with this empty
    object.

##### Example
<pre class="highlight"><code class="language-js">
var results = [];

cursor.each(function(error, output) {
  if (output.key != null) {
    results.push([output.key, output.value]);
  } else {
    console.log(require('util').inspect(results));
  }
});
</code></pre>

[Array]: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Array
[Boolean]: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Boolean
[Buffer]: http://nodejs.org/docs/v0.2.6/api.html#buffers-2
[Cursor]: #cursor
[Date]: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Date
[Error]: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Error
[Function]: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Function
[Number]: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Number
[Object]: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Object
[String]: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/String

<a name="related"></a>
Related Projects
---------

<a name="connect-kyoto"></a>
### connect-kyoto

[connect-kyoto] allows Kyoto Tycoon to be used as a session store for
[connect].

[connect-kyoto]: https://github.com/wezm/connect-kyoto
[connect]: http://senchalabs.github.com/connect/

<a name="changelog"></a>
Changelog
---------

<a name="0.3.0"></a>
### 0.3.0 -- <time datetime="2011-04-25">25 Apr 2011</time>

* Require a default database to be specified to new
* Change database argument to be specified via an options hash
* Support for record expiry in `set` and `get`

<a name="0.2.0"></a>
### 0.2.0 -- <time datetime="2011-03-05">5 Mar 2011</time>

* node 0.4 compatibility (no longer compatible with 0.2)
* Handle base64 encoded responses
* Add [db.exists](#exists)
* Fix and test support for database argument to API calls
* Fix encoding issues surrounding the use of escape/unescape by replacing them
  with encodeURIComponent/decodeURIComponent.

<a name="0.1.1"></a>
### 0.1.1 -- <time datetime="2011-02-09">9 Feb 2011</time>

Some last  minute documentation additions.

<a name="0.1.0"></a>
### 0.1.0 -- <time datetime="2011-02-09">9 Feb 2011</time>

Initial release.

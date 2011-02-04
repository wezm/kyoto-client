---
title: kyoto-client - Kyoto Tycoon client for node.js
---

<h1><span id="logo"></span> kyoto-client -- Kyoto Tycoon client for node.js</h1>

<a name="intro"></a>
Introduction
------------

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

<a name="development"></a>
Development
------------

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
#### ◆ constructor `new()`

The constructor takes no arguments and returns a DB object.

##### Example
<pre class="highlight"><code class="language-js">var kt = require('kyoto-client');
var db = new kt.Db();
</code></pre>

<a name="open"></a>
#### ◆ open `open(hostname='localhost', port=1978)`

Open a connection to the database.

* `hostname` [String] -- The hostname of the database.
* `port` [Number] -- The port to connect to on the host.

##### Example
<pre class="highlight"><code class="language-js">db.open();

// on a different host
db.open('kyoto.example.com');
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
#### ◆ status `status([database], callback)`

Get the miscellaneous status information about a database.

* `database` [String] or [Number] -- A database name or index. For example: `test.kct` or `1`.
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
</code></pre>

<a name="clear"></a>
#### ◆ clear `clear([database], callback)`

Remove all records from the database.

* `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, output)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Key-value pairs

##### Example
<pre class="highlight"><code class="language-js">
db.clear(function(error, output) {
  // output -> {}
});
</code></pre>

<a name="synchronize"></a>
#### ◆ synchronize

Synchronize updated contents with the file and the device

Not yet implemented.

<a name="set"></a>
#### ◆ set `set(key, value, [database], callback)`

Set value of a record.

* `key` [String] -- The key of the record
* `value` -- [String] or [Buffer] -- The value of the record
* `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`

##### Example
<pre class="highlight"><code class="language-js">
db.set('test', "Value", function(error) {
});
</code></pre>

<a name="add"></a>
#### ◆ add `add(key, value, [database], callback)`

Set value of a record. Returns an error if the record already exists.

* `key` [String] -- The key of the record
* `value` -- [String] or [Buffer] -- The value of the record
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
#### ◆ replace `replace(key, value, [database], callback)`

Replace the value of a record. Returns an error if the record does not exist.

* `key` [String] -- The key of the record
* `value` -- [String] or [Buffer] -- The value of the record
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
#### ◆ append `append(key, value, [database], callback)`

Append to the value of a record. Sets the record if it does not exist.

* `key` [String] -- The key of the record
* `value` -- [String] or [Buffer] -- The value to append to the record
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
#### ◆ increment `increment(key, num, [database], callback)`

Increment the integer value of a compatible record. Sets the record if it does
not exist.

**Note:** It appears that Kyoto Tycoon only allows records that were created
with `increment` to be incremented. Attempts to use this procedure on records
set by other means results in an error (Kyoto Tycoon 0.9.29 (2.1) on Mac OS X
(Kyoto Cabinet 1.2.39)).

* `key` [String] -- The key of the record
* `num` -- [Number] -- The amount to increment the record by. Should be a positive or negative integer.
* `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, output)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Key-value pairs

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
#### ◆ incrementDouble `incrementDouble(key, num, [database], callback)`

Increment the double (floating point) value of a compatible record.
Sets the record if it does not exist.

See note about compatible values in [increment].

[increment]: #increment

* `key` [String] -- The key of the record
* `num` -- [Number] -- The amount to increment the record by. Can be positive or negative.
* `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, output)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Object] -- Key-value pairs

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
#### ◆ cas `cas(key, oval, nval, [database], callback)`

Performs a compare-and-swap operation. The value is only updated if the 
assumed existing value matches.

* `key` [String] -- The key of the record
* `oval` -- [String] or [Buffer] -- The assumed old value
* `nval` -- [String] or [Buffer] -- The new value. Set to `null` to remove the
  record.
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
      // value ➞ 'new'
    });
  });
});

// doesn't set the new value when the old value differs
db.set('test', 'old', function() {
  db.cas('test', 'not old', 'new', function(error, output) {
    db.get('test', function(error, value) {
      // value ➞ 'old'
    });
  });
});

// removes the record when the new value is null
db.set('test', 'old', function() {
  db.cas('test', 'old', null, function(error, output) {
    db.get('test', function(error, value) {
      // value ➞ null
    });
  });
});
</code></pre>



<a name="remove"></a>
#### ◆ remove `remove()`

TODO

<a name="get"></a>
#### ◆ get `get(key, [database], callback)`

Get the value of a record. Returns `null` if the record doesn't exist.

* `key` [String] -- The key of the record
* `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, value)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `value` [Buffer] -- The value of the record

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
</code></pre>

<a name="set_bulk"></a>
#### ◆ setBulk `setBulk()`

TODO

<a name="removeBulk"></a>
#### ◆ removeBulk `removeBulk()`

TODO

<a name="getBulk"></a>
#### ◆ getBulk `getBulk(keys, [database], callback)`

Retrieve multiple records at once.

* `keys` [Array] -- An array of keys to retrieve
* `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, value)` [Function] -- Callback function
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

TOOD

<a name="matchPrefix"></a>
#### ◆ matchPrefix `matchPrefix()`

TODO

<a name="matchRegex"></a>
#### ◆ matchRegex `matchRegex()`

TODO

<a name="get_cursor"></a>
#### ◆ getCursor `getCursor([key], callback)`

Obtain a database cursor. A cursor allows you to scan forwards through the
records in the database.

**TODO:** This needs to be amended to accept a database

* `key` [String] -- The key to start scanning from.
<!-- * `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`. -->
* `callback(error, value)` [Function] -- Callback function
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
#### ◆ jump `jump([key], [database], callback)`

Jump the cursor to the specified record or the first record if no key is
specified.

* `key` [String] -- The key to start scanning from.
* `database` [String] or [Number] -- A database name or index. For example: `'test.kct'` or `1`.
* `callback(error, value)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Cursor] -- Key-value pairs

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
#### ◆ jumpBack `jumpBack([key], [database], callback)`

Jump the cursor to the specified record or the last record if no key is
specified.

TODO

<a name="cur_step"></a>
#### ◆ step `step()`



<a name="cur_stepBack"></a>
#### ◆ stepBack `stepBack()`

<a name="cur_setValue"></a>
#### ◆ setValue `setValue()`

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

<a name="cur_getKey"></a>
#### ◆ getKey `getKey()`

<a name="cur_getValue"></a>
#### ◆ getValue `getValue()`

<a name="cur_get"></a>
#### ◆ get `get([step], callback)`

Get the key and value of the current record.

* `step` [Boolean] -- When `true` step the cursor to the next record.
* `callback(error, value)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Cursor] -- Key-value pairs

##### Example
<pre class="highlight"><code class="language-js">
cursor.get(true, function(error, output) {
  // output -> {key: 'test', value: "Value"}
});
</code></pre>

<a name="cur_delete"></a>
#### ◆ delete `delete(callback)`

Close the cursor's connection invalidate it. it will not be valid for
subsequent operations.

**Note:** `delete` is a reserved word so the syntax for calling this procedure
is a little awkward. Refer to examples.

* `callback(error, value)` [Function] -- Callback function
  * `error` [Error] -- Set if an error occurs, otherwise `undefined`
  * `output` [Cursor] -- Key-value pairs

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
[Error]: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Error
[Function]: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Function
[Number]: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Number
[Object]: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Object
[String]: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/String

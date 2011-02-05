kyoto-client
============

kyoto-client is a [node.js][node] module that acts as a client to a [Kyoto
Tycoon][kyoto] server. Kyoto Tycoon is the server component of [Kyoto
Cabinet][cabinet], a fast, efficient key-value store developed by [FAL
labs][fallabs]. Records can be stored on disk or in memory using a hash table
or B+ tree.

[node]: http://nodejs.org/
[kyoto]: http://fallabs.com/kyototycoon/
[cabinet]: http://fallabs.com/kyotocabinet/
[fallabs]: http://fallabs.com/

Installing
----------

Installation via [npm] is recommended:

    npm install kyoto-client

[npm]: http://npmjs.org/

You will of course also need a running Kyoto Tycoon server. Kyoto Tycoon is
available via [MacPorts], [Homebrew] on Mac OS X but for other systems (such
as Debian and Ubuntu) it doesn't appear to be packaged so you will need to
build from source.

[MacPorts]: http://www.macports.org/ports.php?by=name&substr=kyototycoon
[Homebrew]: https://github.com/mxcl/homebrew/blob/master/Library/Formula/kyoto-tycoon.rb

Documentation and Examples
--------------------------

Refer to the [kyoto-client homepage][home] for full API details and examples.

[home]: http://kyoto-client.org/

Development
-----------

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
in the [issue tracker][issues].

[coffee]: http://jashkenas.github.com/coffee-script/
[nodeunit]: https://github.com/caolan/nodeunit
[issues]: https://github.com/wezm/kyoto-client/issues

Contributors
------------

* [Wesley Moore](https://github.com/wezm)

# session-multi

The lifetime of a `Rack::Session` is set during initialization and is fixed to
the same value for every client.  This middleware adds the ability to specify a
longer session lifetime for requests originating from a given client ip.

A cookie based session is used for maximum persistence.
The expiry time is stored in the rack session hash using the key `:_expires` 

### Options

* `:expire_after`: session lifetime in seconds (replaces the Rack::Session option with the same name)
* `:factor`: a multiplier for `:expire_after` to calculate the lifetime of sessions originating from `:eternal_client`
* `:eternal_client`: ip of the client that needs a long lived session

And the Rack::Session options, which are passed unmodified, except `:expire_after`.

### Example deployment via config.ru

```ruby

require_relative 'myapp'
require_relative 'lib/session_multi'

use SessionMulti, factor: 100,
                  expire_after: 14400,
                  eternal_client: '127.0.0.1',
                  secret: 'mylittlesecret'

run MyApp

```


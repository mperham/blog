---
author: Mike Perham
categories:
- Ruby
date: 2010-02-09T00:00:00Z
title: Cassandra and EventMachine
url: /2010/02/09/cassandra-and-eventmachine/
---

I spent this past weekend adding eventmachine support for the Cassandra gem. We're using Cassandra at [OneSpot][1] as our next-gen data store and need EM support. They were nice enough to pull my changes yesterday so the next release of the `thrift_client` and `cassandra` gems should work in EM. You just need to do this:

```ruby
require 'thrift_client/event_machine'
EM.run do
  Fiber.new do
    @twitter = Cassandra.new('Twitter', "127.0.0.1:9160", :transport => Thrift::EventMachineTransport, :transport_wrapper => nil)
    @twitter.clear_keyspace!
    EM.stop
  end.resume
end
```

The key is the `:transport` and `:transport_wrapper` options which override the default, Socket-based implementation. Like all of my EventMachine code, this requires Ruby 1.9.

 [1]: http://www.onespot.com

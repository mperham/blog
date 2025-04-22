---
author: Mike Perham
date: 2015-05-08T00:00:00Z
title: 'Timeout: Ruby''s Most Dangerous API'
url: /2015/05/08/timeout-rubys-most-dangerous-api/
---

In the last 3 months, I've worked with a half dozen Sidekiq users plagued with mysterious stability problems.
All were caused by the same thing: Ruby's terrible `Timeout` module.  I strongly urge everyone reading
this to remove any usage of `Timeout` from your codebase; odds are very good you will see an increase
in stability.

<figure style="float:right">
  <img src="/wp-content/uploads/2015/05/using-timeout.jpg" width="419">
  <figcaption style="text-align: right"><i>You, using Timeout.</i></figcaption>
</figure>

You might think I'm overreacting or hyping up the problem: I'm not.  Here's Charles Nutter, lead developer
of JRuby, writing about how [Timeout is fundamentally broken](http://blog.headius.com/2008/02/rubys-threadraise-threadkill-timeoutrb.html)
and cannot be used safely **in 2008**.

### The Problem

Timeout is typically used to ensure a block of code executes within a given time.  It does this by
raising an error within the Thread executing that block.  Relevant to Sidekiq: this will corrupt
shared network connections.  Imagine this sequence of events:

1. Code makes request A to Redis
1. Timeout triggers, block stops executing
1. Redis connection is returned to connection pool
1. Network receives response A for request A
1. Code checks out same connection and makes request B
1. Code reads response A instead of waiting for response B!

That shared Redis connection has been corrupted due to Timeout skipping response A handling.

### The Solution

The only safe timeouts to use are lower-level network timeouts.  The underlying operating system
understands them and ensures everything is cleaned up properly.  All good network APIs will expose
those timeouts so you can set them in your application code.  Here's a few examples:

```ruby
# Sidekiq's redis connection pool
Sidekiq.configure_server do |config|
  config.redis = { :network_timeout => 2, :url => 'redis://localhost:3970/12' }
end
```

```ruby
# Generic redis-rb
$redis = Redis.new(:url => '...', :connect_timeout => 5, :timeout => 5)
```

```ruby
# Dalli
$memcached = Dalli::Client.new('...', :socket_timeout => 5)
```

```ruby
# Net::HTTP
Net::HTTP.start(host, port, :open_timeout => 5, :read_timeout => 5) do |http|
  http.request(...)
end
```

If your favorite network library does not document its timeout options, be a sport
and open a new issue or send them a PR with updated documentation.  I just did that for
[Redis](https://github.com/redis/redis-rb/pull/528).


### Conclusion

Ruby's `Timeout` is a giant hammer and will only lead to a big mess.  Don't use it.

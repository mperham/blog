---
title: "Ruby HTTP Server from scratch"
date: 2023-09-11T12:27:34-07:00
publishdate: 2023-09-11
lastmod: 2023-09-11
tags: []
---

Recently I decided to add support for Kubernetes HTTP health checks to Sidekiq Enterprise.
This means, within each Sidekiq worker process, we need to implement an HTTP server which listens on port X and simply returns 200/OK if the process is alive.

Notice we have really basic requirements here: no need for serving files or arbitrary dynamic content.
We only respond to "/" so there's no need for routes, paths or query parameter handling.
Because the health check should only be used within private networking, we have no need for TLS or https support.

I didn't want to bring in a dependency on Puma, Thin or some other "big" Ruby HTTP server.
How can we implement this with only Ruby's standard library?

## Our foundation: `gserver`

Unless you've been programming Ruby for a long time, you've probably never heard of Ruby's Generic Server.
[`gserver`](https://github.com/ruby/gserver) is a Rubygem which is part of Ruby's standard library and provides a generic, multithreaded TCP server.

```ruby
class TimeServer < GServer
  def initialize(port=10001, *args)
    super(port, *args)
  end
  def serve(io)
    io.puts(Time.now.to_i)
  end
end

# Run the server with logging enabled (it's a separate thread).
server = TimeServer.new
server.audit = true                  # Turn logging on.
server.start
```

## Adding some spicy HTTP sauce

The `gserver` API provides low-level socket handling but doesn't know anything about higher-level protocols.
They provide a [sample HTTP layer](https://github.com/ruby/gserver/blob/master/sample/xmlrpc.rb) which implements just enough HTTP support on top of `gserver` for our needs.
The low-level `serve(io)` method becomes a higher-level `request_handler(request, response)` method.
Perfect.

## Implementing our Service

Now that we have a low-level TCP server layer and added an HTTP layer on top of that, we can implement our 
request handler:

```ruby
require 'gserver'
# require "sample/xmlrpc"
class HealthCheck < ::HttpServer
  def initialize(port=8080)
    super self, port
  end

  def ip_auth_handler(*)
    # no need for authn/authz
    true
  end

  def request_handler(req, res)
    return res.status = 404 unless req.path == "/"

    # gather and respond with a JSON payload
  end
end
```

`gserver` provides a really useful and well tested foundation for Ruby-based TCP network services.
The gserver core and sample HTTP layer sum to less than 500 lines of code
while Sidekiq's health check HTTP service weighs in at just ~50 lines of code.
We have no dependency on any native extensions or "large" server packages, only Ruby's standard library.
If we ever have a bug, we can easily vendor the code and fix the issue ourselves.

The result looks like this:

```sh
% curl http://localhost:7001/ 
{"rss":"128112","beat":"1694463266.440371","quiet":"false","rtt_us":"154","busy":"0","info":{"hostname":"Mikes-MacBook-Pro.local","started_at":1694463256.3649879,"pid":38478,"tag":"myapp","concurrency":5,"queues":["default"],"weights":[{"default":0}],"labels":["reliable"],"identity":"Mikes-MacBook-Pro.local:38478:7e34c0f1f40c","version":"7.1.3","embedded":false}}
```

This functionality is now available in Sidekiq Enterprise 7.1.2.
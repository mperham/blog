---
author: Mike Perham
date: 2016-06-14T00:00:00Z
title: Test Driving Sidekiq and Crystal
url: /2016/06/14/test-driving-sidekiq-and-crystal/
---

It's alive!  I've finished the initial port of the three core pieces of Sidekiq, the
client API, the job execution engine and the Web UI, to
[Crystal](http://crystal-lang.org).  Let's
assume we have a Ruby app using Sidekiq.rb and integrate Sidekiq.cr to run
beside it.

<figure style="float: right;">
  <a href="http://crystal-lang.org"><img style="border: solid white 0px;" src="http://crystal-lang.org/images/icon.png" width="200px" /></a>
</figure>
<figure style="float: right;">
  <a href="http://sidekiq.org"><img style="border: solid white 0px;" src="http://sidekiq.org/assets/kicker.svg" width="200px" /></a>
</figure>


## Getting Started

Sidekiq.cr has a [Getting Started](https://github.com/mperham/sidekiq.cr/wiki/Getting-Started) wiki page which
walks you through the basics of setting up a new Crystal app.  Follow
those directions.  Once complete, you should have a Worker named `Sample::MyWorker`
that we can call.  We're going to build the Sidekiq.cr binary and run it
with `./sidekiq -q crystal`.  Sidekiq.cr is now listening for jobs on
the `crystal` queue only.  Any Ruby-based jobs should use other queues
so the Crystal worker will never see them - exactly what we want.

We've defined one Worker in the Crystal app:

```ruby
module Sample
  class MyWorker
    include Sidekiq::Worker

    def perform(name : String, count : Int64)
      count.times do
        logger.info "Hello, #{name}!"
      end
    end
  end
end
```

Open up an IRB console and run this:

```ruby
require "sidekiq"
Sidekiq::Client.push("class" => "Sample::MyWorker", "args" => ["Ruby", 3], "queue" => "crystal")
```

Immediately you should see Sidekiq.cr print out three lines:

```
2016-06-13T21:03:21.676Z 3936 TID-223icg0 JID=896704d437d398abdf13eb06 INFO: Start
2016-06-13T21:03:21.676Z 3936 TID-223icg0 JID=896704d437d398abdf13eb06 INFO: Hello, Ruby!
2016-06-13T21:03:21.676Z 3936 TID-223icg0 JID=896704d437d398abdf13eb06 INFO: Hello, Ruby!
2016-06-13T21:03:21.676Z 3936 TID-223icg0 JID=896704d437d398abdf13eb06 INFO: Hello, Ruby!
2016-06-13T21:03:21.676Z 3936 TID-223icg0 JID=896704d437d398abdf13eb06 INFO: Done: 0.000121 sec
```

Nearly identical to Sidekiq.rb but look at that execution time: **121µs**!
In real world code, I'm seeing Crystal execute 5-10x faster than MRI.

So... got tons of little jobs?  Got compute-heavy jobs?  Crystal and
Sidekiq.cr might be the solution you're looking for!  Got questions?
Find a bug?  [Open an issue](https://github.com/mperham/sidekiq.cr/issues).

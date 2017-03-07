---
author: Mike Perham
categories:
- Rails
- Software
date: 2010-03-30T00:00:00Z
tags:
- eventmachine
title: Using ActiveRecord with EventMachine
url: /2010/03/30/using-activerecord-with-eventmachine/
---

Given all my work with Fibers and EventMachine over the last three months, it should come as no surprise that I've been working on infrastructure based on Fibers and EventMachine to get maximum scalability without the callback style of code which I dislike for many reasons. [Watch my talk on scaling with EventMachine][1] if you need more background on the problem.

Now that I have RabbitMQ, Cassandra, Solr and the Amazon AWS services evented, the only holdup was ActiveRecord. Some people may advocate using another ORM layer but when you have 2-3 other Rails apps, all sharing 100+ models, you can't afford to maintain two separate ORM layers. Plus, frankly I like the Rails stack: it works pretty well, is thoroughly documented and every Ruby developer is familiar with it.

So what do we need to do to get AR working event-style? At a high level, there's two things required:

*   The database driver itself must be modified to send SQL asynchronously. The postgresql driver, for instance, calls the `exec(sql)` method for all traffic to the database. So we just need to provide an exec method which uses Fibers under the covers to work asynchronously.
*   AR's connection pooling needs to be Fiber-safe. Out of the box, it is Thread-safe. Since we are using an execution model based on a single Thread with multiple Fibers, all the Fibers would try to use the same connection, with disastrous consequences.

These are the things that em_postgresql does.

*   [postgres_connection][2] is a basic, EM-aware Postgres driver. It provides the Fibered `exec()` method which makes the whole thing asynchronous. 
    *   [em\_postgresql\_adapter.rb][3] wraps postgres_connection to make it a proper ActiveRecord driver.
    *   [patches.rb][4] overrides a bunch of AR's internal connection pooling to make it Fiber-friendly.</ul> 
    Unfortunately the latter makes one hack necessary -- we have to have a list of current Fibers to release any lingering connections associated with those Fibers. The Threaded version can use `Thread.list` but Ruby does not provide an equivalent method for Fibers. Instead I require the application to register a FiberPool with AR to clear stale connections.
    
    So what does it all mean? Well, here's [a Sinatra application][5] that uses plain old ActiveRecord and **is completely asynchronous**! Try `ab -n 100 -c 20 http://localhost:9292/test` to hit the app with 20 concurrent connections; it will process them all in parallel, without any painful threading issues (autoloading, misbehaving extensions, etc). Awesome!
    
    You should guess what's next. Coming soon: the whole Rails stack, running asynchronously...

 [1]: /2010/01/27/scalable-ruby-processing-with-eventmachine/
 [2]: http://github.com/mperham/em_postgresql/blob/master/lib/postgres_connection.rb
 [3]: http://github.com/mperham/em_postgresql/blob/master/lib/active_record/connection_adapters/em_postgresql_adapter.rb
 [4]: http://github.com/mperham/em_postgresql/blob/master/lib/active_record/patches.rb
 [5]: http://github.com/mperham/em_postgresql/blob/master/examples/app.rb

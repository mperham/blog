---
author: Mike Perham
date: 2015-02-18T00:00:00Z
title: Sidekiq Pro 2.0!
url: /2015/02/18/sidekiq-pro-2.0/
---

<figure style="float:right">
  <img src="/wp-content/uploads/2015/02/sidekiq-pro.png" width="303" height="74"/>
</figure>

I'm happy to announce that **[Sidekiq Pro](http://sidekiq.org/pro)** 2.0 is ready for general use.  There's two major features
and some refactoring you need to know about.

### Batches

Sidekiq allows you to fire off a set of jobs to process asynchronously but you don't know when the whole set of jobs are complete:

![no job workflow](/wp-content/uploads/2015/02/sidekiq.png)

Sidekiq Pro provides the **Batch** abstraction, it represents a set of jobs; you can attach callbacks
to be fired when the set of jobs has finished.  This allows more complex job workflows:

![simple job workflow](/wp-content/uploads/2015/02/pro1.png)

For 2.0, the Batch implementation and data model was overhauled for higher performance, much smaller size
and **Batches can now be nested**: a job within a Batch can itself create a child Batch of jobs.  The callbacks for
the parent batch will only be fired once the child batch callbacks have finished.

![complex job workflow](/wp-content/uploads/2015/02/pro2.png)

This was some of the hardest code I've ever written (it requires a bag of buzzwords: asynchronous, distributed,
transactional, threadsafe and fast!) but I'm really proud of the outcome.  Sidekiq Pro should be
able to handle job workflows of any depth now.

As part of 2.0, the batch data model changed significantly but have no fear: existing 1.x batches will process as normal.

### Scheduler

Sidekiq's scheduler scans the scheduler set for jobs to perform.  Unfortunately the way it scans and enqueues jobs is not atomic.
There is a very very small but real chance a scheduled job could be lost.

For 2.0, I've written a Lua-based scheduler which is atomic and enqueues 50-100x faster than the existing scheduler since it does
not require any network round trips.  It's very easy to enable:

```ruby
Sidekiq.configure_server do |config|
  config.reliable_scheduler!
end
```

It's optional because it does require Redis 2.6.

### Miscellaneous Changes

* Various deprecated APIs were removed
* Reliability features are now enabled via methods, not `require`
```ruby
Sidekiq::Client.reliable_push!

Sidekiq.configure_server do |config|
  config.reliable_fetch!
end
```

## Conclusion

Here's the [Sidekiq Pro 2.0 Upgrade Notes](https://github.com/mperham/sidekiq/blob/master/Pro-2.0-Upgrade.md).
If you're not a Sidekiq Pro customer yet, [you can buy Sidekiq Pro here](http://sidekiq.org/).  Enjoy!

Diagrams courtesy of the very nifty [draw.io](http://draw.io).

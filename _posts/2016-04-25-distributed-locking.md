---
title: "Distributed Locking with Redis and Ruby"
author: Mike Perham
layout: post
permalink: /2016/04/25/distributed-locking/
published: true
---

<figure style="float: right;">
  <img style="border: solid white 0px;" src="/images/distributedlock.png" width="400px" />
</figure>

It can happen: sometimes you need to severely curtail access to a
resource.  Maybe you use a 3rd party API where you can only make one call at a
time.  To handle this extreme case, you need an extreme tool: a
distributed lock.

Distributed locks are dangerous: hold the lock for too long and your
system throughput plummets. They can easy become a major chokepoint for
your app's performance and scalability.

Recently a blog post talked about using Redis for
distributed locking with Sidekiq.  I tried the code and **it didn't even
work**. It did however give me the idea to test [Sidekiq Enterprise's Rate Limiting
API](https://github.com/mperham/sidekiq/wiki/Ent-Rate-Limiting), which provides a flexible "concurrent" limiter,
against other rubygems which provide a similar lock.

> **Please Note**: I'm not talking about [Redlock](http://redis.io/topics/distlock) and other algorithms that
provide fault-tolerant locking via distributed consensus.  Those
algorithms are slower and **much** harder to get correct; I would never trust
myself to write one (or anyone else that's not a Computer Science Ph.D).
In this post, I'm talking about using a single Redis instance to
coordinate many worker processes distributed across many machines.
This is sufficiently safe and robust for most businesses.

### The Setup

I tested four different distributed lock gems, including sidekiq-ent.
With any of them we can create a distributed lock which
ensures our system executes a block of code exclusively, even with dozens
of processes.  One thing to understand: **sidekiq-ent's Rate Limiting API does
not need to run within a Sidekiq process** - it can be used in any Ruby
process: puma, unicorn, passenger, sidekiq, etc.

All locking libraries provide similar semantics. You define:

 * how long should the code wait for the lock before giving up?
 * how long before the lock times out?

The lock has to have a timeout as that's the only way to recover from a
process crash while holding a lock.  Libraries "wait" in two different
ways: redis-semaphore and sidekiq-ent block, efficiently waiting to be
notified when they can take the lock, the other two gems poll regularly,
forcing an unfortunate tradeoff: polling more often means slamming Redis
with unnecessary work.

### The Test

I created a benchmark exercising all four APIs.
The code executes 100 "jobs" using 25 threads.  Each job sleeps for 0.1
sec while holding the lock, meaning that a perfect run will take 10.0
sec.  [Gist of the actual benchmark code here](https://gist.github.com/mperham/e0248bfb727ebf02ffd6b09172a85301).

    sidekiq-ent
      0.110000   0.100000   0.210000 ( 10.433794)
    redis-semaphore
      0.150000   0.150000   0.300000 ( 10.487963)
    pmckee11-redis-lock
      0.460000   0.550000   1.010000 ( 10.718958)
    ruby_redis_lock
      0.280000   0.250000   0.530000 ( 11.655952)

The third column shows you the number of seconds actually running on the
CPU; sidekiq-ent's limiter used 0.21 seconds of CPU time, the
others varied from 0.3 to 1.0 seconds.

The theoretical perfect runtime is 10 sec, 100 jobs * 0.1 sec sleep
so sidekiq-ent adds about 4% overhead.  The latter two gems added notably more overhead.
Note in the gist, I had to modify `pmckee11-redis-lock` to disable exponential
backoff, otherwise it would die with a timeout after several minutes.

### Metrics

Unfortunately the other three libraries give you no insight into actual lock usage while
sidekiq-ent's concurrent limiter offers real-time metrics so you can
understand how the lock is performing -- it can answer questions like:

 * how heavily is this lock contended?
 * is the lock ever timing out?
 * how often is the lock granted immediately vs forcing your code to wait?

You can read the [metric definitions in the wiki](https://github.com/mperham/sidekiq/wiki/Ent-Rate-Limiting#concurrent-metrics).  Here's the UI:

![Limiter Web UI](https://raw.githubusercontent.com/mperham/sidekiq/master/examples/ent-concurrent.png)

### What have we learned?

The other libraries give you the basics of a distributed lock but two
are lacking in performance and all are missing the metrics necessary to
debug problems.  Some good things about Sidekiq Enterprise's concurrent limiter:

 * it provides the highest performance distributed lock for Redis
 * it blocks, it does not poll or sleep, so it won't slam Redis with superfluous requests or burn CPU
 * it can limit access to N callers, not just 1
 * it provides much better visibility with real-time metrics about limiter usage

If you are using Sidekiq today, the Enterprise upgrade will drop right in.
[Sidekiq Enterprise starts at $1950/yr, get a quote in seconds here.](https://enterprise.contribsys.com/quote.html)


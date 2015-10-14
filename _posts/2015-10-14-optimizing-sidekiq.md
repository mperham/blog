---
title: "Optimizing Sidekiq"
author: Mike Perham
layout: post
permalink: /2015/10/14/optimizing-sidekiq
published: true
---

Sidekiq has a reputation for being much faster than its competition but
there's always room for improvement. I recently rewrote its internals
and made it **six times faster**.  Here's how!

<figure style="float: right;">
  <img style="border: solid white 10px;" src="http://cdn.shopify.com/s/files/1/0154/2777/products/Sidekiq_-_Detail_1024x1024.jpg" width="360px" />
</figure>

It's been quite a while since I've touched Sidekiq's core design.  That
was intentional: for the last year Sidekiq has stabilized and become
reliable infrastructure that Ruby developers can trust when
building their applications.  That didn't stop me from wondering though,
what would happen if I change this or tweak that?

Recently I decided to embark on an experiment: how hard would it be
to remove Celluloid?  Could I convert Sidekiq to use bare threads?
I like Celluloid and how much easier it makes concurrent programming but
it's also Sidekiq's largest dependency; as Celluloid changes, Sidekiq
must accomodate those changes.

## 1. Get a Baseline

First thing I did was write a [load testing script][0] to execute 100,000
no-op jobs so I could judge whether a change was effective or not.  The
script creates 100,000 jobs in Redis, boots Sidekiq with 25 worker threads
and then prints the current state every 2 seconds until the queue is
drained. This script ran in **125 seconds** on MRI 2.2.3.

## 2. Bare Threads

Once a baseline was established, I spent a few days porting Sidekiq's
core to use nothing but plain old Threads.  This wasn't easy but
after a few days I had a stable system and
the improvement was impressive: the load testing script now ran in **57
seconds**.  Every abstraction has a cost and benefit; Celluloid allows
you to reason about and build a concurrent system much quicker but does
have a small runtime cost.

## 3. Asynchronous Status

Once the rewritten core was stable and tests passing again, I ran `ruby-prof`
on the load testing script to see
if there was any low hanging fruit.  The profiler showed that the
processor threads were spending most of their time sending job status data to
Redis.  Sidekiq has 25 processor threads to execute jobs concurrently and each thread
called Redis at the start and finish of each job; you get precise status
but at the cost of two
network round trips.  To optimize this, I changed the
processor threads to update a global status structure in memory then
changed the process's heartbeat, which contacts Redis every few seconds,
to update the status as part of the heartbeat.  If Sidekiq is processing
1000 jobs/sec, this saves 1999 round trips!  Result?  The load testing
script ran in **20 seconds**.

## 4. Parallel Fetch

The last major change I made when I noticed that MRI was using 100% of
CPU and JRuby was using 150% during the script execution.  *Only 150%???*
I have four cores in this laptop; why isn't it using 300% or more?
I had a hunch: Sidekiq has always used a single Fetcher thread to
retrieve jobs from Redis one at a time.  To test my theory, I introduced 1ms of latency
into the Redis network connection using Shopify's nifty [Toxiproxy][2]
gadget and immediately the script execution time shot up to over five
minutes!  The processor threads were starving, waiting for that single
thread to deliver jobs to them one at a time over the slow network.

I refactored things to move the fetch code into the processor thread
itself.  Now all 25 processor threads will call Redis and block, waiting
for a job to appear.  This, along with the async status change, should
make Sidekiq much more resilient to Redis latency.  With fetch happening
in parallel, the script ran in **20 seconds** again, even with 1ms of latency.
JRuby 9000 uses >300% CPU now and processes 7000 jobs/sec!

## Bonus: Memory and Latency!

I also ran the script with GC disabled.  With no optimizations, Sidekiq
executed 10,000 jobs using 1257MB of memory.  With all optimizations,
Sidekiq executed the same number of jobs in 151MB of memory.  In other words, the
optimizations result in **8.3x less garbage**.

But that's not all!  I measured job execution latency before and after:
the time required for the client in one process to create a job, push it
to Redis, Sidekiq to pick it up and execute the worker.  Latency dropped
from 22ms to 10ms.

<style>
table {
  border-collapse: separate;
  border-spacing: 0;
  border: 1px solid #000;
}

th, td, caption {
  border: 1px solid #000;
  padding: 0.5em;
}
</style>
<table>
<tr><th>Version</th><th>Latency</th><th>Garbage created when<br/> processing 10,000 jobs</th><th>Time to process<br/> 100,000 jobs</th><th>Throughput</th></tr>
<tr><th>3.5.1</th><td>22ms</td><td>1257 MB</td><td>125 sec</td><td>800 job/sec</td></tr>
<tr><th>4.0.0</th><td>10ms</td><td>151 MB</td><td>22 sec</td><td>4500 jobs/sec</td></tr>
</table>
<small>Data collected with MRI 2.2.3 running on my MBP 13-inch w/ 2.8Ghz i7.</small>


## Drawbacks?

There are a few trade offs to consider with these changes:

- more Redis connections in use.  Previously only the single Fetcher
thread would block on Redis.  Now each processor thread will block
on Redis, meaning you **must** have more Redis connections than your
concurrency setting.  Sidekiq's default connection pool sizing of
(concurrency + 2) will work great.
- job status on the Busy tab in the Web UI isn't real-time when the page
renders, it may be delayed up to a few seconds
- Celluloid is no longer required by Sidekiq so if your application uses
it, you will need to pull it in and initialize it yourself

## Conclusion

Keep in mind what we are talking about: the overhead of executing no-op
jobs.  This overhead is dwarfed by application job execution time so
don't expect to see radical speedups in your own application jobs.  That
said, this dramatic lowering of job overhead is still a nice win for
all Sidekiq users, especially those with lots of very fast jobs.

This effort will become Sidekiq 4.0 coming later this Fall.  All of this
is made possible by sales of [Sidekiq Pro][3] and [Sidekiq Enterprise][4].
If you rely on Sidekiq every day, please upgrade and support my work.

See the [GitHub pull request][1] for all the gory detail.


[0]: https://github.com/mperham/sidekiq/blob/master/bin/sidekiqload
[1]: https://github.com/mperham/sidekiq/pull/2593
[2]: https://github.com/shopify/toxiproxy
[3]: http://sidekiq.org
[4]: http://sidekiq.org

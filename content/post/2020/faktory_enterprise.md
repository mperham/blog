+++
title = "Faktory Enterprise"
date = 2020-01-08T09:16:51-08:00
+++

The best way to kick off 2020 is by shipping something massive for me: **Faktory
Enterprise**.

[Faktory](https://contribsys.com/faktory) is an open source, language-independent background job system.
If you want to scale your business app to many millions of transactions per day, background jobs are the best way to do it.
[Celery](https://www.celeryproject.org), [Bull](https://github.com/OptimalBits/bull), [Sidekiq](https://sidekiq.org) are all popular but they are
limited to the one language they are written in (Python, JS and Ruby
respectively).
Faktory's advantage is that you can use it with **any** programming language; it makes a large, consistent feature set available to all of those languages.

## What's Faktory Enterprise?

Faktory Enterprise is the most feature-rich version of the Faktory job system available.
If you agree with my statements above and want the best job system for your company and team, you want Faktory Enterprise.
I'm launching it with two major features.

## Queue Throttling

This is, without a doubt, the #1 missing feature requested by Sidekiq customers.
"We want to resize 100,000 images but processing those jobs at
full blast will crush our servers. How can we throttle those jobs so
that our workers keep some threads available for other, more critical queues?".

Easy, [queue throtting](https://github.com/contribsys/faktory/wiki/Ent-Throttling#use-cases) couldn't be simpler to configure:

```toml
[throttles]
bulk = { worker = 5, timeout = 60 }
```

Throw those 100,000 jobs into a `bulk` queue.  That config says that
each worker process may only process 5 jobs from `bulk` at a time.
If each worker process has 15 threads, you'll have 10 threads left to
process other queues.
Of course it comes with a handy Web UI for monitoring:

<img title="queue throttle ui" src="https://raw.githubusercontent.com/contribsys/faktory/master/example/webui-throttle.png" width="100%"/>

I've never built this feature in Sidekiq for a number of reasons:

0. Sidekiq workers talk directly to Redis.
1. It makes the job fetch logic much more complex.
2. It conflicts with Sidekiq Pro's reliable fetch.
3. It requires Lua.

Faktory doesn't have this same problem because of its different
architecture: Faktory workers talk directly to Faktory, not Redis so (1)
is not true.  I can implement most of the logic within Faktory and keep
the Redis Lua logic to a minimum (this is really important to minimize
latency since Redis is single threaded). [Read more about throttling
here](https://github.com/contribsys/faktory/wiki/Ent-Throttling).

## Batches

Batches continue to be my favorite feature of all time and the one I am
most proud of.

* How can I run 1,000 jobs and be notified when all are done?
* How can I parallelize processing a 10,000 row spreadsheet and then kick
  off more jobs when that work is done?

A background job is a unit of work for your organization.
Batches allow you to compose more complex, nested workflows of jobs.
Here's an example defining a batch with several ImageJobs and a success
callback; that callback will execute only once all three ImageJobs have finished
successfully.

```ruby
b = Faktory::Batch.new
b.success = ImagesComplete.to_s
b.jobs do
  ImageJob.perform_async(...)
  ImageJob.perform_async(...)
  ImageJob.perform_async(...)
end
```

Note that a callback is a background job like everything else.
Of course it comes with a handy Web UI for monitoring but a screenshot is AWOL.
[Read more about batches here](https://github.com/contribsys/faktory/wiki/Ent-Batches).

## Docker Repository

Most of my customers are running Docker so I've joined the hype. The
commercial versions of Faktory now have a private Docker repository so you can
download and run Faktory directly:

```
$ docker login docker.contribsys.com
Username:
Password:
$ docker pull docker.contribsys.com/contribsys/faktory-ent:1.2.0
...
```

The [Faktory wiki](https://github.com/contribsys/faktory/wiki) contains full installation details.

## Conclusion

That's it! Those features took me many months of full-time work to
implement. They are some of the most involved code I've ever written but
I hope they turn out to be useful and easy to use for customers.

I'm excited because I already have two customers migrating
their existing job systems to Faktory Enterprise because of queue
throttling and polyglot support.

And that's the value: all features are useable by jobs and workers written in any programming language.
Want to batch jobs written in Rust and Python? Sure!
Want to scale and throttle your Erlang and Go worker queues differently? Why not!

Got questions, requests? Ping me at [@getajobmike](https://ruby.social/@getajobmike) or mike@contribsys.com.

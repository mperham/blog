+++
date = "2017-12-11T12:45:07-08:00"
title = "Sidekiq Pro Statsd support -- new and improved!"
+++

<div style="float: right; padding-left: 10px">
<figure>
<img src="//www.mikeperham.com/images/statsd.png"/>
<figcaption><small>Drivy's impressive Sidekiq dashboard [<a href="https://drivy.engineering/sidekiq-instrumentation/">source</a>]</small></figcaption>
</figure>
</div>

Several customers have been asking for more metrics to track Sidekiq
internals: when is a job dropped due to uniqueness or expiration?  I've
had to put off the work while working on
[Faktory](https://github.com/contribsys/faktory) but recently I took a week off
to focus on Sidekiq and implement this feature.

## New and Improved

Sidekiq Pro 3.6 has a brand new Statsd metrics subsystem.  Statsd is a
de facto universal standard for metrics in open source software, created by Etsy.  Even if you
use another system like InfluxDB, Prometheus or Datadog, every
metrics system will have an adapter or proxy to convert Statsd
metrics into their own internal format.

You plug in the Statsd client in your initializer and Sidekiq Pro will add metrics:

<div style="clear: both">
</div>

```ruby
require 'statsd-ruby'
Sidekiq::Pro.statsd = ->{ ::Statsd.new("127.0.0.1", 8125) }
```

Note that it's a Proc; Sidekiq Pro uses a connection pool with several clients so a
single global client doesn't become a source of thread and socket contention.

## More Metrics

Sidekiq Pro now publishes several new metrics:

```
jobs.expired - when a job is expired
jobs.recovered.push - when a job is recovered by reliable_push after a network outage
jobs.recovered.fetch - when a job is recovered by super_fetch after a process crash
batch.created - when a batch is created
batch.complete - when a batch is completed
batch.success - when a batch is successful
```

Future versions of Sidekiq Enterprise will also publish more metrics
based on their features.  A sample:

```
jobs.periodic.created - enqueued a cron job
leader.election - Sidekiq cluster changed leadership
jobs.duplicate - a job was not enqueued because it was not unique
jobs.duplicate.$WorkerClassName - metric with the worker's class name included, for debugging
```

With this, your operations dashboards should be more useful than ever.
Want more metrics?  [Open an issue!](https://github.com/mperham/sidekiq/issues/new)

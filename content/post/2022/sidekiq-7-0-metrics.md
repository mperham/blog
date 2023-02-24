---
title: "Sidekiq 7.0: Metrics"
date: 2022-10-27T09:20:55-07:00
publishdate: 2022-10-27
lastmod: 2022-10-27
tags: []
---

Sidekiq 7.0 introduces a new subsystem for gathering job execution data along with a new Metrics tab within the Web UI to visualize this data. The data is designed to help you answer a few questions:

- Which types of jobs executed?
- Which types of jobs took the most amount of time to execute?
- How has the performance of Job X changed recently?
- When did any deploys occur during this time?

The graphs only show data for **the last hour**.
This feature isn't meant to replace a full-blown APM like AppSignal, DataDog, New Relic, Scout, Skylight, etc.
Notably it does not try to profile inside your jobs to find N+1 queries, etc or provide longer-term historical execution metrics.

## Metrics Home

![metrics](https://github.com/sidekiq/sidekiq/raw/main/examples/metrics.png)

The Metrics home page shows a graph and table, focused on the Total Execution Time per Job Class. Lower lines are better.

A successful job is one which runs without raising an error to Sidekiq; we only track execution time for successful jobs.
You can see a Failure job count in the table but since failures can have unpredictable performance, tracking their time might cause a false sense of performance regression.
Average execution time is simply (Total Execution Time / Success).

In the graph above we can see most of the job types look healthy but one type `SlowJob` looks suspicious. We'll click its name in the table row to get more detail.

## Metrics Job Detail

![metrics for job](https://github.com/sidekiq/sidekiq/raw/main/examples/metrics_job.png)

The detail page shows an overall histogram of execution times for the past hour along with a bubble graph of fine-grained data per minute for the given job type.

In the bar graph, we want to see big bars on the left. In the bubble graph, lower is faster and fatter bubbles mean more executions. Ideally you want nice fat bubbles at the bottom of the graph with little variation.

We can see that SlowJob has a bunch of executions which are very fast (see the 20ms bar).
Very fast executions usually mean you are returning early in the `perform` method, that's normal and ok.
But we can also see a mound of slower executions ranging from 750ms to 13sec, almost a 20x spread!
This slower grouping indicates unpredictable job execution time and something you might want to diagnose in order to better understand your application performance characteristics.

**Remember that some job execution time variance is normal**. Ruby will unpredictably switch to other threads or garbage collect, CPU and network performance can vary based on load, 3rd party services can vary in performance, etc.

## Storage and Implementation Details

The Metrics home page uses coarse-grained performance data which Sidekiq sends to Redis with every heartbeat.
Sidekiq stores a tuple of `[job type, minute, failure count, execution count, total execution time]`. Notice with the coarse data, all we know about SlowJob is that it averages 3.49s per execution.

The Metrics Job Detail page uses finer-grained execution time data stored as a "bucket histogram" structure.
You get one histogram per job type per minute so all executions of `FooJob` at `17:34 UTC` will use one histogram.
Each histogram has 26 buckets, each bucket is a 16-bit counter.
The first bucket represents 0-20 ms and each bucket increases by 1.5x, the second bucket is 20-30 ms, the third is 30-45 ms, etc.
If FooJob executed three times during 17:34 taking 15ms, 25ms and 50ms, then each of the first three buckets will have a value of 1.
Notice that with the finer histogram data we can see the performance curve of SlowJob, giving us more insight into its performance characteristics.

Every job type that executes in a given minute requires 52 bytes of storage in Redis; the data expires after 8 hours.
If you have 200 job types, that's 200 * 52 * 60 * 8 = 4,992,000 or less than 5MB of data.

The choice of 1.5x and 26 buckets was arbitrary.
With a smaller scale factor like 1.3x, you get more precise buckets but need more buckets to track the same spread of execution times.
With more buckets you can track a wider spread of execution times but require more space in Redis.

The implementation uses Redis' super nifty [BITFIELD](https://redis.io/commands/bitfield/) command.
See [`lib/sidekiq/metrics/`](https://github.com/sidekiq/sidekiq) for details.

## Tracking Deployments

Sidekiq provides a simple Deploy API so capistrano scripts or similar can mark a deploy. The Metrics graphs will show a vertical line at that point in time so sudden changes can be correlated. If the current directory is a Git repo, here's a simple script which will label each deploy with the current git SHA and commit subject (e.g. "d0f12ab3 Add foo to bar"):

```ruby
require "sidekiq/deploy"
gitdesc = `git log -1 --format="%h %s"`.strip
Sidekiq::Deploy.mark!(gitdesc)
```

You'll see a vertical red line for every deploy in the graphs and the legend for that point on the X-axis will display the deploy label.

![deploy marks](https://user-images.githubusercontent.com/2911/189455943-18e898af-ee51-4b4c-9dd7-9bbc37d304bd.png)

## Summary

I hope this new Metrics tab proves useful for all Sidekiq users but this subsystem is brand new and still ripe for improvement.
If you have ideas for new features or functionality, please [open an
issue](https://github.com/sidekiq/sidekiq/issues/new) so we can discuss!

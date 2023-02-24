---
title: "Coming Soon in Sidekiq, 2022 edition"
date: 2022-06-17T09:00:00-08:00
publishdate: 2022-06-13
lastmod: 2022-06-13
tags: []
---

I just released Sidekiq 6.5 and I've got a lot of changes on the roadmap for Sidekiq 7.0.
Here's what's coming soon so you can plan too.

## New Transaction-aware Client

Sidekiq has long had a "problem" with executing jobs very fast, before
any associated transaction has committed, leading to "Cannot find
Model id=1234" errors. Sidekiq 6.5 introduced beta support for a new
`Sidekiq::Client` option which will delay all job pushes until the current transaction has committed. 

Users have already [found and fixed](https://github.com/Envek/after_commit_everywhere/issues/20) a potential DB connection leak in the `after_commit_everywhere` gem thanks to the increased usage.
That's why we call it beta, folks!

## New Redis Driver

The existing `redis` gem is reliable and battle-tested but has code written for every Redis command.
When Redis adds a new command, `redis` needs to add a Ruby method and ship a new version. Ugh!

Redis 6.0 introduced [the RESP3 protocol](https://github.com/antirez/RESP3/blob/master/spec.md) which allows clients to be implemented without knowledge of specific commands, greatly reducing lines of code in the client.
This is the core of the new `redis-client` gem.
Once I understood this, I realized what a huge advantage this would be; less code means fewer bugs and easier maintenance.
That's good for you, me and especially @_byroot who maintains it!

Sidekiq 6.5 supports running with either gem, `redis` by default and beta support for `redis-client`.
Sidekiq 7.0 will work with `redis-client` only.

## Configuration Refactoring

I'm executing a long-term plan for refactoring Sidekiq's internals in order to allow new deployment topologies.
What would it take to run N Sidekiq instances **in one process**?
Today all Sidekiq configuration is centralized in the global Sidekiq module.
Instead I'm creating a new `Sidekiq::Config` class which could allow configuring multiple instances of the Sidekiq runtime, all running in the same process.
This could unlock a whole new set of features, possibly including **queue throttling**?!?!
Sidekiq 6.5 saw the first step in that refactoring plan.
Sidekiq 7.0 is the next step.

## Redis Data Model and Statistics

Another big change I'm planning is a [major overhaul of the
statistics](https://github.com/sidekiq/sidekiq/pull/5384) Sidekiq stores in Redis.
Since Sidekiq 1.0, these have been coarse-grained success/failure counters per day.
In Sidekiq 7.0 I want to save more fine-grained data which could provide APM-lite functionality: per-queue and per-job runtime metrics.
What about a vertical line in the graphs for the time of each deployment?
Job runtime histograms?

To some extent this is redundant with Sidekiq Pro's Statsd support but that does require a somewhat complex metrics service and dashboard configuration.
I envision this functionality to work out of the box.

I'd welcome feedback on the proposal and other ideas for improving the data model and its capabilities.
Collection needs to be really efficient at runtime, the data take as little space in Redis as possible and provide useful graphs/metrics in the Web UI.
No pressure!

## Other ideas?

I'd love suggestions on how we can improve Sidekiq in its second decade.

---
title: "Supporting Dragonfly"
date: 2024-02-01T09:00:00-08:00
publishdate: 2024-02-01
lastmod: 2024-02-01
draft: false
tags: []
---

For about 15 years, Redis has been the dominant choice for background job infrastructure in Ruby.

First used by Resque, Sidekiq adopted it also as a pragmatic choice which had already gained mass acceptance within the community.
And so for the last 15 years, we've used Redis widely across the industry for caching, jobs and many different data munging tasks.
However the only constant is change.

<a href="https://dragonflydb.io" style="float: right; padding: 20px;">
  <img src="https://raw.githubusercontent.com/dragonflydb/dragonfly/main/.github/images/logo-full.svg"
    width="284" border="0" alt="Dragonfly">
</a>

[Dragonfly](https://dragonflydb.io) brings competition and new capabilities.
They aim to provide a Redis-compatible tool which is better than Redis at certain tasks.
First and most importantly, all Sidekiq test suites are passing 100%.
There's no point in switching to a buggy or incomplete tool; Dragonfly has done the work to fully support every nook and cranny of Sidekiq's functionality.
Performance is where you can see major differences.

For normal use cases, Redis is still faster because of its single-threaded core and lack of locking but scale up and tune Dragonfly and it'll start to pull ahead due to its multi-core capabilities.
The Dragonfly team developed a benchmark which stresses Sidekiq's basic queue processing pipeline: pulling off and executing jobs as fast as possible. They wrote a very thorough blog post talking about the work they did in [tuning and benchmarking Dragonfly with Sidekiq](https://www.dragonflydb.io/blog/running-sidekiq-with-dragonfly).

If you want to scale past Redis's single core, Dragonfly can peg multiple cores while handing out hundreds of thousands of jobs per second to your Sidekiq cluster.
Unfortunately I can't replicate the best of the benchmark results because the necessary hardware becomes pretty expensive.
Here's it chewing through 30,000 jobs/sec on my M1 laptop but the Dragonfly team have tested it running **over 400,000 jobs/sec** on a massive EC2 machine running 96 cores (to run 96 Sidekiq processes in parallel).

```
RUBY_YJIT_ENABLE=1 PROCESSES=8 QUEUES=8 THREADS=10 ITERATIONS=100 ELEMENTS=1000 bin/multi_queue_bench
Dragonfly 1.14.1: 800000 jobs in 26.1067 sec, 30643 jobs/sec
```

Typical business applications processing thousands or even millions of jobs per day may not benefit from Dragonfly but if your job cluster is approaching the limits of scale, you really only had one choice: move to multiple Redis shards.
Now you have another choice in Sidekiq 7.2: switch to Dragonfly.
Read the [Using Dragonfly](https://github.com/sidekiq/sidekiq/wiki/Using-Dragonfly) wiki page which covers the best tips and tricks for running Dragonfly + Sidekiq.
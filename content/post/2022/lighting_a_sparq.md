---
title: "Lighting a Sparq⚡️"
date: 2022-11-14T09:21:09-08:00
publishdate: 2022-11-14
lastmod: 2022-11-14
tags: []
---

I'm starting a new project, [Sparq](https://github.com/contribsys/sparq)⚡️.

With the ongoing fall of Twitter and the rise of the Fediverse, Mastodon seems to be the talk of the town. Unfortunately much of the talk seems to be about its scaling problems. You might not know this but Mastodon uses my [Sidekiq](https://sidekiq.org) project to do much of its data processing and federation. Sidekiq can scale really, really far (I emailed last week with a Sidekiq Pro customer processing 22 billion jobs/day \[250,000/sec!\]) but it needs to be deployed carefully to handle that scale. Fundamentally, a Ruby process is memory-hungry and bound to a single core. Sidekiq can't change that.

## Mastodon

Mastodon is a Ruby on Rails app.
It requires Ruby and a large set of gems to be installed.
The Mastodon source tree must be deployed.
You install and run PostgreSQL for the database.
You install and run Redis for Sidekiq.
You must run separate Puma and Sidekiq processes.
In summary, you must run and monitor a minimum of four services: postgresql, redis, puma, sidekiq.
If you want to scale Mastodon, you need to run more puma or sidekiq processes.
Since Mastodon is using Ruby, each puma or sidekiq process can only use one core.
The DevOps knowledge required to administer Mastodon is significant.

So Mastodon is in a bind: Ruby is a lovely language with some painful runtime constraints. This is what I aim to fix with Sparq.

## How is Sparq different?

Sparq is designed to be a single executable with all of the infrastructure necessary for a complex web application inside it.
Redis is the only external dependency.
Embedded within the Sparq process is:

* sqlite providing a SQL database
* faktory providing a background job engine
* a faktory worker pool for processing those jobs
* redis running as a child process

Instead of four separate services requiring customization to scale, you have one service which automatically scales.

Sparq is written in Go.
The Go language is far faster than Ruby (typically 5-10x).
It uses far less memory (typically 5-10x).
It does not limit you to one core but can automatically use all cores on a machine.
If you put Sparq on a 2 core machine, it will use 2 cores.
If you put it on a 64 core machine, it will use all 64 cores.
Automatically.

With all of those services running, it boots in 10 milliseconds:

```
Sparq⚡️ 0.0.1
Copyright © 2022 Contributed Systems LLC
Licensed under the GNU Affero Public License 3.0
D 2022-11-11T00:06:12.379Z Options: {localhost:9494 localhost.dev debug . .}
I 2022-11-11T00:06:12.380Z Starting sqlite 3.39.3
I 2022-11-11T00:06:12.380Z Initializing redis storage at ., socket sparq.redis.sock
D 2022-11-11T00:06:12.381Z Booting Redis: /opt/homebrew/bin/redis-server /tmp/redis.conf --unixsocket sparq.redis.sock --loglevel notice --dir . --logfile ./redis.log
D 2022-11-11T00:06:12.388Z Redis booted in 5.864375ms
D 2022-11-11T00:06:12.389Z Running Redis v7.0.5
D 2022-11-11T00:06:12.389Z Queue init: low 0 elements
D 2022-11-11T00:06:12.389Z Queue init: high 0 elements
I 2022-11-11T00:06:12.389Z Faktory 1.6.2 booted
I 2022-11-11T00:06:12.389Z Starting Faktory job runner with 40 concurrency
I 2022-11-11T00:06:12.389Z Web now running at localhost:9494
```

## Status

Sparq is brand new.
I have the core infrastructure running as above but there's no app yet.
We need to build the database models, ActivityPub federation, Admin UI and User UI.
Where possible we will maintain compatibility with Mastodon.
But realistically that's a lot of work; Sparq will not be usable for several months.
But if this project interests you and you'd like to help expand the Fediverse ecosystem, jump into the [issue tracker](https://github.com/contribsys/sparq/issues) and review the current status.

As we get closer to something usable, I'll update this blog with project news.
Follow me at [https://ruby.social/@getajobmike](https://ruby.social/@getajobmike).
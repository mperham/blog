---
title: "Faktory News: Pause, RSS and Bring your own Redis"
date: 2021-03-01T09:00:00-08:00
publishdate: 2021-03-01
lastmod: 2021-03-01
tags: []
---

Faktory is my background job server for use with any programming language.
It brings the nice patterns and features available in Sidekiq to the rest of the world.
Using Go, Python, JavaScript, Elixir, or other languages?
Give [Faktory](https://github.com/contribsys/faktory/wiki) a shot!

Today I've released Faktory, Faktory Pro and Faktory Enterprise 1.5.0.
What's new?

# Pause / Resume

The OSS version of Faktory now allows you to **Pause** and **Resume** processing
for a queue. When Paused, calling FETCH on a queue will get nothing
back. The `/queues` page has a button to toggle the state.

![pause UI](/images/faktory-pause.png)

There is a new QUEUE command to do this via API:

```
QUEUE PAUSE *
QUEUE PAUSE nameA nameB ...
QUEUE RESUME *
QUEUE RESUME nameA nameB ...
```

and of course the Go and Ruby clients have been updated so you can issue
these commands:

```ruby
require 'faktory'

client = Faktory::Client.new
client.pause_queue [:default, :low]
client.resume_queue "*"
```

# Worker RSS display

Worker processes can now submit their current process RSS with their
heartbeat so Faktory can display that attribute on the `/busy` page. The Go
and Ruby workers have been updated to do so.

![rss UI](/images/faktory-busy-rss.png)

# Bring your own Redis

Faktory Enterprise has a huge new feature: **Bring your own Redis**.
Faktory Enterprise will now work with a Redis instance that you supply, allowing
you to outsource high availability, failover and replication to the Redis SaaS of
your choice, e.g. AWS Elasticache, Redis-To-Go, Redis Labs, RedisGreen,
Heroku Redis.

All you need to do is provide a `REDIS_URL` variable to the Faktory
process or a `REDIS_PROVIDER` variable which points to a custom variable.

Faktory is very sensitive to Redis round trip time (RTT) so the `/debug` page now
highlights the current RTT seen by Faktory. If RTT is
above 1000µs, Faktory will display yellow (above 10,000µs: red) and print a
warning so you understand performance will be less than optimal.
One customer with a high quality (i.e. expensive) AWS Elasticache
instance reported 160µs RTT in us-east-2. The localhost Redis instance on
MikeBookPro reports 200µs. You win this time, AWS! To keep RTT low:

1. Ensure your Redis instance is in the same Availability Zone as your Faktory instance.
   You cannot beat the speed of light so distance will always add latency.
   One mile adds 5µs.
1. Ensure your Redis instance is running on reasonably high-quality hardware.
   You will be disappointed if you expect good performance on a `t2.micro`.
1. Faktory Enterprise cannot share the Redis database with any other
   applications or Faktory instances; sharing will lead to unpredictable behavior.

I hope all Faktory users and customers love these new features. Please [open an
issue](https://github.com/contribsys/faktory/issues/new) if you have any questions or comments.

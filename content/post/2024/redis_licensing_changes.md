---
title: "Redis Licensing Changes and You"
date: 2024-04-22T08:53:20-07:00
publishdate: 2024-04-22
lastmod: 2024-04-22
tags: []
---

A few weeks ago, the owners of Redis changed its licensing from BSD to a more limited source available license.
As far as I know this was done in order to prevent service providers from adding their own closed source, proprietary changes to their Redis service offerings.

In principle I like this change.

My [Faktory](https://github.com/contribsys/faktory) project uses the AGPL license for the same purpose: Faktory is open source and anyone who offers Faktory as a service **with proprietary changes** should have to open source those changes too.
I consider this a valuable quid pro quo: if you change my open source to make money, you must contribute some of that value back to the community in return.

## How does this affect Sidekiq and Faktory users?

"Not at all" is the short answer.

Are you adding custom functionality to the Redis source code and then providing a binary or service access to your users or customers?
Almost no one is doing this except Redis service providers: AWS, GCP, Azure.
This licensing change is meant to force them to negotiate custom licensing with Redis.com for any future Redis releases.

Both Sidekiq and Faktory use stock Redis. Neither rely on or add any proprietary extensions to the Redis source code.

Redis remains 100% usable for everyone else, as long as you use a pre-packaged Redis or a stock build.
The last Redis release with the old licensing is v7.2.4 and Sidekiq will remain compatible with that version for the foreseeable future.

## Using other Redis forks?

Sidekiq also recently announced compatibility and support for [Dragonfly](https://www.mikeperham.com/2024/02/01/supporting-dragonfly/), a multi-threaded fork of Redis.
I have not tested Sidekiq with the new [Redict](https://redict.io) and [Valkey](https://valkey.io) forks but I would bet they work just fine.

My takeaway is that Sidekiq and Faktory users don't need to worry or care about this change.
Please let me know if you have further concerns, mike@contribsys.com.
---
author: Mike Perham
categories:
- Sidekiq
date: 2013-08-10T00:00:00Z
title: Lua and Sidekiq Pro
url: /2013/08/10/lua-and-sidekiq-pro/
---

I've started working with Redis 2.6's embedded Lua support to power new features for Sidekiq Pro. I think there's a rich vein of functionality to be tapped here for several reasons:

*   **Server-side execution = performance** O(n) algorithms perform much better when you don't have network latency. For example, Sidekiq Pro 1.2 adds a `Sidekiq::Queue#delete_job` API which scans a queue and deletes the job with the given JID. Previously this required network round trips and so performed poorly, even when using paging. With a queue size of 10,000 jobs, my benchmark deleting 200 random jobs with the Lua version is 15x faster (1.5sec vs 20sec).
*   **Atomic execution** Lua operations execute atomically in Redis so you can add complex logic to mutate data within Redis without the need for locks.

There's a caveat of course: Redis is single-threaded so executing a user-defined Lua script can add significant latency to other Redis operations if you aren't careful with performance. O(n^2) algorithms are definitely a no-no and minimizing O(n) algorithms is still a good idea if you want your Redis server to continue to perform well. Nevertheless I think Lua has real potential for developing some cool new features.

It's possible some Lua features will go into Sidekiq but right now everything I'm planning will be Sidekiq Pro only.

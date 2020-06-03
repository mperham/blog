---
title: "Trimming Dependencies"
date: 2020-06-02T15:41:10-07:00
publishdate: 2020-06-02
lastmod: 2020-06-02
tags: []
---

I've advocated for [fewer dependencies](https://www.mikeperham.com/2016/02/09/kill-your-dependencies/) for years now.
Every long-running project needs to periodically re-evaluate their usage of each dependency and the value it provides.
To that end, I recently considered Sidekiq's dependencies:

- redis-rb - the Redis client
- connection_pool - provide threaded access to Redis connections
- rack - required to standardize Sidekiq's Web UI
- rack-protection - necessary to provide CSRF protection for write
actions in the Web UI

We might be able to remove `rack-protection` gem if we re-implement the
CSRF functionality but none of the other gems are easy to remove
(indeed, as I was writing this post, @seuros stepped up and took on [issue #4587](https://github.com/mperham/sidekiq/issues/4587)).

### Sidekiq Pro

Sidekiq Pro adds a dependency on `concurrent-ruby` because Pro uses its
`ThreadPoolExecutor` to limit access to Redis in super_fetch. Can we
remove it?

It turns out we can. We can reuse a connection pool as a pool of tokens
for accessing Redis. By forcing all Processor threads to get a token
before calling Redis, we can limit concurrent access to Redis. After
refactoring connection_pool a bit, I was able to replace Concurrent
usage with just a few lines of ConnectionPool code.

```diff
-        @pool ||= Concurrent::ThreadPoolExecutor.new(
-          min_threads: 1,
-          max_threads: 2,
-          max_queue: options[:concurrency]
-        )
+        @pool = ConnectionPool.new(size: 2, timeout: 120) { Object.new }

@@ -249,12 +244,20 @@ module Sidekiq::Pro
-          future = Concurrent::Future.execute(executor: @pool, &method(:get_job))
-          val = future.value(nil)
-          return val if val
-          raise future.reason if future.rejected?
-        rescue Concurrent::RejectedExecutionError
+          # Since every Processor is a Thread, we want to limit the concurrency
+          # going to Redis. We do this with an artifically limited connection pool
+          # that holds tokens allowing the Thread to call Redis. We need to do
+          # this because Redis does not have a command which is both Reliable
+          # *and* operates on multiple queues.
+          # https://github.com/antirez/redis/issues/1785
+          @pool.with do
+            get_job
+          end
+        rescue ConnectionPool::TimeoutError
+          nil
+        rescue ConnectionPool::PoolShuttingDownError
           # shutting down race condition, #2827, nbd
+          nil
         end

```

### Sidekiq Enterprise

Sidekiq Enterprise adds a dependency on `einhorn` for the [rolling
restart](https://github.com/mperham/sidekiq/wiki/Ent-Rolling-Restarts) feature.
We can't really remove this gem as customers use the `einhorn` binary.

Enterprise also uses the `Concurrent.processor_count` API so it can fork
a Sidekiq process for each core. It turns out that Ruby already provides
this API in `Etc.nprocessors`, awesome!!! With this change, we can
completely remove the `concurrent-ruby` gem from all Sidekiq variants.

```diff
@@ -46,7 +45,7 @@ module Sidekiq
         @signal = signal
         @io = STDOUT
 
-        @count = Integer(env["SIDEKIQ_COUNT"] || Concurrent.processor_count)
+        @count = Integer(env["SIDEKIQ_COUNT"] || Etc.nprocessors)
```

### Who cares? What's the effect?

Almost all OSS projects will struggle to get long term maintenance.
concurrent-ruby had a maintainer for many years but he eventually moved
onto other things. I believe it currently has another maintainer but
there's no guarantee how long that arrangement will last. **Without
maintenance, OSS projects are a snapshot in time: eventually they will
become outdated.**

Once I removed all usage of the gem I booted a bare Sidekiq Pro process, had it process a few thousand jobs, and examined the RSS before and after:

**Before**: 60MB<br/>
**After**: 50MB

**10MB shaved off by removing concurrent-ruby!!!**

### Conclusion

Alas, a reality check: Rails depends on concurrent-ruby so most apps using Sidekiq will pull it in anyways.
But this is a great example where stable, well used projects can always improve.
Rails depends on many dozens of gems: can you remove one?

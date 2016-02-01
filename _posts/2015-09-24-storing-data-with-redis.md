---
title: "Storing Data with Redis"
author: Mike Perham
layout: post
permalink: /2015/09/24/storing-data-with-redis/
published: true
---

Would you stuff all of your data into one database table?  *That's crazy, Mike,
don't be silly!*  What if I told you most people do just that with Redis?

<img src="/images/redis.png" width="740px" />

Redis users often have several distinct datasets in Redis: long-lived transactional data, background job queues,
emphemeral cached data, etc.  At the same time I see lots of people using Redis in the most naive way possible:
put everything into one database.

There are several questions to answer when determining how to use Redis for different datasets:

1. Can I flush with the dataset without affecting other datasets?
2. Can I [tune the persistence strategy][0] per dataset?
   For transactional data, you want real-time persistence with AOF.
   For cache, you want infrequent RDB snapshots or no persistence at all.
3. Can I scale Redis per dataset?  Redis is single-threaded and can perform X ops/sec so consider that your
   performance "budget".  *Datasets in the same Redis instance will share that budget.*  What happens when your
   traffic spikes and the cache data uses the entire budget?  Now your job queue slows to a crawl.

## Data Partitioning

You have several different options when it comes to splitting up your data:

### Namespaces

This is the most naive option.  With namespaces, the Redis client prefixes every key with the
namespace, e.g. "cache", so the keys for "cache" don't conflict with the keys for "transactional".  Namespacing
increases the size of every key by the size of the prefix.  You don't get to tune Redis for the
individual needs of "cache" and "transactional".  **I strongly recommend avoiding namespaces**.
I see people use namespaces to share a single Redis across multiple apps and/or multiple environments.
Consider this for hobbyists only who only want to pay for a single Redis database from a SaaS;
you do not want to build a business on top of this hack.  **Answers: No, No, No**.

### Databases

Out of the box, every Redis instance supports 16 databases.  The database index is the number you see
at the end of a Redis URL: `redis://localhost:6379/0`.  The default database is 0 but you can change that
to any number from 0-15 (and you can configure Redis to support more databases, look in redis.conf).  Each database
provides a distinct keyspace, independent from the others.  Use `SELECT n` to change databases.  Use `FLUSHDB` to flush the
current database.  You can `MOVE` a key from the current database to another database.

Want to put all your Sidekiq job data in a separate database?

{% highlight ruby %}
# Use DB 4 for all job data
redis = { url: 'redis://localhost:6379/4' }
Sidekiq.configure_client do |config|
  config.redis = redis
end
Sidekiq.configure_server do |config|
  config.redis = redis
end
{% endhighlight %}

Using separate databases is an easy way to put a "firewall" between datasets without any additional administrative
overhead.  Now you can FLUSHDB one dataset without affecting another dataset.  Protip: configure your test suites
to use a different database than your development environment so the test suite can FLUSHDB without destroying development data.
**Answers: Yes, No, No**.

### Instances

Running separate instances of Redis on different ports is the most flexible approach but adds significant administrative
overhead.  If you are using Redis for caching (and you should probably use memcached<sup>1</sup> instead), use a separate instance
so you can [tune the configuration][1] and dedicate 100% of Redis's single thread to serving high-traffic cache data.
Configure another Redis instance to handle lower-traffic transactional and job data with more appropriate persistence.
**Answers: Yes, Yes, Yes**.

## Conclusion

My main goal of this blog post is educate people on the drawbacks of stuffing everything into one Redis database.
Namespaces are a poor solution for splitting up datasets in almost every case.

<hr/>
1. I recommend memcached because it is designed for caching: it performs no disk I/O at all and is multithreaded so it can scale
across all cores, handling 100,000s of requests per second.  Redis is limited to a single core so it will hit a scalability
limit before memcached.  Using Redis for caching is totally reasonable if you want to stick
with one tool and are comfortable with the necessary configuration and lower scalability limit per process.  Redis does
have a nice advantage that it can persist the cache, making it much faster to warm up upon restart.

[0]: http://redis.io/topics/persistence
[1]: http://redis.io/topics/lru-cache

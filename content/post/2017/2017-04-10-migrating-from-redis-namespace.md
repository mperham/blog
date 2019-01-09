+++
date = "2017-04-10T09:00:00-07:00"
title = "Migrating from redis-namespace"
+++

In a blog post in 2015, [Storing Data with Redis](http://www.mikeperham.com/2015/09/24/storing-data-with-redis/), I wrote about your options for partitioning data
stored within Redis and came down pretty hard on using key namespacing
via redis-namespace.
The redis-namespace gem allows you to share a Redis database among several
applications by prefixing every key with a namespace but it's a terrible hack
that no one should use.  Redis
already has a native solution if you want to share a Redis instance: databases.
The default database is 0.  Here's how to point Sidekiq to use database
1 instead:

```ruby
Sidekiq.configure_client do |config|
  # these are equivalent
  config.redis = { url: "redis://localhost:6379/1" }
  config.redis = { db: 1 }
end
```

By default, Redis offers 16 databases: 0-15.  This is configurable in
redis.conf.  Keys in one database are not visible from another database.
All databases will share global data like registered Lua scripts.
In practice that's not a big deal due to Redis's excellent implementation.

If you have multiple apps and want to share a Redis instance, just have
them use different databases.  Create a convention for how your apps map to
database indexes and stick with it.

> Cache data, job data and transactional/persistent data have different configuration needs and should
not share a Redis instance at all.  If you use Redis for caching and
jobs and your budget is \>$0, you should have two different Redis instances
with different configurations. Job data is closer to transactional data,
they can probably share the same Redis if necessary.

*"Our current application uses redis-namespace.  How do we migrate away from namespace usage without losing everything we have currently?"*

Ah, this is possible but non-trivial, as with all data migrations.
I will assume you are running Sidekiq.
Continue onward for the nittiest of gritty, dear reader.

## Migrating your Data

Like any data migration, you have two choices:

1. Run old/new systems in parallel for N days/weeks
2. Shutdown old setup, migrate data, start new setup

### Running old/new in parallel

You want to start two Sidekiq processes: old and new.  The old
process(es) will continue to process any retries and scheduled jobs in
the old data.  The new process(es) will process all new jobs.

```
# Starting an old and new process
OLD=1 bundle exec sidekiq ...
bundle exec sidekiq ...
```

We specifically want the client configuration to only point to the new
system so that any new jobs from Puma/Unicorn/etc will go to the new
system.  In this example, the old Redis is using the `foo` namespace in
database 0.  We want the new system to use database 1 with no namespace.

```ruby
# Note that the client ALWAYS pushes to the new process
Sidekiq.configure_client do |config|
  config.redis = { db: 1 }
end

Sidekiq.configure_server do |config|
  if ENV['OLD']
    # We'll continue to poll for old scheduled jobs and retries
    config.redis = { namespace: 'foo', db: 0 }
  else
    config.redis = { db: 1 }
  end
end
```

If you are a Sidekiq Pro customer you can monitor both old and new in the Web UI with Sidekiq Pro's
[Web UI Sharding support](https://github.com/mperham/sidekiq/wiki/Pro-Web-UI#sharding),
just mount a copy for the old and new config in your `config/routes.rb`:

```ruby
NEWPOOL = ConnectionPool.new { Redis.new(db: 1) }
OLDPOOL = ConnectionPool.new { Redis::Namespace.new(:foo, :redis => Redis.new(db: 0)) }

mount Sidekiq::Pro::Web.with(redis_pool: NEWPOOL), at: '/sidekiqnew', as: 'sidekiqnew'
mount Sidekiq::Pro::Web.with(redis_pool: OLDPOOL), at: '/sidekiqold', as: 'sidekiqold'
```

Monitor your retry and scheduled job counts in the old system.  After N weeks, you should be able to safely decommission the old Sidekiqs.  Ciao, bella!

### The big migration

If you can afford the downtime, it can be a lot faster/easier/cheaper to simply
migrate your Redis data to strip off the namespace from the key.  You
shut down the old processes (**anything** that talks to Redis with the namespace),
run the migration script, and start everything with the new setup once it's complete.

> How long will it take?

This is an excellent question, look at the size of your databases:

```
$ redis-cli info
[snip]

# Keyspace
db0:keys=2,expires=0,avg_ttl=0
db4:keys=18,expires=15,avg_ttl=1894990352
db5:keys=10,expires=7,avg_ttl=1894990303
db14:keys=7,expires=4,avg_ttl=1894990402
```

Notice the keys count.  This will tell you the magnitude of your
problem: do you have thousands of keys or millions?  For every single
key, we want to strip the namespace from the front of it.

We'll write a Lua script which will run atomically on our instance and
rename every key.  **This script will not move the data from database 0
to database 1** (for future readers, in Redis 4.0, there is a [SWAPDB](https://redis.io/commands/swapdb) command which can do
this).

**WARNING: Depending on the amount of data in Redis, this script may
crush your Redis instance for a long time.  Do not use it while other
things are using that Redis instance.**

```ruby
# remove_ns.rb
require 'redis'

################################
# Change "foo" to your namespace, leave the ":*" alone
ns = "foo:*"

################################
# Point to your Redis instance
redis = Redis.new(db: 0)

script = <<-LUA
  local count = 0
  local keys = redis.call("keys", ARGV[1])
  for _, keyname in pairs(keys) do
    redis.call("rename", keyname, string.sub(keyname, ARGV[2]))
    count = count + 1
  end
  return count
LUA

start = Time.now
count = redis.eval(script, [], [ns, ns.size])
puts "Complete, migrated #{count} keys in #{Time.now - start} sec"
```

Now:

1. **Shut down everything talking to your Redis instance.** You can verify
   by running `redis-cli monitor` against the instance and seeing that
   nothing is coming over the wire.
2. Run `ruby remove_ns.rb`
3. Deploy your new configuration and start everything back up.

## Testing

I created a script which creates 500 plain keys and 500 namespaced keys
to verify that 500 keys are migrated:

```ruby
gem 'redis', "< 4"
require 'redis'

redis = Redis.new(db: 4)

500.times do |idx|
  redis.set(idx, idx)
end

require 'redis-namespace'
rn = Redis::Namespace.new(:foo, redis: redis)

500.times do |idx|
  rn.set(idx, idx)
end
```

The result:

```sh
$ ruby remove_ns.rb
Complete, migrated 500 keys in 0.003167 sec
```

The keyspace count goes from 1000 to 500 with the migration.  Please
note that this migration script blindly renames keys so if you have keys named
"foo:bar" and "bar", it's possible the latter will be overwritten in the
migration due to the rename.

## Conclusion

* Avoid namespaces.
* Data migrations are always fraught with peril, test in staging.
* Make backups and always have a replica handy.

Good luck!

+++
date = "2017-04-27T09:00:00-07:00"
title = "Debugging Redis"
draft = true
+++

Redis is widely by the Ruby community but, like any complex piece of
infrastructure, isn't well understood by many of its users.  I wanted to
write a blog post that would answer the question: **How can I check on
the health of my Redis server?**

----
## Ask for Info

The `info` command is the easiest way to get an overall view of Redis:

```
$ redis-cli info
# Server
redis_version:3.2.5
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:9fe990583d8f1fbf
redis_mode:standalone
os:Darwin 16.5.0 x86_64
arch_bits:64
multiplexing_api:kqueue
gcc_version:4.2.1
process_id:445
run_id:b2f86239484facc8dd3829ad25dac8757afdb32f
tcp_port:6379
uptime_in_seconds:1313002
uptime_in_days:15
hz:10
lru_clock:16178069
executable:/usr/local/opt/redis/bin/redis-server
config_file:/usr/local/etc/redis.conf

# Clients
connected_clients:1
client_longest_output_list:0
client_biggest_input_buf:0
blocked_clients:0

# Memory
used_memory:1043920
used_memory_human:1019.45K
used_memory_rss:16564224
used_memory_rss_human:15.80M
used_memory_peak:18961872
used_memory_peak_human:18.08M
total_system_memory:8589934592
total_system_memory_human:8.00G
used_memory_lua:60416
used_memory_lua_human:59.00K
maxmemory:0
maxmemory_human:0B
maxmemory_policy:noeviction
mem_fragmentation_ratio:15.87
mem_allocator:libc

# Persistence
loading:0
rdb_changes_since_last_save:0
rdb_bgsave_in_progress:0
rdb_last_save_time:1492463475
rdb_last_bgsave_status:ok
rdb_last_bgsave_time_sec:0
rdb_current_bgsave_time_sec:-1
aof_enabled:0
aof_rewrite_in_progress:0
aof_rewrite_scheduled:0
aof_last_rewrite_time_sec:-1
aof_current_rewrite_time_sec:-1
aof_last_bgrewrite_status:ok
aof_last_write_status:ok

# Stats
total_connections_received:396
total_commands_processed:588823
instantaneous_ops_per_sec:0
total_net_input_bytes:136139888
total_net_output_bytes:216183171
instantaneous_input_kbps:0.00
instantaneous_output_kbps:0.00
rejected_connections:0
sync_full:0
sync_partial_ok:0
sync_partial_err:0
expired_keys:95
evicted_keys:0
keyspace_hits:6978
keyspace_misses:20802
pubsub_channels:0
pubsub_patterns:0
latest_fork_usec:1007
migrate_cached_sockets:0

# Replication
role:master
connected_slaves:0
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0

# CPU
used_cpu_sys:67.83
used_cpu_user:42.98
used_cpu_sys_children:0.07
used_cpu_user_children:0.07

# Cluster
cluster_enabled:0

# Keyspace
db4:keys=25,expires=24,avg_ttl=892611707
db5:keys=37,expires=36,avg_ttl=829671792
db8:keys=4,expires=2,avg_ttl=4423347833
```

There's a few very important pieces to note in the output:

1. `config_file` shows where Redis is getting its static configuration.
   If you need to tweak a setting, this is where to go.
1. `connected_clients` shows how many network client connections are
   currently connected.  It's normal for this to be in the hundreds or
   even thousands for a very busy server.
1. `used_memory_*` is important to see how much RAM is used by Redis.

Memory is the most important thing to note here.  Your entire dataset
size **must** fit into machine RAM.  If it does not, the resulting swapping will lead
to terrible performance and massive latency spikes.

`--stat` mode gives you the most important details in a real-time view
you can watch:

```
$ redis-cli --stat
------- data ------ --------------------- load -------------------- - child -
keys       mem      clients blocked requests            connections
31         1009.00K 1       0       681483 (+0)         576
31         1009.00K 1       0       681484 (+1)         576
31         1009.00K 1       0       681485 (+1)         576
```

----

## Look out for Latency

Latency is the time difference between request and response.  The client sends a
command and gets a result back in 10ms.  We want this round trip to be as fast as
possible.
Really bad latency can trigger "Operation timed out" exceptions in your application.
There are two general latency sources:

1. Network - the network between the client and Redis can be congested.
2. Internal - Redis itself might have commands or internal operations
   which add significant latency.

### Network

You can see the current network latency easily:

```
$ redis-cli --latency
min: 0, max: 1, avg: 0.29 (632 samples)
```

This shows a minimum of 0ms and max of 1ms, averaging 290µs, latency to
my localhost server.  Ideal conditions.

You can also easily watch latency history, here with a default window of 15 sec:

```
$ redis-cli --latency-history
min: 0, max: 7, avg: 0.24 (1321 samples) -- 15.00 seconds range
min: 0, max: 256, avg: 0.55 (1280 samples) -- 15.01 seconds range
min: 0, max: 3062, avg: 3.86 (1051 samples) -- 15.98 seconds range
min: 0, max: 490, avg: 0.69 (1255 samples) -- 15.01 seconds range
```

You can see the first window looks pretty good, the second window had a
spike of 256ms, and the third had a spike of 3062ms (!).

I triggered these spikes by running `redis-cli debug sleep 0.5`.  Not
recommended in production.

### Internal

Redis also has a latency event and monitoring subsystem to track
commands execution latency and operations (like forking) which might
block command processing. Use the [LATENCY](https://redis.io/topics/latency-monitor)
commands to monitor and collect these events.  Some commands can be naturally
slow, see SLOWLOG below.

----
## Watch for Slow Commands

Because it is single-threaded, it's vitally important that all commands
to Redis process quickly or one slow command can block everyone else for
a significant amount of time.  Redis includes a configurable [SLOWLOG](https://redis.io/commands/slowlog)
command to watch for these bad apples.

My Redis is configured by Homebrew to log any commands that take longer than 10ms, a
sensible default.  Run this on your instance and see if you find anything suspicious:

```
$ redis-cli slowlog get 10
1) 1) (integer) 3
   2) (integer) 1492461257
   3) (integer) 11825
   4)  1) "LPUSH"
       2) "queue:default"
       3) "{\"queue\":\"default\",\"jid\":\"df55c4e27c48e63f0d5212b4\",\"class\":\"LoadWorker\",\"args\":[0],\"created_at\":1492461257.208411,\"enqueued_at\"... (33 more bytes)"
       4) "{\"queue\":\"default\",\"jid\":\"4989e31cea7ecf78e93b7f9f\",\"class\":\"LoadWorker\",\"args\":[1],\"created_at\":1492461257.2084169,\"enqueued_at... (34 more bytes)"
      [snip]
      32) "... (9971 more arguments)"
```

There are four parts to each entry: 3 is a unique identifier, 1492461257 is the timestamp
when it happened and 11825 is the number of microseconds for execution, 11.825ms.
The last part is the command with arguments.

I happen to know that entry is an LPUSH to the `default` queue of 10,000 jobs.  It's
a testcase for Sidekiq::Client's `push_bulk` API.  Since we're
enqueueing 10,000 jobs at once, it's not surprising that might take almost 12ms.

**It is safe to run SLOWLOG in production and highly encouraged.**  In
fact, I would set `slowlog-log-slower-than 2000` to log anything
greater than 2ms.  If you find the slowlog is constantly full, raise
that value until it doesn't have many entries **or redesign your system so it
doesn't run those slow commands**.  For instance, if you want to enqueue
10,000 jobs, perhaps you could call `push_bulk` 10 times with 1000 jobs
each, so each invocation only takes 1/10th as long.

## Extra Credit

When I was managing technical operations, my team was
responsible for monitoring our infrastructure.  We would do things like:

1. Write a cron job to dump the slowlog to a daily email if it is not empty.
  Treat any entries as issues to be investigated and fixed.
2. Set up a dashboard for the Redis server.  Have dedicated
   graphs for connected_clients, instantaneous_ops_per_sec, and used_memory_rss.
   Treat big changes in these graphs as incidents to be investigated.

Part of owning your infrastructure is monitoring its health proactively;
understanding these tools and having quick access to this data will be
invaluable when debugging failures and outages.

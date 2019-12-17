+++
title = "Workload Isolation with Queue Sharding"
date = 2019-12-17T10:55:37-08:00
+++

A number of customers have contacted me with a common problem:

> We run a multi-tenant system where our users can perform an action which
results in a huge number of jobs being enqueued. When this happens, other
users see significant delays in their jobs being processed while our
Sidekiq cluster works through the backlog for that one user.

The issue is this: if you give 100% of your resources to process that
user's backlog, 100% of your customers will feel the pain of that backlog
delay. For years I've recommended customers use a simple setup with three
queues: `critical`, `default` and `bulk`. If user A throws 100,000 jobs
into `bulk`, processing those jobs would be low priority and perhaps take
one or two hours.  That backlog will not block critical or default jobs **but** it will
delay any bulk processing by other users.

Generically, this issue is known as `workload isolation`. AWS, in
particular, has published a few articles on how they deal with this
problem in their services and they've highlighted an interesting
technique used to provide isolation between customers.

![shuffle sharding example](https://d1.awsstatic.com/legal/builders-library/Screenshots/shuffle-sharding-with-eight-workers.97e815152d06856351e6976ed33029414f1a7f99.png)

The key idea is known as [shuffle sharding](https://aws.amazon.com/builders-library/workload-isolation-using-shuffle-sharding/) but the technique is not specific to AWS, you can use it today with your Sidekiq cluster.
Go read that article, it's quite good.

## Queues and Processes

We'll use real numbers here to minimize confusion but you can
adjust these numbers for your own scale.

Note also that this technique is completely separate from Redis
sharding.
If you have 4 Redis shards, you have 4 Sidekiq clusters.
This queue sharding technique is specific to a single Sidekiq cluster
running against a single Redis instance.

We assume that operations which trigger high job volumes will go into a logical `bulk`
queue but in reality your app will enqueue those jobs into eight shards: bulk0 - bulk7.

You have 8 Sidekiq processes and each process will process `critical`,
`default` and 2 bulk shards.

```ruby
shards = 8
shards.times do |idx|
  other = idx.succ % shards
  "bundle exec sidekiq -q critical -q default -q bulk#{idx} -q bulk#{other}"
end
```

Now each user's operation should dynamically target a bulk shard.
If you have a random ID for the overall operation, you can do something as simple as:

```ruby
q = "bulk#{operationID % 8}"
100_000.times do |idx|
  # push 100,000 jobs to a bulk shard
  SomeWorker.set(queue:q).perform_async(idx)
end
```

Other bulk user operations should randomly select a shard also. They have a 1 in 8 chance of selecting the same shard but most of the time the operations will be isolated from each other.
Net result: if a user operation creates a large number of bulk jobs, this will only affect 12%
of other operations rather than 100% as we were seeing at the beginning. The trade off is that only two Sidekiq processes will be processing any one bulk shard.

Want faster processing?  Spread the jobs across two random shards. You
get 100% more processes but only increase your odds from 12% to 25%
that you will disrupt anyone.

That trade off is the crux: you might want more processes or fewer
shards to get that backlog processed quicker. 32 processes and 8 shards
will get you 4 processes for a queue. 16 processes with 4 shards will
also get you 4 processes for a queue but will mean that 1/4 of
operations will clash instead of 1/8. Only you can judge what's
appropriate for your app and budget.

## Conclusion

By sharding the `bulk` queue, we isolate our Sidekiq resources into buckets so
that any one bulk user operation can't monopolize all resources.  Ultimately
this is a trade off because it also naturally limits the thoroughput of
those operations: they can't use the full set of resources in production
to finish quicker. High priority operations still have the option to
utilize more than one bulk shard or target the `default` queue in order to
blast through a backlog with 100% of your resources.

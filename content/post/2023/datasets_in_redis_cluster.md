---
title: "Scaling Huge Transactional Datasets with Redis Cluster"
date: 2023-05-08T09:00:00-07:00
publishdate: 2023-05-08
lastmod: 2023-05-08
tags: []
---

Recently I made some minor changes to Sidekiq Enterprise 7.1 in order to greatly increase the scalability of the Rate Limiter feature.
Redis has a little-known feature which allows you to safely use `MULTI` transactions with multiple keys in a cluster.
This was a real learning experience for me so I thought other people might find this interesting.
<!--more-->

# Clustering a Cache

Redis is famously single-threaded: while you can have thousands of connections, only one can be operating on the dataset at a time.
While Redis is incredibly well tuned, this design decision presents a fundamental limitation in scalability for one Redis instance.
Redis has a Cluster mode which allows N Redis nodes to operate on a single, shared keyspace.
This is the traditional way to scale Redis to many CPUs and machines and most commonly used for massive caches.

All [Redis clients](https://github.com/redis-rb/redis-cluster-client#redis-cluster-client) use an algorithm to map a given key onto an node within the Cluster, e.g.

```
key-a -> node1
key-b -> node2
```

All Redis clients use the same algorithm so no matter which machine or CPU you are executing on, `key-a` will always map to `node1` as long as the set of nodes are the same.
In this manner, keys are spread evenly across all nodes in the Cluster.
If you have 1000 nodes and one of them goes down, 99.9% of the keyspace should still be available.
This is exactly how you want a massive data cache to operate.

# Transactions

Redis also allows you to operate transactionally on multiple data elements to ensure consistency using its `MULTI` command.
Sidekiq uses this command quite frequently:

```
MULTI do
  HSET element-a field value
  LPUSH element-a-queue message
end
```

But both of these data elements, element-a and element-a-queue, need to be stored on the same Redis node, otherwise we can't operate on them atomically.
And unfortunately since they are two different keys, they will map to two different nodes and the MULTI command will raise a `CROSSSLOT` error.
This is the root cause why Sidekiq has never supported Redis Cluster as its backing store.

# Hash Tagging
 
Sam Cochrane from [Buildkite](https://buildkite.com) brought [Hash tagging support](https://redis.com/blog/redis-clustering-best-practices-with-keys/) to my attention.
**Hash tagging allows you to map a set of keys to the same Cluster node.**
You do this by demarcating the portion of the key which should be used to map the key to a Node, using braces:

```
MULTI do
  HSET {element-a} field value
  LPUSH {element-a}-queue message
end
```

Since both keys now use the same hash tag, `element-a`, they will map to the same Node and the transaction will work!!!!!!

# Limitations

There are some drawbacks here:

"Global" data structures can't participate in the MULTI transaction.
Let's say I wanted to have a set of all element keys: [element-a, element-b, etc] so that a management screen could show all active elements.
I can't use `SADD elements element-a` within the MULTI transaction above because the global `elements` key won't map to the same Node as `element-a`.
I can run that command on its own, outside of the MULTI transaction, but now the application has a potential source of inconsistency.

Maybe I can't maintain a global set of elements, but could I scan for all elements in Redis?
Yes, but that requires scanning every node in the cluster.
If you have thousands of nodes and billions of elements, that scan becomes very expensive.

Essentially as your ability to scale the number of individual elements goes up, your ability to see and manage those elements goes down.
It's easy to manage a thousand elements.
It's very hard to manage a billion elements and every order of magnitude brings new challenges.

# Scaling Rate Limiting

Sam wrote to me and suggested that the Rate Limiting feature would be a good candidate for Hash tagging.
Unlike many other features, [Sidekiq Enterprise's Rate Limiting](https://github.com/sidekiq/sidekiq/wiki/Ent-Rate-Limiting) does not require access to any global data structures within Redis so
I was able to add Hash tags at the few points where limiters used transactions.
Starting with 7.1, you can configure the [Rate Limiter subsystem](https://github.com/sidekiq/sidekiq/wiki/Ent-Rate-Limiting#redis) to use a Redis Cluster and create millions or billions of rate limiters.
The only thing that won't work is the "Limits" tab in the Web UI; as we noted, the increase in scalability decreases the manageability.

Let me be clear: Sidekiq still does not support Clustering of its core data model
but this is a great example where a knowledgable customer helped me improve Sidekiq.

If you have a bug, feature or idea for improvement, please [open an issue](https://github.com/sidekiq/sidekiq/issues/new)!
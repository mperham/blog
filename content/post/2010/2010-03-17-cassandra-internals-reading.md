---
author: Mike Perham
categories:
- Software
date: 2010-03-17T00:00:00Z
tags:
- cassandra
title: Cassandra Internals -- Reading
url: /2010/03/17/cassandra-internals-reading/
---

![Cassandra logo][1]

In my [previous post][2], I discussed how writes happen in Cassandra and why they are so fast. Now we'll look at reads and learn why they are slow.

**Reading and Consistency**

One of the fundamental thereoms in distributed systems is [Brewer's CAP theorem][3]: distributed systems can have Consistency, Availability and Partition-tolerance properties but can only guarantee two. In the case of Cassandra, they guarantee AP and loosen consistency to what is known as *eventual consistency*. Consider a write and a read that are very close together in time. Let's say you have a key "A" with a value of "123" in your cluster. Now you update "A" to be "456". The write is sent to N different nodes, each of which takes some time to write the value. Now you ask for a read of "A". Some of those nodes might still have "123" for the value while others have "456". They will all eventually return "456" but it is not guaranteed when (in practice, usually just a few milliseconds). You'll see why this is important in a second.

Reads are similar to writes in that your client makes a read request to a single random node in the Cassandra cluster (aka the Storage Proxy). The proxy determines the nodes in the ring (based on the replica placement strategy) that hold the N copies of the data to be read and makes a read request to each node. Because of the eventual consistency limitations, Cassandra allows the client select the strength of the read consistency:

*   Single read -- the proxy returns the first response it gets. Can easily return stale data.
*   Quorum read -- the proxy **waits for a majority to respond with the same value**. This makes it much more difficult to get stale data (nodes would have to go down) but slower.

In the background, the proxy also performs *read repair* on any inconsistent responses. The proxy will send a write request to any nodes returning older values to ensure that the nodes return the latest value in the future. There are a number of edge cases here that I'm not clear how Cassandra deals with:

*   What if an even number of nodes reply, with half returning a value of "X" and the other half returning a value of "Y"? Since each column value is timestamped, presumably it will use the timestamp as a tie breaker.
*   What if two nodes return "X" with an old timestamp and one node returns "Y" with a newer timestamp? Does quorum override the clock?
*   What if the clocks on the cluster nodes are out of sync?

**Scanning ranges**

Cassandra works fine as a key/value store: you give it the key and it will return the value for that key. But this is often not enough to answer critical questions: what if I want to read all users whose last name starts with Z? Or read all orders placed between 2010-02-01 and 2010-03-01? To do this, Cassandra must know how to determine the nodes which hold the corresponding values. This is done with a *partitioner*. By default, Cassandra uses a *RandomPartitioner* which is guaranteed to spread the load evenly across your cluster but cannot be used for range scanning. Instead a ColumnFamily can be configured to use an *OrderPreservingPartitioner*, which knows how to map a range of keys directly onto one or more nodes. In essence, it knows which node(s) hold the data for your alphabetically-challanged users and for February's orders.

**Reading on an Individual Node**

So all of that distributed system nonsense aside, what does each node do when performing a read? Recall that Cassandra has two levels of storage: Memtable and SSTable. The Memtable read is relatively painless -- we are operating in memory so the data is relatively small and iterating through the contents is fast as possible. To scan the SSTable, Cassandra uses a row-level column index and bloom filter to find the necessary blocks on disk, deserializes them and determines the actual data to return. There's a lot of disk IO here which ultimately makes the read latency higher than a similar DBMS. Cassandra does provide some row caching which solves much of that latency.

That's a whirlwind tour of Cassandra's read path. Take a look at the [StorageConfiguration][4] wiki page for much more content on this subject. Next up, I'll discuss some of the various "tricks" Cassandra uses to solve the myriad of edge cases inherent in distributed systems.

 [1]: http://incubator.apache.org/cassandra/media/img/cassandra_logo.png
 [2]: /2010/03/13/cassandra-internals-writing/
 [3]: http://en.wikipedia.org/wiki/CAP_theorem
 [4]: http://wiki.apache.org/cassandra/StorageConfiguration

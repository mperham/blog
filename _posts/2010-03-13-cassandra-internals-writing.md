---
title: 'Cassandra Internals &#8211; Writing'
author: Mike Perham
layout: post
permalink: /2010/03/13/cassandra-internals-writing/
categories:
  - Software
tags:
  - cassandra
---
![Cassandra logo][1]

We&#8217;ve started using Cassandra as our next-generation data storage engine at [OneSpot][2] (replacing a very large Postgresql machine with a cluster of EC2 machines) and so I&#8217;ve been using it for the last few weeks. As I&#8217;m an infrastructure nerd and a big believer in understanding the various layers in the stack, I&#8217;ve been reading up a bit on how Cassandra works and wanted to write a summary for others to benefit from. Since Cassandra is known to have very good write performance, I thought I would cover that first.

First thing to understand is that Cassandra wants to run on many machines. From what I&#8217;ve heard, Twitter uses a cluster of 45 machines. It doesn&#8217;t make a lot of sense to run Cassandra on a single machine as you are losing the benefits of a system with no single point of failure.

Your client sends a write request to a single, random Cassandra node. This node acts as a proxy and writes the data to the cluster. The cluster of nodes is stored as a &#8220;ring&#8221; of nodes and writes are replicated to N nodes using a *replication placement strategy*. With the RackAwareStrategy, Cassandra will determine the &#8220;distance&#8221; from the current node for reliability and availability purposes where &#8220;distance&#8221; is broken into three buckets: same rack as current node, same data center as current node, or a different data center. You configure Cassandra to write data to N nodes for redundancy and it will write the first copy to the primary node for that data, the second copy to the next node in the ring *in another data center*, and the rest of the copies to machines in the same data center as the proxy. This ensures that a single failure does not take down the entire cluster and the cluster will be available even if an entire data center goes offline.

So the write request goes from your client to a single random node, which sends the write to N different nodes according to the replication placement strategy. There are many edge cases here (nodes are down, nodes being added to the cluster, etc) which I won&#8217;t go into but the node waits for the N successes and then returns success to the client.

Each of those N nodes gets that write request in the form of a &#8220;RowMutation&#8221; message. The node performs two actions for this message:

*   Append the mutation to the commit log for transactional purposes
*   Update an in-memory Memtable structure with the change

And it&#8217;s done. This is why Cassandra is so fast for writes: the slowest part is appending to a file. Unlike a database, Cassandra does not update data in-place on disk, nor update indices, so there&#8217;s no intensive *synchronous* disk operations to block the write.

There are several asynchronous operations which occur regularly:

*   A &#8220;full&#8221; Memtable structure is written to a disk-based structure called an SSTable so we don&#8217;t get too much data in-memory only.
*   The set of temporary SSTables which exist for a given ColumnFamily are merged into one large SSTable. At this point the temporary SSTables are old and can be garbage collected at some point in the future.

There are lots of edge cases and complications beyond what I&#8217;ve talked about so far. I highly recommend reading the Cassandra wiki pages for [ArchitectureInternals][3] and [Operations][4] at the very least. Distributed systems are hard and Cassandra is no different.

Please leave a comment if you have a correction or want to add detail &#8211; I&#8217;m not a Cassandra developer so I&#8217;m sure there&#8217;s a mistake or two hidden up there.

 [1]: http://incubator.apache.org/cassandra/media/img/cassandra_logo.png
 [2]: http://www.onespot.com
 [3]: http://wiki.apache.org/cassandra/ArchitectureInternals
 [4]: http://wiki.apache.org/cassandra/Operations
---
title: 'Cassandra Internals &#8211; Tricks!'
author: Mike Perham
layout: post
permalink: /2010/03/20/cassandra-internals-tricks/
categories:
  - Software
tags:
  - cassandra
---
In my previous posts, I covered how Cassandra [reads][1] and [writes][2] data. In this post, I want to explain some of the trickery that Cassandra uses to provide a scalable distributed system.

**Gossip**

Cassandra is a cluster of individual nodes &#8211; there&#8217;s no &#8220;master&#8221; node or single point of failure &#8211; so each node must actively verify the state of the other cluster members. They do this with a mechanism known as [gossip][3]. Each node &#8216;gossips&#8217; to 1-3 other nodes every second about the state of each node in the cluster. The gossip data is versioned so that any change for a node will quickly propagate throughout the entire cluster. In this way, every node will know the current state of every other node: whether it is bootstrapping, running normally, etc.

**Hinted Handoff**

In [writing][2], I mentioned that Cassandra stores a copy of the data on N nodes. The client can select a consistency level for a write based on the importance of the data &#8211; for example, ConsistencyLevel.QUORUM means that a majority of those N nodes must reply success for the write to be considered successful.

What happens if one of those nodes goes down? How do those writes propagate to that node later? Cassandra uses a technique known as [hinted handoff][4], where the data is written to anther random node X to be stored and replayed for node Y when it comes back online (remember that gossip will quickly tell X when Y comes online). Hinted handoff ensures that node Y will quickly match the rest of the cluster. Note that read repair would still eventually &#8220;fix&#8221; the old data if hinted handoff did not work for some reason but only once the client asked for that data.

Hinted writes are not readable (since node X is not officially one of the N copies) so they don&#8217;t count toward write consistency. If Cassandra is configured for three copies and two of those nodes are down, it would be impossible to fulfill a ConsistencyLevel.QUORUM write.

**Anti-Entropy**

The final trick up Cassandra&#8217;s proverbial sleeve is [anti-entropy][5]. AE explicitly ensures that the nodes in the cluster agree on the current data. If read repair or hinted handoff don&#8217;t work due to some set of circumstances, the AE service will ensure that nodes reach eventual consistency. The AE service runs during &#8220;major compactions&#8221; (the equivalent of rebuilding a table in an RDBMS) so it is a relatively heavyweight process that runs infrequently. AE uses a [Merkle Tree][6] to determine where within the tree of column family data the nodes disagree and then repairs each of those branches.

This is the last post in my series on Cassandra. I hope you enjoyed them! Please leave a comment if you have questions or if I&#8217;ve made an error above.

 [1]: /2010/03/17/cassandra-internals-reading/
 [2]: /2010/03/13/cassandra-internals-writing/
 [3]: http://wiki.apache.org/cassandra/ArchitectureGossip
 [4]: http://wiki.apache.org/cassandra/HintedHandoff
 [5]: http://wiki.apache.org/cassandra/ArchitectureAntiEntropy
 [6]: http://en.wikipedia.org/wiki/Hash_tree
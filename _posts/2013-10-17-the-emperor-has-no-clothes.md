---
title: The Emperor has no Clothes
author: Mike Perham
layout: post
permalink: /2013/10/17/the-emperor-has-no-clothes/
categories:
  - Software
---
&#8220;In theory, theory and practice are the same. In practice, they are not.&#8221; &mdash; Albert Einstein

The original Dynamo paper created a wave of interest in the [CAP theorem][1] and gave rise to the recent crop of distributed databases: Cassandra, Riak, et al. These systems are generally AP where C can be tuned to provide some guarantee of consistency, i.e. they do their best to provide CAP according to the application&#8217;s needs. For instance, you might have a cluster of 5 nodes where a write to the cluster will return success if 3 of the nodes acknowledge the write. The cluster will still be available even if two of the machines fail.

In theory they are a great way to ensure availability to your application in the face of network failures. In practice, I believe **these databases are so complex that they often provide less availability than a simpler CP system like a SQL database.**  
<!--more-->

  
Consider:

*   Network failure cases are legion
*   Integration testing of high availability systems is extremely complicated
*   Reasoning about and debugging failures becomes much harder
*   Adding N machines increases your odds of network failure N-fold

As the [recent series of Jepsen posts][2] show, even the most highly regarded of these systems have serious bugs in their handling of network failures. Cascading failure happens. Split brain happens. Distributed databases do not scale linearly vs a single system; having a 5 node cluster will not handle 5x the throughput of a single system so your costs will increase super-linearly and your chances of network failure increase 5x (and thus exposing those hard-to-test network failure bugs). Distributed databases are useful only if:

*   You need scale beyond what one system can provide
*   You are willing to accept the server and administration costs
*   You can test the network failure cases you wish to handle

My belief is simple: avoid distributed databases if possible. You will pay a heavy tax for their use.

 [1]: https://en.wikipedia.org/wiki/CAP_theorem
 [2]: http://aphyr.com/tags/jepsen
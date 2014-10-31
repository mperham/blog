---
title: Varnish on 32-bit systems
author: Mike Perham
layout: post
permalink: /2010/01/18/varnish-on-32-bit-systems/
categories:
  - Software
---
We run three small EC2 instances for content caching purposes at OneSpot. These systems are 32-bit machines with 1.7GB of RAM. Originally we figured even on a small system Varnish could flood a 100Mb line so we wouldn&#8217;t need a more expensive, large EC2 instance. This blog post explains why this turned out to be a poor choice.

Executive summary: Varnish really, really wants to run on a 64-bit system. Don&#8217;t run it on 32-bit systems if possible.

Varnish wants to memory map the entire cache. This means the entire cache needs to be able to fit into virtual memory. On a 64-bit system, VM is virtually unlimited. On a 32-bit system, processes usually have access to a maximum of 3GB of virtual memory. Since you also need to allocate stack space and other standard process requirements, in practice people don&#8217;t recommend more than 2GB of cache space for Varnish on 32-bit systems. Pretty small for a web content cache. If you want Varnish to use an entire disk for a cache, it must run on a 64-bit system.

We had a few minutes of outage recently due to this architecture. We read some [Varnish tuning tips][1] and decided to modify our default configuration. Specifically we raised the minimum thread count from 1 to 500. Because, after all, &#8220;* idle threads are cheap*&#8220;. But they are only cheap on 64-bit systems where allocating hundreds of MB for extra stack space is a no brainer! When we rolled out this change, the process ran out of memory and couldn&#8217;t allocate the extra threads. Klaxons went off and I rolled back the changes. Over the next few months, we&#8217;ll be upgrading our caches to 64 bit so that we don&#8217;t need to worry about sizing issues moving forward.

 [1]: http://kristian.blog.linpro.no/2009/05/25/common-varnish-issues/
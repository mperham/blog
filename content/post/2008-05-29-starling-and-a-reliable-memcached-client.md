---
author: Mike Perham
categories:
- Ruby
date: 2008-05-29T00:00:00Z
tags:
- memcached
- starling
title: Starling and a reliable Memcached client
url: /2008/05/29/starling-and-a-reliable-memcached-client/
---

We moved part of our [FiveRuns Manage][1] infrastructure to use Starling this week. I'm rapidly becoming a convert as it has proven to be simple, fast and reliable. The Starling 0.9.3 release is somewhat long in the tooth but GitHub has several Starling forks which contain performance improvements and bugfixes, including our own [fiveruns/starling][2] fork. Our fork has proven to be about 3 times faster than 0.9.3 in raw message processing speed.

More elusive has been the client library to use with Starling. Because Starling just uses the memcached protocol, any memcached client should be able to use Starling. The problem is that the most popular memcached client, Seattle.rb's memcache-client library, has several bugs in the latest 1.5.0 version:

1.  set() fails when the socket has been disconnected ([via Twitter][3])
2.  it does not retry if a socket operation fails ([via Will Bryant][4])
3.  it does not retry the current operation on another server if a server dies

The first two I fixed by applying the patches at the links above. The last one I found and fixed myself -- it's critical for fault tolerance. We run two Starling servers for redundancy and if one goes down, we wanted the clients to transparently fail over to the other. All three bugs have been fixed in our [fiveruns/memcache-client][5] project. If you use our client, please let me know. I'd love to hear success stories!

 [1]: http://fiveruns.com/products/manage
 [2]: http://github.com/fiveruns/starling/tree/master
 [3]: http://dev.twitter.com/2008/02/solving-case-of-missing-updates.html
 [4]: http://willbryant.net/software/2007/12/21/ruby-memcache-client-reconnect-and-retry
 [5]: http://github.com/fiveruns/memcache-client/tree/master

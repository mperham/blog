---
author: Mike Perham
categories:
- Ruby
- Software
date: 2009-01-14T00:00:00Z
title: Consistent Hashing in memcache-client
url: /2009/01/14/consistent-hashing-in-memcache-client/
---

One of the most important features needed to create a scalable memcached infrastructure is *consistent* hashing. I [recently added][1] consistent hashing to the Ruby memcache-client project and I want to take a moment to explain why this is important.

**The Naive Approach**

Memcached is simple in principle: just like a hashtable, a unique key maps to a value. This is simple when you have a single memcached server, but what do you do if you have two servers? Which server is the key/value pair stored on?

The naive approach is to hash the key to an integer and do a modulo based on the size of the server set. For a given key, this should return the same, random server from the set every time.

<pre lang="ruby">idx = Zlib.crc32(key) % servers.size
</pre>

This works great -- if the server set never changes.

**Where It All Goes Wrong**

Now our website is doing great and getting tens of hits per day so we find ourselves needing to add a new memcached server in order to handle the surge in traffic. We add the new server, restart our daemons and soon the database disk(s) grinds to a halt. *What happened?* When you change the server set, the modulo value for most of the key hashes changes. This means that memcache-client goes to the "wrong" server, the lookup misses and that expensive operation you are caching needs to be performed again. You essentially get a storm of recalculation as your cache contents shift from their old server to their new server.

**Enter the Continuum**

The better algorithm, instead of using modulo, uses a predefined continuum of values which map onto a server. We select N random integers (where N is around 100 or 200) for each server and sort those values into an array of N * server.size values. To look up the server for a key, we find the closest value >= the key hash and use the associated server. The values form a virtual circle; the key hash maps to a point on that circle and then we find the server clockwise from that point.

![The Virtual Continuum][2]

**Results**

Assume we have 3 memcached servers and want to add a fourth.  
The continuum approach will invalidate 1/4 or 25% of your keys.  
The modulo approach will invalidate 3/4 or 75% of your keys.

The more servers you have, the worse modulo performs and the better continuum performs.

**The Future**

I've checked in this change into GitHub but haven't released a new version yet. I'm waiting on one set of fixes and then I'll release 1.6.0 to RubyForge.

Tom White has a more in-depth explanation of [consistent hashing][3]. Thanks to him for the image above. I based my implementation on the explanation of [libketama][4].

 [1]: http://github.com/fiveruns/memcache-client/commit/7e0744387b4136a4915cd914e79aec2497d505dc
 [2]: http://weblogs.java.net/blog/tomwhite/archive/images/consistent_hashing_1.png
 [3]: http://weblogs.java.net/blog/tomwhite/archive/2007/11/consistent_hash.html
 [4]: http://www.last.fm/user/RJ/journal/2007/04/10/rz_libketama_-_a_consistent_hashing_algo_for_memcache_clients

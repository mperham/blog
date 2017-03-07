---
author: Mike Perham
categories:
- Ruby
date: 2009-06-16T00:00:00Z
title: memcached vs memcache-client Performance
url: /2009/06/16/memcached-vs-memcache-client-performance/
---

[memcached][1] is Evan Weaver's Ruby wrapper around the libmemcached C library and widely regarded as quite fast. After an hour of trying, I finally got a build of memcached to actually compile and install on my machine (the trick: you need to download the custom packages Evan links on his blog, nothing else seems to work). Here's the results:

<pre>== memcached 0.13 + libmemcached 0.25.4 versus memcache-client 1.7.4

                                     user     system      total        real
set:plain:noblock:memcached      0.090000   0.030000   0.120000 (  0.277929)
set:plain:memcached              0.220000   0.270000   0.490000 (  1.251547)
set:plain:memcache-client        0.610000   0.270000   0.880000 (  1.670718)
set:ruby:noblock:memcached       0.150000   0.020000   0.170000 (  0.309201)
set:ruby:memcached               0.300000   0.290000   0.590000 (  1.390354)
set:ruby:memcache-client         0.670000   0.270000   0.940000 (  1.713558)
get:plain:memcached              0.240000   0.270000   0.510000 (  1.169909)
get:plain:memcache-client        0.850000   0.270000   1.120000 (  1.885270)
get:ruby:memcached               0.270000   0.280000   0.550000 (  1.229705)
get:ruby:memcache-client         0.890000   0.260000   1.150000 (  1.861660)
multiget:ruby:memcached          0.190000   0.090000   0.280000 (  0.396264)
multiget:ruby:memcache-client    0.530000   0.100000   0.630000 (  0.901016)
missing:ruby:memcached           0.280000   0.290000   0.570000 (  1.254400)
missing:ruby:memcached:inline    0.300000   0.290000   0.590000 (  1.235122)
missing:ruby:memcache-client     0.570000   0.250000   0.820000 (  1.461293)
mixed:ruby:noblock:memcached     0.540000   0.620000   1.160000 (  2.429200)
mixed:ruby:memcached             0.580000   0.570000   1.150000 (  2.610819)
mixed:ruby:memcache-client       1.580000   0.540000   2.120000 (  3.632775)
</pre>

In most cases, memcache-client is within 33-50% of the performance of memcached. This is amazing for a (mostly) pure Ruby library performing a lot of network IO against a C library which has been tuned for speed! I hope that puts to bed any lingering doubts that memcache-client is slow.

Remember: if you are using Rails 2.3, just "gem install memcache-client" and Rails will pick up the latest version with all these performance improvements.

 [1]: http://github.com/fauna/memcached

---
author: Mike Perham
categories:
- Ruby
date: 2009-02-15T00:00:00Z
title: Memcache-client Performance
url: /2009/02/15/memcache-client-performance/
---

One email I get fairly regularly is "Why would I use memcache-client when the performance sucks?" Most people point me to Evan Weaver's BENCHMARKS file in his [memcached library][1] as proof that I should just close up shop.

His benchmarks, like all performance tests, are a snapshot in time -- they reflect a certain revision of the codebase. Specifically I assume his benchmarks reflect memcache-client 1.5.0. This version is about 18 months old and ships with Rails 2.x. Since 1.5.0, I've taken over the project and done a lot of tuning. Here's some numbers:

```
Testing 1.6.4
                                     user     system      total        real
set:plain:memcache-client        0.740000   0.270000   1.010000 (  2.123806)
set:ruby:memcache-client         0.800000   0.270000   1.070000 (  2.215323)
get:plain:memcache-client        0.920000   0.270000   1.190000 (  2.270049)
get:ruby:memcache-client         1.000000   0.260000   1.260000 (  2.473615)
multiget:ruby:memcache-client    0.600000   0.090000   0.690000 (  1.055913)
missing:ruby:memcache-client     0.710000   0.260000   0.970000 (  2.069232)
mixed:ruby:memcache-client       1.800000   0.540000   2.340000 (  4.637675)

Testing 1.5.0 (as shipped in Rails 2.2.2)
                                     user     system      total        real
set:plain:memcache-client       28.450000   0.400000  28.850000 ( 30.025903)
set:ruby:memcache-client        29.180000   0.420000  29.600000 ( 30.803760)
get:plain:memcache-client       28.640000   0.410000  29.050000 ( 30.201306)
get:ruby:memcache-client        29.350000   0.430000  29.780000 ( 30.942459)
multiget:ruby:memcache-client   30.750000   0.250000  31.000000 ( 31.462482)
missing:ruby:memcache-client    28.470000   0.410000  28.880000 ( 30.046172)
mixed:ruby:memcache-client      58.590000   0.840000  59.430000 ( 61.951933)
```

You can see the exact benchmark code in [memcache-client][2]/`test/test_benchmark.rb`. It's basically just a direct copy of Evan's benchmarks, modified to run as part of the test suite. This is running in Ruby 1.8.6 p114 on a 2.2Ghz Core 2 Duo. The numbers for Ruby 1.9.1 are approx 20% faster.

The latest numbers are not orders of magnitude slower but rather merely some percentage off. So while Evan's numbers are correct for an old version of memcache-client, they do not represent the current state of the project. It's my belief that memcache-client 1.6.x has perfectly acceptable performance and in return, you get a mostly pure Ruby codebase that works on JRuby, Ruby 1.8 and Ruby 1.9. I hope this clears up any confusion; let me know if you have further questions!

 [1]: http://github.com/fauna/memcached
 [2]: http://github.com/mperham/memcache-client

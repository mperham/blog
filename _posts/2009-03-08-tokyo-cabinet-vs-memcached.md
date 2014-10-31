---
title: Tokyo Cabinet vs Memcached
author: Mike Perham
layout: post
permalink: /2009/03/08/tokyo-cabinet-vs-memcached/
categories:
  - Ruby
---
[Tokyo Cabinet][1] bills itself as a next-generation DBM. Like BerkeleyDB, TC gives you low-level database operations and allows you to build your own very fast data access operations. Unlike BDB, TC has several functional layers on top of TC which provide network access, schema-less document-oriented storage (a la CouchDB) and supported bindings for many languages. This project is an infrastructure nerd&#8217;s dream!

One interesting feature of its network access layer, Tokyo Tyrant, is support for the memcached protocol, which means we can access it via memcache-client! I downloaded tokyocabinet and tokyotyrant and built and installed them. I then started a tyrant server like so:

<pre>ttserver -port 45000 data.tch
</pre>

Let&#8217;s try some simple benchmarks:

<pre lang="ruby">require 'rubygems'
require 'benchmark'

gem 'memcache-client', '1.7.0'
require 'memcache'

memcached = MemCache.new(['localhost:11211'], :timeout => nil)
tokyo = MemCache.new(['localhost:45000'], :timeout => nil)

Benchmark.bm(20) do |b|
  b.report 'memcached-write' do
    10000.times do |idx|
      memcached.set idx.to_s, idx.to_s*100, 120, true
    end
  end
  b.report 'tokyo-write' do
    10000.times do |idx|
      tokyo.set idx.to_s, idx.to_s*100
    end
  end
  b.report 'memcached-read' do
    10_000.times do
      memcached.get(rand(100).to_s, true)
    end
  end
  b.report 'tokyo-read' do
    10_000.times do
      tokyo.get(rand(100).to_s)
    end
  end
end
</pre>

Results:

<pre>user     system      total        real
memcached-write       0.380000   0.200000   0.580000 (  1.308354)
tokyo-write           0.470000   0.200000   0.670000 (  1.663922)
memcached-read        0.410000   0.170000   0.580000 (  1.354334)
tokyo-read            0.470000   0.180000   0.650000 (  1.688558)
</pre>

Not too shabby at all! Keep in mind that TC doesn&#8217;t support time-based key expiration and is persistent. Memcached is designed to be a memory-only cache, so while the underlying semantics of the two are somewhat different, the same basic operations are available to memcache-client. In fact, you can even theoretically use TC as your Rails cache by configuring the mem\_cache\_store to point to your Tokyo Tyrant server instead of memcached!

 [1]: http://www.igvita.com/2009/02/13/tokyo-cabinet-beyond-key-value-store/
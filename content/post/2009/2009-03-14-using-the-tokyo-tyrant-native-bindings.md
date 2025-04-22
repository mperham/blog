---
author: Mike Perham
categories:
- Ruby
date: 2009-03-14T00:00:00Z
title: Using the Tokyo Tyrant native bindings
url: /2009/03/14/using-the-tokyo-tyrant-native-bindings/
---

My previous examination of Tokyo Tyrant's memcache protocol support showed how you can use memcache-client directly with TT. John Mettraux has created [Ruby bindings][1] for TT's own native client for ultimate speed. Let's take a look at how this affects performance:

```ruby
require 'rufus/tokyo/tyrant'

db = Rufus::Tokyo::Tyrant.new('localhost', 1978)
Benchmark.bm(20) do |b|
  b.report 'native-write' do
    10_000.times do |idx|
      db[idx.to_s] = idx.to_s*100
    end
  end
  b.report 'native-read' do
    10_000.times do
      db[rand(100).to_s]
    end
  end
end
```

```
user     system      total        real
native-write             0.150000   0.220000   0.370000 (  1.079804)
native-read              0.160000   0.210000   0.370000 (  1.093927)
memcache186-write        0.530000   0.210000   0.740000 (  1.750988)
memcache186-read         0.580000   0.200000   0.780000 (  1.830207)
memcache191-write        0.430000   0.230000   0.660000 (  1.528519)
memcache191-read         0.410000   0.220000   0.630000 (  1.591678)
```

I've included the memcache protocol times right after for comparision. Notice the system time is basically unchanged but the user time is dramatically lower. This is the overhead of the memcache-client's pure Ruby networking layer. Ruby is a great language but its networking implementation is not blindingly fast. There's definite improvement in Ruby 1.9.1 but still nowhere near bare metal.

 [1]: http://github.com/jmettraux/rufus-tokyo

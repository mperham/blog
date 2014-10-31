---
title: Background Job Processing Overhead
author: Mike Perham
layout: post
permalink: /2013/06/30/background-job-processing-overhead/
categories:
  - Ruby
---
I wrote a simple benchmark which loads 20,000 empty jobs into Redis and then times how long it takes one Sidekiq process to finish those jobs running on my 2012 MacBook Air. The times are unsurprising (lower is better):  
<!--more-->

  
JRuby 1.7.4 &#8211; 38 sec (using java 1.7.0_09)  
MRI 2.0.0-p195 &#8211; 50 sec  
MRI 1.9.3-p374 &#8211; 56 sec

Just as a point of comparison, I tried the latest version of Resque too:

MRI 2.0.0-p195 &#8211; 286 sec (Resque 1.24.1, one process)

Defaults were used where possible, I used Sidekiq 2.13.0 with 25 worker threads and the worker was a no-op class:

<pre lang="ruby">class LazyWorker
  include Sidekiq::Worker
  def perform
  end
end
</pre>

To reproduce the benchmark:

1. Install redis.  
2. redis-cli flushall  
3. git clone git://github.com/mperham/sidekiq  
4. cd sidekiq/myapp  
5. bundle  
6. bundle exec ruby bench.rb (this just loads 20k jobs into redis)  
7. bundle exec sidekiq

**Conclusions**

1. Even with the GIL, MRI can perform 400 jobs/sec.  
2. In my experience, JRuby continues to be 20-30% faster than MRI in real world benchmarks. This was true a year ago with 1.6.x vs 1.9.3 and still true today with 1.7.x vs 2.0.0.  
3. I didn&#8217;t try Rubinius 2.0.0-dev because rbenv installs it in Ruby 1.8 mode (what year is this!?).
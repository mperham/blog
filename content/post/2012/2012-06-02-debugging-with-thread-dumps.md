---
author: Mike Perham
categories:
- Ruby
date: 2012-06-02T00:00:00Z
title: Debugging with Thread Dumps
url: /2012/06/02/debugging-with-thread-dumps/
---

I recently upgraded [TheClymb][1] to use the Redis 3.0 gem. When I did this, our test suite halted mid-spec and pegged the CPU at 100%. I suspected an infinite loop but how do you determine where the loop is? A naive approach might use a binary search with print statements but I realized I could do something more effective: dump thread backtraces for the current process.

I wrote this trap recently to help people debugging their code when using [Sidekiq][2], which is multi-threaded, but never expected it to be useful in a single-threaded scenario! Put this in your test helper:

```ruby
trap 'TTIN' do
  Thread.list.each do |thread|
    puts "Thread TID-#{thread.object_id.to_s(36)}"
    puts thread.backtrace.join("n")
  end
end
```

Now just find the PID for your ruby process and run "kill -TTIN \_PID\_". Once I ran that, I realized the infinite loop was deep in the redis client and a few lines up was the tell-tale sign of a monkeypatch in one of our Rails initializers:

```
/Users/mperham/.rvm/gems/ruby-1.9.3-p125@theclymb3/gems/redis-3.0.0/lib/redis/client.rb:242:in `logging'
/Users/mperham/.rvm/gems/ruby-1.9.3-p125@theclymb3/gems/redis-3.0.0/lib/redis/client.rb:166:in `process'
/Users/mperham/.rvm/gems/ruby-1.9.3-p125@theclymb3/gems/redis-3.0.0/lib/redis/client.rb:78:in `call'
/Users/mperham/src/clymbhub/config/initializers/redis.rb:16:in `block in call'
/Users/mperham/.rvm/gems/ruby-1.9.3-p125@theclymb3/gems/metriks-0.9.7.1/lib/metriks/timer.rb:47:in `call'
/Users/mperham/.rvm/gems/ruby-1.9.3-p125@theclymb3/gems/metriks-0.9.7.1/lib/metriks/timer.rb:47:in `time'
/Users/mperham/src/clymbhub/config/initializers/redis.rb:15:in `call'
/Users/mperham/.rvm/gems/ruby-1.9.3-p125@theclymb3/gems/redis-3.0.0/lib/redis.rb:1185:in `block in sismember'
/Users/mperham/.rvm/gems/ruby-1.9.3-p125@theclymb3/gems/redis-3.0.0/lib/redis.rb:36:in `block in synchronize'
```

We had patched Redis 2.x to count operations for Graphite monitoring and this patch broke in 3.x. Once I fixed it, everything went back to working as normal.

 [1]: http://www.theclymb.com/invite-from/mperham
 [2]: http://mperham.github.com/sidekiq/

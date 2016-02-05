---
title: "Happy 4th Birthday, Sidekiq"
author: Mike Perham
layout: post
permalink: /2016/02/05/happy-birthday-sidekiq/
---

Four years ago today I shipped Sidekiq 0.5.0.  110 versions later, it's
still changing every day.  Pretty amazing.  So what's new?

## Sidekiq Enterprise

Sidekiq Enterprise gained two major new features this month.

### Historical Metrics

Sidekiq Enterprise can now send the global counts you see at
the top of the Web UI to Statsd for monitoring and
display within your metrics dashboard. [Read More][0]

{% highlight ruby %}
STATSD = ::Statsd.new(...)

Sidekiq.configure_server do |config|
  config.save_history(STATSD)
end
{% endhighlight %}

### Multi-Process

If you start N Sidekiq processes, each process is completely separate
and must be managed individually.

Sidekiq Enterprise has a new binary, `sidekiqswarm`,
which will spin up N child Sidekiq processes.  Those child processes
will share memory with the parent process, leading to increased memory efficiency.
If a child process dies, the parent will restart it immediately.
Quieting and stopping the parent does the same to all children so you
don't need to manage individual child processes.  With this new
multi-process support, it's really simple to scale Sidekiq across all
cores.  [Read More][1]

{% highlight ruby %}
COUNT=4 bundle exec sidekiqswarm -e production
{% endhighlight %}

## Sidekiq Pro

Until today you had to be running reliable fetch in order to pause
queues.  This is no longer required!  Anyone running Sidekiq Pro 3.x can now
pause queues.

{% highlight ruby %}
q = Sidekiq::Queue.new
q.pause!
sleep 10
q.unpause!
{% endhighlight %}

[Read More][2]

## Sidekiq

Sidekiq gained support for an ActiveJob-style `set` method, to set options
dynamically:

{% highlight ruby %}
SomeWorker.set(queue: 'high').perform_async(1, 2, 3)
{% endhighlight %}

Also, the Web UI now shows a tag next to any process which is quiet (has
received the USR1 signal). [Read More][3]

## Rails

When you buy [Sidekiq Pro or Sidekiq Enterprise][4], part of the deal is that
I can work to improve Sidekiq **and** the Ruby ecosystem.  I've
recently spent some time simplifying Rails 5 and cutting out unnecessary
gem dependencies.  I'll have another blog post about that work next
week.

Until then, ciao!

[0]: https://github.com/mperham/sidekiq/wiki/Ent-Historical-Metrics
[1]: https://github.com/mperham/sidekiq/wiki/Ent-Multi-Process
[2]: https://github.com/mperham/sidekiq/blob/master/Pro-Changes.md
[3]: https://github.com/mperham/sidekiq/blob/master/Changes.md
[4]: http://sidekiq.org

---
title: "Sidekiq and Upstart"
author: Mike Perham
layout: post
permalink: /2015/07/16/sidekiq-and-upstart
published: true
---

The best and most reliable way to manage multiple Sidekiq processes is with Upstart.
Many developers know little to nothing about Upstart so I wanted to write up how to
integrate Sidekiq with Upstart.  With Upstart doing the hard work, it becomes easy
to manage deployments with Capistrano or another similar tool.

## Starting Sidekiq

The Sidekiq repo has [example .conf files](https://github.com/mperham/sidekiq/tree/master/examples/upstart) you can use as a template to create your
own services.  Customize the .conf files as necessary and place them in `/etc/init`;
they tell Upstart when and how to start the associated processes.

The `workers` service is a "fake" service which knows how to start/stop N sidekiq
processes.  Upon machine boot, Upstart will start `workers` which will start those N
processes.  Within `workers.conf` we've declared how many processes we want to start:

{%highlight ruby %}
env NUM_WORKERS=2
{% endhighlight %}

If you want to quickly shut down all Sidekiq processes, run `stop workers`. Start
them back up with `start workers`.  Of course you can do both with `restart workers`.
It literally can't be any easier!

The `sidekiq` service is an "instance" service, allowing you to create N processes.
It requires an index parameter to define which instance you are controlling:

{%highlight ruby %}
start sidekiq index=0
start sidekiq index=1
stop sidekiq index=2
etc...
{% endhighlight %}

## Deployment

Deployment should do two things: quiet Sidekiq as early as possible and restart
as late as possible.

### Quieting Sidekiq

During a deployment, we want to signal Sidekiq to stop processing jobs as early as possible so
Sidekiq has as much time as possible to finish any jobs in progress.  We do this by sending
each process the USR1 signal, here's a Capistrano task which does that:

{%highlight ruby %}
task :quiet do
  on roles(:worker) do
    puts capture("sudo pgrep -f 'sidekiq' | xargs kill -USR1")
  end
end
{% endhighlight %}

You can also use Upstart's `reload` command to do the same:

{%highlight ruby %}
reload sidekiq index=X
{% endhighlight %}

Note that `workers` does not support reload since it doesn't map to a single process so we have to
use that pgrep hack.

### Restarting Sidekiq

Restarting is easy: `restart workers`.  This will actually stop and then start the processes.

{%highlight ruby %}
task :restart do
  on roles(:worker) do
    puts capture("sudo restart workers")
  end
end
{% endhighlight %}

## Notes

* We don't need to daemonize.  Modern daemons should never daemonize themselves.
* We don't need PID files.  PID files are legacy from years ago and their use should
signal that something is wrong.
* We don't need to specify our own log files.  Sidekiq will output to stdout; Upstart will direct stdout to
a file within `/var/log/upstart/` **and** automatically rotate those log files
for you - no logrotate setup necessary!

In other words, stop reinventing the wheel and let the operating system do the hard work for you!
I hope this makes your Sidekiq deployment cleaner and more stable.

---
author: Mike Perham
date: 2015-10-14T00:00:00Z
published: true
title: Should you use Celluloid?
url: /2015/10/14/should-you-use-celluloid/
---

I've used Celluloid from day one.  More importantly I've evanglized
Celluloid and advised Rubyists to use it.  So it came as a shock to
several people that I [recently overhauled Sidekiq][1] to remove Celluloid.
What does that mean?  I must be a huge hypocrite!

<figure style="float: right;">
  <img src="https://raw.github.com/celluloid/celluloid-logos/master/celluloid/celluloid.png" width="360px" />
</figure>

**Engineering is about trade offs.**

* To make something easier or safer to use, create an abstraction layer.
* To make something faster, remove one or more abstraction layers.

Multithreading is extremely hard to get right and the APIs that Ruby
exposes for threading are rudimentary at best.  **Celluloid is an
abstraction layer designed to make multithreading easier and
safer to develop.**  If you are building your own threading, use an
abstraction layer!  Celluloid is fantastic, Michael Grosser's
[parallel][0] gem is great, etc.

Using threads typically gets you a huge increase in throughput per process.
This increase usually dwarfs any overhead which an abstraction layer introduces.

But there's an exception for every rule.  Sidekiq has gone from a
young, quickly moving project to a mature, stable project over the last two
years.  Celluloid makes redesigning a system easier but Sidekiq doesn't
really need that ease anymore.  Celluloid does add a fixed overhead to
every job execution, which thousands of apps running billions of jobs pay every day.  The
overhead is small but noticeable when running no-op jobs:

![sidekiq 4 metrics](/images/sidekiq4.png)

Celluloid is also Sidekiq's biggest dependency.  By removing it, I
shrink the surface area of 3rd party gems I have to monitor and stay
compatible with.  Not a problem if you are using Celluloid in your app
(you can just lock versions) but Sidekiq can't stay on an old version
without limiting people who are trying to use Celluloid APIs within Sidekiq.

## Conclusion

My opinion has not changed: **if I were building a new concurrent system today, I'd
start with Celluloid**.  The abstraction is quite valuable when
building something new but Sidekiq itself is at a point where it can
do without that abstraction layer.

[0]: https://github.com/grosser/parallel
[1]: https://github.com/mperham/sidekiq/pull/2593

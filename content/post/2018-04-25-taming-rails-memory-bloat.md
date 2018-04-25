+++
title = "Taming Rails memory bloat"
date = 2018-04-25T09:00:00-07:00
+++

MRI, the standard Ruby interpreter, has a serious problem with memory bloat in large Rails apps.
It's quite common for me to see Sidekiq processes which are 1-2GB in RSS or even larger!
It turns out that a large part of this memory usage is due to memory fragmentation: MRI uses
the OS's memory allocator by default (on Linux, almost always GNU glibc),
which seems to work poorly with Ruby's memory allocation patterns.

[Nate Berkopec went into great detail](https://www.speedshop.co/2017/12/04/malloc-doubles-ruby-memory.html) about Ruby memory bloat.  His blog post is a much deeper dive.

One important note: this behavior is specific to GNU glibc on Linux.
OSX and BSD appear to have better quality allocators, not as prone to fragmentation.

## Reducing Arenas

The major cause of fragmentation appears to be the large number of glibc memory arenas in heavily multi-threaded programs.
"Heavily multi-threaded" -- sound familiar?  That's Sidekiq.
People on Heroku have discovered that to reduce memory, they should set `-c 5` which reduces the number of threads from 25 to 5.
That reduces the "heavily multi-threaded" trigger and leads to less bloat.

But the better way is to reduce glibc's memory arena count.
Set this environment variable in your dynos, systemd unit files or however you start Sidekiq:

```
MALLOC_ARENA_MAX = 2
```

You should see a noticable reduction in memory usage after rebooting.

## Using jemalloc

Switching Ruby's allocator to jemalloc looks to be an even more effective solution... for a price.
One example:

![jemalloc](https://www.mikeperham.com/images/jemalloc.jpg)

The results have been described as "miraculous".
That's **40GB** worth of Sidekiq processes shrunk to **9GB**, a 4x reduction.
Much of this space is fragmented memory and switching to jemalloc fixes this wasted space.
Seeing R14 errors on Heroku?
[Just throw a little jemalloc in there](https://www.levups.com/en/blog/2017/optimize_ruby_memory_usage_jemalloc_heroku_scalingo.html).

The issue with jemalloc is that it can cause problems in different environments.
For example, it's had compatibility issues with Alpine Linux so if you are running Ruby in Alpine-based Docker images, you could see segfaults or stack overflows.
If you want to try jemalloc, be sure you test your app thoroughly before pushing to production.

[Redis pulled in jemalloc explicitly to reduce memory fragmentation, with
big success](http://oldblog.antirez.com/post/everything-about-redis-24.html):

> "Since we introduced the specially encoded data types Redis started suffering from fragmentation. We tried different things to fix the problem, but basically the Linux default allocator in glibc sucks really, really hard. [...] Every single case of fragmentation in real world systems was fixed by this change, and also the amount of memory used dropped a bit."

## Trying jemalloc

Want to try jemalloc on OS X?
My installed rubies seem to hardcode the memory allocator so you might need to build MRI with jemalloc specifically.

```bash
brew install jemalloc
# Now install Ruby with jemalloc enabled
#   with rbenv:
#     RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install 2.5.1
#   with ruby-install
#     ruby-install ruby-2.5.1 -- --with-jemalloc
chruby ruby-2.5.1
MALLOC_CONF=stats_print:true irb
```

If you see lots of arcane stats print out upon exiting IRB, jemalloc is running in your Ruby.
Make sure to verify your Ruby is actually running jemalloc; it is easy to misconfigure and have it silently fall back to the default allocator.

## Conclusion

I'm convinced that tuning glibc is a no brainer.
Set `MALLOC_ARENA_MAX=2` everywhere you start Sidekiq and enjoy your extra memory.

Using jemalloc is more complex.
Memory bloat has been a serious issue in large scale Rails apps as far back as I can remember in Ruby.
I wish ruby-core would pull in jemalloc as the default allocator but they seem content with glibc.
Major Rails apps like [GitLab](https://gitlab.com/gitlab-org/omnibus-gitlab/issues/3073), Discourse and [Mastodon](https://github.com/tootsuite/mastodon/issues/7257) plan to or have already integrated jemalloc but each app has to do it separately.
If you have a large Rails app, integrate jemalloc and see significant improvements, please [open a Ruby issue](https://bugs.ruby-lang.org/issues/new) with graphs before and after.
Let's give ruby-core all the data they need to make the right decision.

Ruby-core jemalloc issues: [13524](https://bugs.ruby-lang.org/issues/13524), [9113](https://bugs.ruby-lang.org/issues/9113)

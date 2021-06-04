+++
title = "Something For Nothing"
date = 2019-07-19T10:27:11-07:00
+++

<img style="float: right; padding: 10px" src="/images/freebeer.jpg" alt="freebeer"/>

Do you like free things? Would you like to get something for nothing?
Are you a Sidekiq user? If you answered yes to these questions, I have a
case study in how one customer effectively got Sidekiq Enterprise for
free.

One Friday morning, two engineers jumped into my weekly Happy Hour to ask me about a Sidekiq problem they were having.

> "We have two Sidekiq dynos with 40 threads each: we find that after about 5 minutes, they are only using about 20 threads; shouldn't all 40 threads pick up jobs? The jobs perform image processing."

```
bundle exec sidekiq -c 40
```

They were using two Heroku `performance-m` dynos, which cost $250/month each.

## MRI has a Limit

If you are a Ruby expert, you might already have an idea of what's going
wrong but the crux is this: **one MRI process will only use a single core**.
Now consider **image processing is often CPU intensive**.
They were crushing a single core on each performance-m dyno while the rest of the cores sat there doing nothing.
Those extra 20 threads weren't lazy -- they literally couldn't get any CPU time scheduled!

## Multi-Process to the Rescue

The answer was easy since they were a Sidekiq Enterprise customer:

```
bundle exec sidekiqswarm -c 20
```

`sidekiqswarm` is a special binary which [forks a Sidekiq process for
each core on the
dyno](https://github.com/mperham/sidekiq/wiki/Ent-Multi-Process). We reduce the thread count so each core
isn't crushed by image processing.

In summary:

| | Before | After |
---|---|---
Dynos | 2 | 1
Threads | 80 (2 x 40) | 80 (4 x 20)
Core usage | 50% | 100%
Cost | $500 | $250 + $179
Savings | | $71/mo

Before they had 1 busy core and 3 idle cores on each dyno.  Now they
have 4 busy cores and can spin down the second dyno instance to save
$250/mo. Since Sidekiq Enterprise costs $179/mo, this change paid for
Sidekiq Enterprise, saved an additional $71/mo and ensured that future worker dynos are fully utilized.

If you are using Performance dynos and not using Sidekiq Enterprise, you
are likely paying for too many dynos.  [Purchasing Sidekiq Enterprise](https://billing.contribsys.com/sent/new.cgi) and
using `sidekiqswarm` to reduce your dyno count may cover the entire
purchase price.  You get all the Sidekiq Pro and Enterprise features
effectively for free.  Each sale has a 14 day money back guarantee if
you want to try it today.

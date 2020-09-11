---
title: "What's New in Sidekiq, 2020 edition"
date: 2020-09-10T18:58:52-07:00
publishdate: 2020-09-10
lastmod: 2020-09-10
tags: []
---

> "Your work doesn't matter if no one knows about it" -- some marketing
> genius

COVID and wildfires have made this year hellish and really difficult to
focus. I sympathize with all of my fellow engineers trying to maintain
systems and improve apps while dealing with our rapidly changing
society. Be kind to each other. ❤️

Let's distract ourselves with a Sidekiq family update.

## Sidekiq 6.1

The most visible change in Sidekiq 6.1.x are dark mode CSS improvements
to make things a bit more readable for eyes over 30.

Dependencies got a bit of polish:

* `jquery` was upgraded to the latest 1.x
* the `rack-protection` gem was removed, CSRF protection was implemented inside Sidekiq itself
* adjustments were made for a deprecated API in `redis-rb` 4.2.

## Sidekiq Pro 5.2

Some server-side changes were made to the commercial gem server to
make `bundle install` **much** faster on Bundler 2.2+. In my testing it
goes from 10 sec to 2.5 sec.

Poison pills (jobs which kill the Sidekiq process) are now
gracefully handled: any orphaned job which is rescued 3 times in 72 hours will be killed rather than retried. This fixes the infinite job loop: `run, die, rescue, retry`.

Statsd metrics have been cleaned up a bit to better reflect modern
Statsd usage with tags, possibly leading to cost savings due to
fewer unique metric names. This can lead to broken dashboards if you are
graphing an old metric, sorry in advance for any breakage!

## Sidekiq Enterprise 2.1

`sidekiqswarm` was updated to add as much systemd integration as
possible so it can notify systemd on successful bootup, etc. You just
need to mark your [systemd service as `Type=notify` per the example](https://github.com/mperham/sidekiq/blob/3f54edb4497ee727b947effaff46d88302270a84/examples/systemd/sidekiq.service#L33).

You can now set `SIDEKIQ_PRELOAD_APP=1` to optionally preload your application
before forking children in `sidekiqswarm`. This can save a **huge** amount of memory (~20-40%)
but may cause problems due to socket or thread sharing across processes; be careful
and test cautiously.

Enterprise got the same Statsd cleanup that Pro got.

Finally, a nice option for ActiveJob users: ActiveJobs can now
use Enterprise's unique jobs feature directly:

```ruby
class MyJob < ApplicationJob
  sidekiq_options unique_for: 10.minutes

  def perform(*args)
  end
end
```

And of course plenty of minor bug fixes. Want to know more? The changelogs mention the precise GitHub issue with
all the detail. See {,Pro-,Ent-}Changes.md in the [Sidekiq repo](https://github.com/mperham/sidekiq).

## What's Next

I'm looking into Ruby 3.0's new Ractor subsystem to see if Sidekiq can
use it. So far it is looking too early, Ractor still needs a lot of
polish before it will be useful to Rails apps.

---
title: "Introducing Sidekiq 8.0"
date: 2025-03-05T12:09:25-08:00
publishdate: 2025-03-10
lastmod: 2025-03-10
tags: []
---

After six months of hard work, I'm thrilled to announce the general availability of Sidekiq 8.0! 🥳🎉

## Status

Sidekiq is used by thousands of Ruby applications around the world to scale job processing up to billions of jobs/day.
Current Sidekiq Enterprise customers are reporting a grand total of 1,806,671,058,604 jobs processed, almost two trillion, with my largest customer executing up to 250,000 jobs/sec.
Got a Ruby/Rails app and want to try out Sidekiq? See [Test Drive](#test-drive) to get started quickly.

Over the next few weeks I plan to publish several blog posts which go deep into the changes described below.
Subscribe to my [RSS feed](https://www.mikeperham.com/index.xml) if you want to see those posts when they are published.

## What's New?

### Profiling

Profiling allows you to see how long your code takes to execute, allowing you to find unexpected performace problems. Sidekiq 8.0 makes job profiling in production **so easy**:

```ruby
MyJob.set(profile: "mike").perform_async(...args...)
```

If you tag a job with a `profile` attribute, Sidekiq will run it within [Vernier](https://vernier.prof) and store the report in Redis.
You access the profile report in the new `Profiles` tab of the Web UI.
For more details, refer to the [Profiling](https://github.com/sidekiq/sidekiq/wiki/Profiling) wiki page.

### Web UI

The Web UI has undergone a significant overhaul.
For years, we relied on Bootstrap 3.3.7 but now we've removed the dependency altogether.
It was an absolute delight to discover that modern CSS, with its support for variables, can be used without a build process.
Many thanks to [@antoinem](https://github.com/antoinem) for contributing the majority of this work.
The look and feel of the pages have improved dramatically, take a look at this beauty!

![webui](/images/webui_80.png)

Sidekiq::Web's routing code has been extensively rewritten and a new configuration API has been introduced for web extensions to use.

Lastly, a significant performance regression was discovered while testing Sidekiq's profiling support.
Pages now render faster because they no longer load 20 YAML files on every request.

### Iteration

Job iteration is a new feature that enables you to divide long-running jobs into smaller chunks of work.
With this feature, you can construct jobs that can safely execute for days, provided that each iteration step takes less than 30 seconds.
For instance, consider a job that performs data migration for millions of accounts, where each step migrates 100 accounts.
This feature was introduced in version 7.3 and has undergone refinement in the subsequent months.
I strongly encourage all Sidekiq users to review the [Iteration](https://github.com/sidekiq/sidekiq/wiki/Iteration) wiki page to learn more.

### Metrics

Job runtime metrics now support displaying data for 24/48/72 hours, allowing you to observe multi-day usage patterns.
Previously data was limited to 8 hours.

### Requirements

Redis 7.0 is the minimum required version.
Sidekiq also officially supports Valkey and DragonflyDB, providing users with options in terms of datastore provider.

Ruby 3.2 is now the minimum Ruby version supported.
Rails 7.0 and later versions are also supported.

Sidekiq does not require Rails, unlike many modern job systems which require Active Job.
Sidekiq can be used by any Ruby application whether using Rails, [Hanami](https://hanamirb.org), [Sinatra](https://sinatrarb.com), [Roda](http://roda.jeremyevans.net), or no framework at all.
We like providing options!

### Commercial

Sidekiq Pro and Enterprise 8.0 will be released soon.

### Test Drive

Want to take Sidekiq for a test drive on your local machine? If you can run Docker containers, you can run Valkey (an open source clone of Redis) in seconds:

```
# add this line to ~/.zshrc or ~/.bashrc
alias valkey="docker run -p 6379:6379 valkey/valkey:latest"

# run this anytime to start valkey locally
valkey

# On a Mac with Homebrew? Run this:
brew install valkey
brew services start valkey
```

Now follow the directions in https://github.com/sidekiq/sidekiq/wiki/Getting-Started to give Sidekiq a try.

## ...and so much more!

These are the main highlights but there are many smaller tweaks and fixes.
See the [Changelog](https://github.com/sidekiq/sidekiq/blob/main/Changes.md#800) for more detail.
I hope you find a valuable improvement or feature to love here.
Keep on 'kiqing! ❤️
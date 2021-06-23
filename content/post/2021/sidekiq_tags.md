---
title: "Using Tags with Sidekiq Jobs"
date: 2021-06-23T15:08:02-07:00
publishdate: 2021-06-23
lastmod: 2021-06-23
tags: []
---

A customer recently opened issue to point out a bug in Sidekiq's tag
filtering support and I realized: **I haven't told people that tags
exist**. **Oops.** Here is your notification. 😁

[Sidekiq 6.0.1](https://github.com/mperham/sidekiq/blob/master/Changes.md#601) added support for per-job tags. Tags are an Array of Strings
within the job payload. Maybe you want to tag the sports related to a given job:

```ruby
class SomeWorker
  include Sidekiq::Worker
  sidekiq_options tags: ['alpha']
```

There's plenty of ideas for job tagging:

* active locale or user language
* customer or account ID
* a 'manual' tag indicating jobs created using Rails console

In the Web UI you can see tags and, in Sidekiq Pro, **click on them to see all jobs
with that tag**.

For example, assume we have a bunch of jobs which are associated with different sports.
First we'll create a bunch of jobs with random tags:

```ruby
sports = [:⚽️, :🏈, :⛳️, :⚾️, :🏀, :🎾, :🏐, :🥊, :🎳, :🏓]
100.times do
  SimpleWorker.set(tags: sports.sample(2)).perform_async("abc")
end
```

In Redis, tags are an Array within each job's JSON payload.

```json
{
  "class": "SimpleWorker",
  "args": ["abc"],
  "tags": ["⚽️", "🏈"],
  "queue": "default"
}
```

On the Retries and Dead tabs, we can see each tag formatted as a blue label
next to the job type.

![alljobs](/images/2021-tags-alljobs.png)

In Sidekiq Pro, the tags are clickable and will use Pro's filtering support to show just
jobs with that tag. Click a soccer ball and you'll see all jobs tagged with it.
The filter isn't very smart; it looks for any substring match within the
job's JSON payload -- make your tags unique or you can get false positives.
That's why I like to use emoji: they are unusual but short and easy to read.

![alljobs](/images/2021-tags-filter.png)

Tags can make sets of jobs easier to find and manage within Redis. Have a
creative use for tags? Have an idea to improve them? [Open a
issue](https://github.com/mperham/sidekiq/issues/new) and
let me know.

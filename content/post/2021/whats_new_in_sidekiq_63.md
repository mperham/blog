---
title: "What's New in Sidekiq 6.3"
date: 2021-11-07T09:00:00-07:00
publishdate: 2021-11-07
lastmod: 2021-11-07
tags: []
---

I'm happy to announce the general availability of Sidekiq 6.3 here at Rubyconf 2021!
Since Sidekiq 6.2 in March we've passed 110 million downloads on Rubygems.org and added a number of nice new features.
Let's dive in!

## Sidekiq::Job

One consistent issue in communication with the Sidekiq community is the nebulous term `worker`.
Are you talking about a process? A thread? A type of job?
Vagueness breeds confusion and frustration.
I encourage developers to stop using the term `worker` and use `include Sidekiq::Job` in your job classes.
Of course `Sidekiq::Worker` will be supported for the foreseeable future for backwards compatibility.

```ruby
class SomeJob
  include Sidekiq::Job
  sidekiq_options ...
  def perform(*args)
  end
end
```

## ActiveJob Compatibility

ActiveJob's `set` API allows you to dynamically change job options.
When I saw it, I said "Why didn't I think of that?!" *smacks forehead*

Sidekiq 4.1 first introduced support for ActiveJob's `set` API.
Sidekiq 6.3 adds support for the `wait` and `wait_until` options as an alternative to `perform_at` or `perform_in`.
```ruby
MyJob.set(wait: 5.minutes).perform_async(1,2,3)
MyJob.set(wait_until: 5.days.from_now).perform_async(1,2,3)
```
We also added support for `queue_as :foo` as an alternative to `sidekiq_options queue: :foo`.
By supporting more and more of the ActiveJob API natively, we make the decision of "should I use ActiveJob or native Sidekiq?" easier.

## Rails Logger

Sidekiq's stdout now includes any logging from `Rails.logger`.
Remove any logging hacks you might have in your initializer and see if it Just Works™ now.
A specific thank you to @key88sf who helped me understand and track down the issue.

## Speedy Scheduler

GitLab submitted an optimized job scheduler which reduces Redis overhead by
up to 45% when scheduling jobs with large fleets of worker processes. A
really detailed, interesting writeup with more info can be [found here](https://gitlab.com/gitlab-com/gl-infra/scalability/-/issues/1179).

## Bulk Perform

If you need to create a lot of jobs to parallelize some task, `Sidekiq::Client.push_bulk` has existed for years.
We recently landed a higher-level wrapper API, `perform_bulk` which can be called directly from your Job class.
Pass an Array of Arrays for the individual job arguments; this will create three SomeJob instances and direct them to a lower priority queue:
```ruby
SomeJob.set(queue: "low").perform_bulk([[1], [2], [3]])
```
There's no size limit. By default, jobs are created and pushed in batches of 1000.

## Modern JavaScript

The Web UI's javascripts hadn't been touched in five years so I felt it time to modernize things a bit.
jQuery has been removed and the Web UI's scripts updated to use vanilla JavaScript.
One less thing to upgrade and one less source of CVEs. **WARNING**:
existing Web UI extensions which use jQuery might break since the page does
not supply jQuery anymore.

## Metrics Tagging

A Sidekiq Pro customer wanted to tag their job metrics based on the associated tenant.
Sounds like a great idea to me!
Sidekiq Pro's Statsd metrics now allows you to dynamically calculate any options, including tags, for the job metrics.
```ruby
# add to your initializer
Sidekiq::Server::Middleware::Statsd.options = ->(klass, job, q) do
  {tags: ["worker:#{klass}", "queue:#{q}"]}.tap do |h|
    h[:tags] << "tenant:#{job['tenant_id']}" if job["tenant_id"]
  end
end
```

## Miscellenia

Among lots of other tweaks, a race condition leading to queue stoppage on JRuby was fixed.
See the [changelog](https://github.com/mperham/sidekiq/blob/main/Changes.md#630) for even more detail.
Thanks for your continued support and keep 'kiqing!

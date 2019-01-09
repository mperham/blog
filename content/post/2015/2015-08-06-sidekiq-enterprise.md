---
author: Mike Perham
date: 2015-08-06T00:00:00Z
published: true
title: Sidekiq Enterprise
url: /2015/08/06/sidekiq-enterprise/
---

After many months of development and preparation, I'm proud to announce the newest
member of the Sidekiq family: **Sidekiq Enterprise**.  Sidekiq Enteprise
is targeted at large companies and businesses which are building and scaling their
operations with Sidekiq. It offers a whole new level of functionality
beyond what Sidekiq and Sidekiq Pro contain.

### What's New?

Four major new features:

#### Rate Limiting

Many Sidekiq users and customers have asked how to throttle or limit
their concurrency so a 3rd party API is not crushed by a huge number
of Sidekiq workers at the same time.  The new `Sidekiq::Limiter` API
allows you to declare and enforce rate limits across all your Ruby
processes, Sidekiq or not:

{{< highlight ruby >}}
# Allow up to 50 concurrent operations to the ERP service
ERP_LIMITER = Sidekiq::Limiter.concurrent(:erp, 50)

def perform(...)
  ERP_LIMITER.within_limit do
    Erp.do_something
  end
end
{{< / highlight >}}

The Limiter API allows you to limit based on concurrency or a rate limit
(e.g. 5 ops per sec).

If the operation cannot be executed due to the rate limit, it will raise
an error by default.  If this error is raised within a Sidekiq job, Sidekiq
will catch the error and reschedule the job to execute in the near future.

The Web UI has a new "Limits" tab containing a overview of registered limiters
along with usage metrics or history for each.

Documentation: [Rate Limiting][0]

#### Periodic Jobs

Possibly the most popular 3rd party plugins are ones which add cron job-like
functionality.  Cron is also a common single point of failure since you typically
pick one machine to run cron jobs.

Sidekiq Enterprise offers an officially supported solution for periodic jobs.
Jobs are created according to the specified schedule and any Sidekiq process can pick up the job.
As a side benefit, your system will no longer have that cron machine as a single point of failure.
It's dead simple to register a periodic job:

{{< highlight ruby >}}
# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.periodic do |mgr|
    mgr.register "* * * * *", MinutelyWorker, retry: 1
    mgr.register "*/4 * 10 * *", OddTimedWorker, queue: 'critical'
  end
end
{{< / highlight >}}

Your Worker must take no arguments.

The Web UI has a new "Cron" tab containing an overview of registered periodic jobs
along with their recent execution history.

Documentation: [Periodic Jobs][2]

#### Unique Jobs

> "How do you catch a unique rabbit?"  
> "Unique up on him!"

Sidekiq Enterprise's new unique jobs support will automatically de-duplicate
any jobs already pending within Redis.  If you create a job every time your
user presses a button, you might not want a storm of clicks to create a storm of jobs.

To activate the feature, add this line:

{{< highlight ruby >}}
# config/initializers/sidekiq.rb
Sidekiq::Enterprise.unique! unless Rails.env.testing?
{{< / highlight >}}

Your workers must declare their uniqueness TTL with the `unique_for` option:

{{< highlight ruby >}}
class MyWorker
  include Sidekiq::Worker
  sidekiq_options unique_for: 10.minutes

  def perform(...)
  end
end
{{< / highlight >}}

The uniqueness will remain in effect until the job is successfully processed or the TTL expires.
Uniqueness is based on `(class, args, queue)` so you **can** push the same class/arguments
to two different queues.

Documentation: [Unique Jobs][5]

#### Leader Election

If you have a swarm of N Sidekiq processes, how can you run some code
on a single Sidekiq?  Many customers schedule a special job to run over and
over but if there's a Redis networking issue, the job can be lost and the cycle
broken.  With Sidekiq Enterprise you can run an infinite loop on a
single Sidekiq "leader" process, elected randomly from your processes.  If the
leader disappears, a follower will be promoted to leader within a minute.

Documentation: [Leader Election][1]

### Onboarding

Each Sidekiq Enterprise customer gets a one hour onboarding video chat session with me to help
with any questions they might have and discuss any problems they might see in their
application.  I can help optimize Sidekiq for your application and environment.

### Licensing

Sidekiq Pro's low price means I cannot accept license changes which the lawyers at larger
corporations often demand.  These corporations can now purchase Sidekiq Enterprise
and negotiate custom terms.

As part of this release, my lawyer has drawn up a new commercial license for Sidekiq Pro
and Sidekiq Enterprise.  New customers will use those licenses.

### Pricing

Sidekiq Enterprise is priced on a sliding scale, based on number of workers running in
your production environment.  Pricing is $1750/yr per 250 workers.

* 250 workers - $1750/yr
* 251-500 workers - $3500/yr
* More?  Volume discounts available.

A worker is a thread within a Sidekiq server process.  Ten processes with the default
concurrency of 25 = 250 workers.

Existing Pro subscribers can [contact me][4] to upgrade to Enterprise for the
prorated difference in price.

Older Pro lifetime customers will need to [purchase a new Enterprise subscription][3]
in order to upgrade.

### Purchasing

Many large companies have contacted me privately, asking if they can purchase
without a credit card.  Sadly, until now my answer was "no" because I
didn't have any other purchase workflow.  Today I'm happy to say that
companies [can purchase Sidekiq Enterprise][3] via the more traditional
quote/purchase order/invoice workflow.  Because of its lower price, Sidekiq Pro
remains credit card only.

### Sidekiq Pro

Sidekiq Pro is now the entry-level commercial version, with unlimited workers for $950/yr.
This unmetered pricing remains a great value and something I want to maintain for smaller
startups out there with limited funding.  Purchasing is via credit card only but is completely
automated so you can purchase and have Sidekiq Pro running in minutes.

### sidekiq.org

The [sidekiq.org](http://sidekiq.org) website has been completely redesigned for the Enterprise release.

## Conclusion

Sidekiq Enterprise offers not only a whole new set of features for serious Sidekiq users
but also legal and support options important to large companies.

My goal here is to offer a product for all types of users: from hobbyists using Sidekiq
to startups using Sidekiq Pro and larger companies using Sidekiq Enterprise.  I hope
one of them fits your needs too.

[0]: https://github.com/mperham/sidekiq/wiki/Ent-Rate-Limiting
[1]: https://github.com/mperham/sidekiq/wiki/Ent-Leader-Election
[2]: https://github.com/mperham/sidekiq/wiki/Ent-Periodic-Jobs
[3]: https://billing.contribsys.com/sent/new.cgi
[4]: mailto:mike&#40;contribsys.com?subject=Enterprise%20Upgrade
[5]: https://github.com/mperham/sidekiq/wiki/Ent-Unique-Jobs

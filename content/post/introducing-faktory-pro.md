+++
title = "Introducing Faktory Pro"
date = 2018-12-01T10:13:45-08:00
draft = true
+++

I'm happy to announce Faktory Pro, my commercial version of [Faktory](https://github.com/contribsys/faktory), is now available for purchase.
Faktory is my next generation background job system which brings Sidekiq functionality to **all programming languages**.
If you want background jobs in Python, JavaScript, PHP, Go, Ruby, or Rust, Faktory can work with them all!
It gives you a standard job interface and conventions useful for all languages.

![faktory ui](/images/faktory-ui.png)

## Why Jobs?

I believe background jobs are the best architectural pattern for scaling typical
business apps to many machines.  Sidekiq has been enormously successful
because it implements that pattern and adds opinionated conventions
which make the average developer's life much easier:

* A standard mechanism for implementing and creating a unit of work
* A standard process for error handling with automatic retries and backoff
* "All-in-one" packaging so the base package includes everything necessary: client API, worker process, management APIs, and a beautiful Web UI translated to 25 languages

If you want to build and maintain your own low-level infrastructure, Faktory is not
for you. If you want to build and scale a traditional business app as quickly and
painlessly as possible, Faktory is designed for you.

## Features

This initial launch includes these features but **the Pro feature list here will grow over time**.
Notably I will implement as many of the [commercial Sidekiq features](https://sidekiq.org) as possible.

1. [Cron jobs](https://github.com/contribsys/faktory/wiki/Pro-Cron) - kick off jobs on a regular schedule.
2. [Redis Gateway](https://github.com/contribsys/faktory/wiki/Pro-Redis-Gateway) - expose Redis to the network so you can take backups, set up a replica, etc.
3. [Expiring jobs](https://github.com/contribsys/faktory/wiki/Pro-Expiring-Jobs) - configure jobs to expire if they have not successfully processed within some time interval

Future features might include metrics, batches, unique jobs, encryption, Web UI search, etc.
Faktory's different architecture means some features aren't possible but enables others that Sidekiq couldn't do well, like queue throttling.
I'm exciting to see what new things are possible!


## Pricing

Faktory Pro is a server you run and is priced *per production instance* at $149/mo for the first server and $49/mo for each additional server.
Each Faktory Pro server can handle thousands of jobs per second under
normal conditions.
Testing, staging and development instances are unlimited and free.
For the price of one consultant-hour per month, you get a well-maintained and well-supported feature-rich job system.

You can **[buy Faktory Pro](https://billing.contribsys.com/fpro/new.cgi)** right here.
Got questions?
Check out the [wiki documentation](https://github.com/contribsys/faktory/wiki), [open an issue](https://github.com/contribsys/faktory/issues/new) or [jump into the chatroom](https://gitter.im/contribsys/faktory/) and say hi!

+++
date = "2017-10-23T07:00:00-07:00"
title = "The Future of Background Jobs"
+++

Whether sending an email, adding an item to your cart or tracking an
impression, modern businesses can be modeled as a series of business
transactions.  I believe that a good background job framework is the
best way to execute these transactions and scale your business applications.
across many machines.  A good background job framework gives you:

* a simple API for defining and calling jobs
* automatic error handling and retry logic
* an interface for monitoring, debugging and introspection

These jobs become much easier to reason about and debug when they
all use similar calling conventions, logging and execution environment.

> In fact, I would argue that the current Serverless trend is
(background jobs - devops + price).  Squint a bit and a serverless
function call looks a bit like a background job invocation: both are, at
their core, asynchronous function calls into your app logic.

For the last five years, I've created and polished Sidekiq, Sidekiq Pro
and Sidekiq Enterprise as best as I can, adding features and functionality
that scale (in the case of a few customers) to billions of jobs per day.

But Sidekiq has two major constraints:

1. The datastore is Redis, with all its advantages and disadvantages
1. Almost all functionality is implemented in the Ruby worker process, limiting Sidekiq to Ruby

What if we could have a system that:

1. scales to thousands of jobs per second?
2. enables polyglot teams -- can be used with any programming language?
3. provides those useful tools and metrics for monitoring and debugging?

Sidekiq has been very successful but there's nothing Ruby-specific
about its conventions; almost all programming languages can benefit from a
similar tool.  Tomorrow, I'm going to introduce you to my new open source
project which aims to do all of this: **Faktory**.

![faktory](/images/faktory.png)

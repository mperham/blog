---
title: "Introducing Sidekiq 7.0"
date: 2022-10-27T10:08:17-07:00
publishdate: 2022-10-27
lastmod: 2022-10-27
tags: []
---

I'm proud to announce, after nearly a year of work, Sidekiq 7.0 is now available.
This release is our biggest, most splendiforous release ever!

# What's New?

## Metrics

One thing I know: everybody loves big beautiful graphs!
Sidekiq 7.0 has a major new feature for tracking and visualizing job execution times.
Big thanks to @adamlogic of Rails Autoscale for implementing the new graphs and I hope you'll agree he did a fantastic job.

![metrics](https://github.com/mperham/sidekiq/raw/main/examples/metrics.png)

The Metrics system is covered in more detail [in its own blog post](https://www.mikeperham.com/2022/10/27/sidekiq-7.0-metrics/).

But wait, that's not all! Adam also reimplemented the Dashboard graphs using [Chart.js](https://chartjs.org) to replace Rickshaw/D3.js and bring the Web UI javascripts into the 2020s.
Truly he is a Sidekiq rockstar!

## Embedding

Sidekiq can now be embedded within another process in order to share memory and simplify deployments.
Instead of needing a 500MB Sidekiq process and a 500MB Puma process, now you might have a 600MB Puma process with Sidekiq running inside.
There are some caveats and footguns here so this is definitely more of an advanced feature.
Caveat developer!

Embedding is covered in more detail [in its own blog post](https://www.mikeperham.com/2022/10/27/sidekiq-7.0-embedding/).

## Refactoring and New APIs

Lots of internal Sidekiq APIs have been refactored or changed in some way to support these new features. If you maintain a Sidekiq plugin, you really really should test it against Sidekiq 7.0.

**Middleware** should now include `Sidekiq::ClientMiddleware` or `Sidekiq::ServerMiddleware`.
Sidekiq 6.5 has these modules also so you may choose to only support Sidekiq 6.5+ in future releases of your middleware. Once you include the module, your middleware should call `redis` or `logger` instead of `Sidekiq.redis` or `Sidekiq.logger`.

## Requirements

Strict argument checking is now enabled by default. Sidekiq will raise an error if you pass a Symbol or generic Ruby object into `perform_async` because they do not serialize correctly into JSON.
This has long been a source of frustration and debugging time for users, better to be upfront about this design decision. From the beginning, Sidekiq has used plain JSON as its job format, for interoperability with all programming languages and environments.

Sidekiq 7.0 now requires Redis 6.2+. That's a huge jump from 4.0 to 6.2 but Redis Labs has made a lot of changes to Redis commands recently and v6.2 is really necessary to start using the new commands. In 7.1, I'll update Sidekiq to use those new commands.

I also worked with @_byroot to migrate Sidekiq to the `redis-client` gem which uses the new [RESP3 protocol](https://github.com/antirez/RESP3/blob/master/spec.md) found in Redis 6.0+.
The newer protocol provides precise data types for responses, meaning the Ruby client code is greatly simplified.
There are a few compatibility issues between the old and new client; test carefully if you use `Sidekiq.redis` in your code.

Sidekiq 7.0 requires Ruby 2.7+. Sidekiq 7.0 supports Rails 6.0+. Both are several years old so this should not be controversial.

## Deprecations and Removals

Sidekiq 7.0 removes the Delayed extensions and support for redis-namespace. Neither have been recommended for years now.

With the release of Sidekiq 7.0, Sidekiq 5.x is no longer supported.
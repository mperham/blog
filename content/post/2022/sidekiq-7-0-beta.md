---
title: "Sidekiq 7.0 Beta now Available"
date: 2022-09-27T15:17:08-07:00
publishdate: 2022-09-27
lastmod: 2022-09-27
tags: []
---

Yesterday I released the first public beta of Sidekiq 7.0. This is a major new release with
several huge new features, several features removed, APIs refactored and updated requirements.

* Job Performance Metrics!
* Embedded mode!
* Capsules!
* Strict args!

But with all these [awesome new features](https://github.com/mperham/sidekiq/blob/7-0/docs/7.0-Upgrade.md), we refactored a **LOT** of internal APIs and likely broke a bunch of things. In other words, we really need people to test it and open issues in order to get a smooth 7.0 rollout.

## How to Get the Beta

Bundler makes you ask for the exact version:

```ruby
gem "sidekiq", "7.0.0.beta1"
```

or specifically opt into the beta with the `--prerelease` flag. Allow 7.x versions:

```ruby
gem "sidekiq", "<8"
```

and then run:

```
bundle install --prerelease
```

## Commercial Considerations

There is no compatible version of Sidekiq 7.x for Sidekiq Pro or Sidekiq Enterprise yet.
If you use Pro or Ent, **please lock your app to Sidekiq 6.x** as described below so you don't accidentally pick up 7.x.
I will announce new versions of Sidekiq Pro and Ent in the next few weeks.

## How Not to Get the Beta

If you do not want to risk breaking things, please make sure your Sidekiq version is locked to a major version.
Here's how to lock to 6.x versions:

```ruby
gem "sidekiq", "<7"
```

## How You Can Help

[I need feedback](https://github.com/mperham/sidekiq/issues/new?template=bug_report.md). Try running your app with Sidekiq 7.0b1 and open an issue with any problems you encounter. I would be happy to help you and adjust Sidekiq to lessen the impact of these breakages. Your feedback will help me help others with the same issue.
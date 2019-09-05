+++
title = "Welcome to Sidekiq 6.0"
date = "2019-09-03T09:00:00Z"
+++

I'm happy to announce that Sidekiq 6.0, Sidekiq Pro 5.0 and Sidekiq
Enterprise 2.0 are now generally available after nine months of work by
various contributors! 🎉🎂

## No More Daemonizing

Sidekiq 6.0 no longer offers the ability to run as an circa-1990s init.d-style daemon by removing the `logfile`, `pidfile` and
`daemonize` command line flags.
For a decade, all major Unix systems have offered init tooling that handle these concerns automatically for the developer and sysadmin.
For the last five years [I've blogged about and recommended against](/2014/09/22/dont-daemonize-your-daemons/) using these flags and
Sidekiq has provided [example systemd and upstart configuration files](https://github.com/mperham/sidekiq/tree/master/examples) since day one.
No more excuses, good riddance.

## Logging

Sidekiq's logging subsystem was overhauled by Andrew Babichev to allow pluggable logging
formatters, allowing the user to configure JSON-formatted log output in
production, for instance.

```ruby
Sidekiq.configure_server do |config|
  config.log_formatter = Sidekiq::Logger::Formatters::JSON.new
end
```

See `sidekiq/logger` for implementation details.

## ActiveJob integration

I recently added the ability for ActiveJobs to use the `sidekiq_options`
method like any normal `Sidekiq::Worker` to control Sidekiq features.
This makes it  easier to tailor Sidekiq's retry subsystem to each
individual ActiveJob's needs.

```ruby
class ExampleJob < ActiveJob::Base
  queue_as :critical
  sidekiq_options retry: 5, backtrace: 10

  def perform(*args)
  end
end
```

## Upgrade Requirements

Like Rails 6.0, Sidekiq 6.0 has upgraded platform requirements:

* Ruby 2.5+
* Redis 4.0+

Your Redis provider should have documentation on how to migrate your
Redis instance to a supported version.

## Twitter

You may or may not have noticed but I've deleted my Twitter account.
I can't interact with people as easily but it's debatable whether that is a feature or a bug.
I'm still lurking in various Ruby places, Mastodon, /r/ruby, some Slack groups, etc and you can always find me
via email. I strongly encourage Sidekiq users to join me at my weekly [Happy
Hour](https://sidekiq.org/support.html).  I get to meet you and learn your needs, you get to learn
Sidekiq straight from me!

## Wrapup

That's the quick overview, a few changes but mostly Sidekiq has been stable!
I hope these changes make Sidekiq more useful and reliable than ever to you.
The actual Upgrade notes can be found here:

* [Sidekiq 6.0](https://github.com/mperham/sidekiq/blob/master/6.0-Upgrade.md)
* [Sidekiq Pro 5.0](https://github.com/mperham/sidekiq/blob/master/Pro-5.0-Upgrade.md)
* [Sidekiq Enterprise 2.0](https://github.com/mperham/sidekiq/blob/master/Ent-2.0-Upgrade.md)

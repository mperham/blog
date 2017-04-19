+++
date = "2017-04-24T09:00:00-07:00"
title = "Hello Sidekiq 5.0"
draft = true
+++

<figure style="float: right;">
 <img src="/images/50.jpg"/>
</figure>

After a few months of work, I'm happy to announce that Sidekiq 5.0 is
now available.  Sidekiq 5.0 refactors the core job processor to work better
with Rails 5 and includes a few breaking changes that have been pending for a
while.

## What's New?

### Rails 5 native!

Sidekiq::Processor has been redesigned to work well
with Rails 5.0's Executor.  The Executor is a new API which needs
to wrap any use of Rails code; it automatically handles code reloading,
database connection management and any other callbacks.  Before now,
Sidekiq had middleware to clean up database connections but
this is no longer necessary with the Executor.

Note that Sidekiq 5.0 will still work with Rails 4.0+.

### Bad JSON, no problem!

Sidekiq now explicitly handles malformed job payloads which cannot be
parsed as valid JSON.  This is usually due to pushing jobs to Redis via
other languages.  Invalid jobs are immediately sent to the Dead set so
they can be manually examined.  Previously these payloads were discarded
or needed to be removed from Redis manually.

### Right-to-Left Languages

![bidi](/images/bidi.png)

The Web UI can now natively render RTL (right-to-left) languages like
Arabic, Hebrew, Persian and Urdu.  This brings language support from 21
to 25 languages and another billion or so potential Sidekiq users!
Change your browser to request one of those languages
and the Web UI will render in that language.

### Cleanup

The `delay` APIs are now disabled by default, since they pollute
`Class` and can lead to overly large job payloads.  You can re-enable
them if your application uses that API.

The quiet signal has been changed from USR1 to TSTP, which is available in JRuby
and better reflects the intent: Threads SToP.  USR1 will still work but is
deprecated. Sidekiq 4.2.9+ also supports TSTP so you can port your
deployment scripts to use the new signal without risking a major version bump
at the same time.

Support for Ruby 2.0, Ruby 2.1 and Rails 3.2 is dropped.

## Conclusion

Please see the [5.0 upgrade notes](https://github.com/mperham/sidekiq/blob/master/5.0-Upgrade.md) for more detail and how to upgrade safely.

**Thank you to all my [Sidekiq Pro and Sidekiq Enterprise](http://sidekiq.org) customers for
ensuring the long-term support and maintenance of Sidekiq.  Support OSS software
and your infrastructure vendors so we can support you!**

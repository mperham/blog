---
author: Mike Perham
date: 2016-02-09T00:00:00Z
title: Kill Your Dependencies
url: /2016/02/09/kill-your-dependencies/
---

<figure style="float: right;">
  <img style="border: solid white 0px;" src="http://wookiehangover.github.io/dependency-injection-for-fun-and-profit/img/dependency-graph2.png" width="400px" />
</figure>

This post talks about Ruby but it's true of every language community: Python, JavaScript, Java, etc.  The scourge of dependencies spares no one.

This is a dependency visualization of every Rails app I've ever used.  Does any of this
sound familiar:

* Gemfile with 100s of entries.
* Test gems loading in production.
* Each Rails process takes 100s of megabytes of RAM.

The Rubygems system is commendable for how easy it makes packaging up
Ruby for others to reuse.  But that very ease means it's also quite easy for
those gems to pull in other gems transitively, leading to Rails apps
which "download the Internet" and have hundreds of dependencies.

When you publish a Rubygem, every one of your dependencies transitively
becomes a dependency for any app using your gem.  This multiplies the
impact of bugs in those gems.

### The curious case of mime-types

The `mime-types` gem [recently optimized its memory usage](https://github.com/mime-types/ruby-mime-types/issues/94)
and saved megabytes of RAM.
Literally every Rails app in existence can benefit from this optimization because Rails depends on
the mime-types gem transitively: `rails -> actionmailer -> mail -> mime-types`.

In other words, this gem wasn't used by your app.  It wasn't used by Rails
directly.  It wasn't used by ActionMailer directly.  It was used deep in the bowels of the ActionMailer
implementation **and it was using far too much memory**.  Every single
Rails app in existence was using 10MB too much due to this issue.

## App Developers, Listen Up!

Every dependency in your application has the potential to bloat your
app, to destabilize your app, to inject odd behavior via monkeypatching
or buggy native code.
When you are considering adding a dependency to your Rails app, it's a
good idea to do a quick sanity check, in order of preference:

1. Do I really need this at all?  Kill it.
1. Can I implement the required minimal functionality myself?  Own it.

If you need a gem:

1. Does the gem have a native extension?  Look for pure ruby alternatives.
1. Does the gem transitively pull in a lot of other gems?  Look for
   simpler alternatives.

Gems with native extensions can destabilize your system; they can be
the source of mysterious bugs and crashes.  Avoid gems which pull in more
dependencies than their value warrants.  Example of a bad gem: the
`fog` gem which pulls in 39 gems, more dependencies than rails itself
and most of which are unnecessary.

Lastly, make sure you only load the gem when necessary.  Use Bundler's
group support to disable test gems when not testing:

```ruby
group :test do
  gem 'rspec'
  gem 'timecop'
  # etc
end
```

## Gem Developers, Listen Up!

Part of your job as a library author is to treat your user and their
application with respect.  You should make an effort to minimize your
own dependencies so they don't load unnecessary code or cause issues in the user's application.
You control your own code but you don't control your dependencies.  Any
bug in a dependency of yours becomes a bug that causes stress for your user and
their application.

As a gem developer, for each of your gem dependencies do you:

* know how much memory each takes?
* know how long each takes to require?
* know whether it performs any monkeypatching outside of its own module?

Sidekiq, with all of its functionality, has only 3 runtime dependencies:
`rack`, `connection_pool` and `redis`.

### Die json, die (German for "The json, the")

<figure style="float: right;">
  <img style="border: solid white 10px;" src="http://41.media.tumblr.com/tumblr_lh4z0xSXsx1qbohddo1_500.jpg" width="320px" />
</figure>
So many gems declare a dependency on json, oj, multi_json, or yajl-ruby.
There's so many ossified layers of cruft around JSON
processing that only one course of action makes sense: remove it all.
JSON has been in the stdlib since 1.9, you don't need to declare any dependencies at all.
Just `require 'json'` and let Ruby deal with it.

[Rails did it](https://github.com/rails/rails/pull/23453), so can you!

### Why choose an HTTP client when you can have them all?

Every Rails app pulls in a half dozen different HTTP clients: faraday, rest-client,
httparty, excon, typhoeus, curb, etc.  This is because various gems use them internally.
**A Rubygem should never use anything but Net::HTTP internally!**
Learn the Net:HTTP API, kill those dependencies and stop forcing extra HTTP client gems on your users.

Let's say you want to offer an optimized version using curb: ok, but make it
optional.  Allow the application developer to opt into using curb but
net/http should always be the default.

### Optimizing Rails 5.0

For the last few weeks, I've been working (in tandem with several other
developers, hi @\_matthewd, @applerebel!) on minimizing gem dependencies
in Rails 5.0.  Rails 4.2.5 requires 34 gems.  Rails 5.0b1 required 55 gems.
Rails 5.0b2 required 39 gems.  I expect Rails 5.0 to require 37 gems or
less.  So far we've removed Celluloid, EventMachine, thread\_safe, and json.

Unfortunately there's no more low-hanging fruit.  I'd love to drop
Nokogiri, it's such a huge dependency with a massive native extension component,
but there are some [non-trivial dependencies](https://github.com/flavorjones/loofah/issues/100) on it.
[Oga](https://github.com/YorickPeterse/oga) is a nice, simpler alternative.  If you
ship a gem which depends on Nokogiri, consider making it optional and defaulting to REXML (I know, but
at least it's in stdlib) or Oga instead.

### Be Part of the Solution

I can help with Rails 5.0 but I can't fix every gem.  If you are a gem developer,
audit your own dependencies and remove as many as you can.
If you're an app developer, take a look in your
Gemfile and see if you can find a gem or two to remove.
Simplify, simplify, simplify.

As an example, I think it's possible for the [Stripe gem](https://github.com/stripe/stripe-ruby/blob/master/stripe.gemspec#L16) to remove both of its runtime dependencies. (Update: Stripe [removed these dependencies](https://github.com/stripe/stripe-ruby/pull/813) from their gem, yay!)

### Rules to Remember

Some software engineering rules:

* No code runs faster than no code.
* No code has fewer bugs than no code.
* No code uses less memory than no code.
* No code is easier to understand than no code.

Kill those dependencies.  Your gems and apps will be better for it.

---
author: Mike Perham
date: 2015-02-04T00:00:00Z
published: true
title: Indie Developers in Ruby, 2015 Ed.
url: /2015/02/04/indie-developers-in-ruby-2015-edition/
---

<figure style="float:right">
  <img src="/wp-content/uploads/2015/02/indie.png"/>
  <figcaption style="font-size: xx-small"><a style="float: right" href="http://michaeljholley.com/2014/09/02/self-publishing-or-indie-publishing/">image source</a></figcaption>
</figure>

Ruby is great for programmers: you can download the source for so many different libraries to solve many different problems.
But there's a dark side: there's no incentive for the library author to help or support you as a user.
So many open source projects become ghost towns over the course of a year or two due to ongoing support and time commitments.
If you're building a long-term business with these tools, it's in your best interests to ensure they remain
supported with a steady flow of features and bug fixes for years to come.

Many developers are trying to find a happy medium between the Open Source "give it all away" approach
and the traditional commercial software approach "talk to this sales guy to get a quote" by selling Open Source-based
products.  Steady income makes the ongoing time commitment so much easier to handle.

Note that I'm focused on bootstrapped or "indie" developers selling Ruby-related **products** and ignoring VC-backed companies or
SaaSes.  Indie developers don't have the benefit of big marketing budgets or sales staff.
They might blog, go to conferences and/or give away swag but they often don't get much public attention.
Let's change that!

## Class of 2015

Without further ado, here's the list I came up.  Thanks to my Twitter followers for many suggestions!

**Dresssed**

[Dresssed](https://dresssed.com/themes/gimlet) sells premium site templates for Rails.  Get a beautiful template for
your new site with lots of form variants, error pages, SASS integration, responsive design, etc already built.

**GitLab**

[GitLab](https://about.gitlab.com/pricing/) offers an open source alternative to GitHub Enterprise.  If you
need to self-host your own source code repositories, this is one way to do it.  They offer GitLab Enterprise
with extra features and support.

**Passenger**

Passenger is the canonical commercial/OSS hybrid product and Phusion does a fantastic job pushing the envelope in features
and performance.  (I'm happy to admit I borrowed several of their ideas when bootstrapping my own project.)
They sell [Passenger Enterprise](https://www.phusionpassenger.com/enterprise): an upgrade of their free
Passenger OSS library with additional features and support.  If you have a business running on Rails,
this should be your first purchase.

**Payola**

Pete Keen has carved out a niche as the expert on Rails + Stripe.  If you need top-notch Stripe integration,
Payola is your solution.  His commercial variant, [Payola Pro](https://www.payola.io/pro), adds a number
of additional features and a support contract.

**RailsKits**

RailsKits offers Rails app templates with common functionality already built-in.  Their [SaaS kit](https://railskits.com/saas/)
gives you a full Rails 4.1 app skeleton with monthly subscriptions, pricing tiers and multi-tenant database storage pre-built
for one low price; sounds awesome!

**RailsLTS**

[RailsLTS](https://railslts.com/) offers long-term support for very popular Rails versions, backporting critical security fixes to
older Rails versions which aren't maintained anymore by Rails Core.  They've released 12 versions of
2.3.18 so far and will be adding Rails 3.2 support soon.

**RubyMotion**

How awesome is [RubyMotion](http://www.rubymotion.com/buy/)?  Write native iOS applications with Ruby!  Not technically a Ruby product
since it's all Mac/iOS native, but it's focused on making iOS development for us Rubyists as easy as possible.

**Sidekiq**

I'm happy to be part of this list too!  [Sidekiq Pro](http://sidekiq.org/pro/) extends Sidekiq with more features and a support contract.
If you want to build a scalable Ruby website for the long-term, use Passenger Enterprise for your app server and Sidekiq Pro for
processing background jobs.  Since its launch three years ago, Sidekiq has grown from a side project to my full-time job.

**TwoFactorAuth**

Peter Harkins built [TwoFactorAuth](https://www.twofactorauth.io/), a gem which adds U2F key fob (e.g. Yubikey) support to your Rails app.  It's AGPL
licensed for free, you must pay for commercial usage.  I love OSS projects which have the courage to use GNU + commercial licensing: everything is out
in the open but the author built something valuable, businesses need to pay for that value and the AGPL enforces that.  Makes for a dead simple way
to allow free trials while ensuring sales with no effort on the developer's part.  When you think about all the government, health care and financial
apps which can be built in Rails and need robust authentication, I bet there's a nice niche market for Peter to capture here!

### Conclusion

That's only nine - I wish there were more!  If I missed anyone, please let me know.

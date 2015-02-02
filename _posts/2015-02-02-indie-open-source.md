---
title: "Indie Open Source in Ruby, 2015 Ed."
author: Mike Perham
layout: post
permalink: /2015/02/03/indie-open-source-in-ruby-2015-edition
published: false
---

Open Source is great for programmers: you can download the source for so many different libraries to solve your problem.
But there's a dark side: there's no incentive for the library author to help or support you as a user.
If you're building a long-term business with these tools, it's in your best interests to ensure they remain
supported for years to come.  Several OSS developers are trying to find a happy medium between the most popular approach
"give it all away" and the traditional commercial software approach "talk to this sales guy to get a quote" by selling
products.

Note that I'm focused on bootstrapped or "indie" developers selling Ruby-focused **products** and ignoring VC-backed companies or
SaaSes.  Indie developers don't have the benefit of million dollar marketing budgets.  We don't have sales teams
or author nonsensical whitepapers.  Indie developers might blog, go to conferences and/or give away stickers but they often
don't get much public attention; that's why I want to highlight them.

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

Passenger is the canonical commercial Ruby product and Phusion does a fantastic job pushing the envelope in features
and performance.  They sell [Passenger Enterprise](https://www.phusionpassenger.com/enterprise): an upgrade of their free
Passenger OSS library with additional features and support.  If I was building a large-scale Ruby website,
this would be my first purchase.

**Payola**

Pete Keen has carved out a niche as the expert on Rails + Stripe.  If you are building an e-commerce site and
need top-notch Stripe integration, Payola is your solution.  His commercial variant, [Payola Pro](https://www.payola.io/pro), adds a number
of additional features and a support contract.

**RailsKits**

RailsKits offers Rails app templates with common functionality already built-in.  Their [SaaS kit](https://railskits.com/saas/)
gives you a full Rails 4.1 app skeleton with monthly subscriptions, pricing tiers and multi-tenant database storage pre-built
for one low price; sounds awesome!

**RailsLTS**

[RailsLTS](https://railslts.com/) offers long-term maintenance of very popular Rails versions, backporting critical security fixes to
older Rails versions which aren't maintained anymore by Rails Core.  They've issued 12 versions of
2.3.18 so far and will be adding Rails 3.2 support soon.

**RubyMotion**

How awesome is [RubyMotion](http://www.rubymotion.com/buy/)?  Write native iOS applications with Ruby!  Not technically a Ruby product
since it's all Mac/iOS native, but it's focused on making iOS development for us Rubyists as easy as possible.

**Sidekiq**

Of course my own Sidekiq project offers [Sidekiq Pro](http://sidekiq.org/pro/), an add-on which offers more features and a support contract.
I believe Passenger Enterprise and Sidekiq Pro are the best infrastructure for scaling Rails websites today.

**TwoFactorAuth**

[TwoFactorAuth](https://www.twofactorauth.io/rails) is a gem which adds U2F key fob (e.g. Yubikey) support to your Rails app.  It's AGPL
licensed for free, you must pay for commercial usage.  I love OSS projects which have the courage to use GNU + commercial licensing: everything is out
in the open but the author built something valuable, business users should pay for that value.  Makes for a dead simple way to allow free trials
while ensuring sales with no effort on the developer's part.

## Others?

If I missed any products, please let me know.  That's only nine - I wish there were more!

I love doing this full-time without the need for investors or a board of directors to distract me from simply building
the best product I can and I'm happy to support fellow indies in their work.

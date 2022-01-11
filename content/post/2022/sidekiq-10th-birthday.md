---
title: "🎉 Happy 10th Birthday, Sidekiq! 🎂"
date: 2022-01-17T09:00:00-08:00
publishdate: 2022-01-17
lastmod: 2022-01-17
tags: []
---

It's hard for me to believe these words but I pushed Sidekiq's [first commit](https://github.com/mperham/sidekiq/commit/26d9a92a6b355f131720b983888e8858e40aaa6e) on Jan 16th, 2012. Ten years ago. [The public announcement](https://www.mikeperham.com/2012/02/07/sidekiq-simple-efficient-messaging-for-rails/). [One month later](https://www.mikeperham.com/2012/03/02/the-state-of-sidekiq-one-month-later/). [One quarter later](https://www.mikeperham.com/2012/05/01/one-quarter-of-sidekiq/).

Some context for those new to this blog: Sidekiq is the most popular background job system for the Ruby programming language.
Every application has tasks which are important: send an email, charge a credit card, reserve inventory for an order, synchronize some data to a 3rd party service, etc.
By making these background jobs, you automatically get error handling and retry, easy scaling across multiple machines, a monitoring UI and lots more.

<div class="jumbotron" style="padding: 2rem">
  <h1>A Deal for You!</h1>
  <p class="lead">Nate Berkopec's incredible <a href="https://nateberk.gumroad.com/l/sidekiqinpractice"><b>Sidekiq in Practice</b></a> workshop is 10 times cheaper in honor of Sidekiq's 10th Anniversary. You can buy it for $5 with the discount code <tt>SIDEKIQ10</tt>.
  <p>The discount is good for <b>this week only</b> and ends on 2022-01-24.</p>
</div>

## Prehistory

Sidekiq did not spring fully formed from the ether.
The first background job system in Ruby which I'm aware of was **[BackgrounDRb](https://www.infoq.com/articles/BackgrounDRb/)** in 2006 from the late, great [Ezra Zygmuntowicz](https://youtu.be/xG1S9ZPCy2Q).
Ruby on Rails was just taking off in popularity but there was little to no infrastructure to process tasks outside of the HTTP request/response cycle.
The name is a play on DRB, the Distributed Ruby module which ships in Ruby's standard library, and allows RPC-style calls across machines.
Note the use of the term **Worker** in [the docs](http://blog.gnufied.org); modern Ruby uses the term **Job** now.

BackgrounDRb's main issue is that it is not persistent: if the process is shutdown, all executing jobs are lost.
Tobi Lutke, CEO of Shopify, [published **Delayed::Job** in Feb 2008](https://github.com/tobi/delayed_job/commit/75b49dc1c281ffa934a4eb2c7e840291e8b4a5ff).
DJ persisted job data to the database, allowing for safe, frequent deployments which restarted any DJ processes.
DJ's main issue is that it targeted MySQL, which was not designed for the access patterns inherent in a queue; it added massive load to the database which limited its scalability pretty severely.

Chris Wanstrath, Founder of GitHub, [published **Resque** in Aug 2009](https://github.com/resque/resque/commit/b1e00511b8ee9d9b2bcec41d7ccf306757049e66).
Resque moved away from the database and stored job data inside a popular new datastore named **Redis**.
(Side note: Ezra Zygmuntowicz was the main driver of Redis adoption within the Ruby community and wrote the first Redis client.)
Redis was marketed as a "data structure server" and had native, high performance support for queueing operations, making it far more scalable than DJ.
Resque's main issue is that jobs are not thread-safe and so job execution is single-threaded only, making it RAM hungry.

Shopify is currently worth $140+ billion.
GitHub was bought by Microsoft for $7.5 billion.
Tobi and Chris are both now billionaires.

## History

This was the state of background jobs circa 2010.
I had implemented a background job system in every Ruby company I had worked at because each OSS solution had severe limitations.
I built [Qanat in 2010](https://github.com/mperham/qanat), an [event-based job runner](https://www.mikeperham.com/2010/01/27/scalable-ruby-processing-with-eventmachine/) which used green threads to process multiple jobs concurrently but it suffered from the same malady as Node apps: blocking the event loop.
I built [girl_friday in 2011](https://github.com/mperham/girl_friday/wiki) which prototyped using the Actor pattern for [thread-safe job execution](https://www.mikeperham.com/2011/05/19/threads-fibers-events-and-actors/) but still had a few design issues I was not happy about.
The stage was set for Sidekiq.

Redis really impressed me as a pragmatic datastore.
It was the first non-trivial C project I'd seen that did not run `configure`;
you just downloaded the code and ran `make`.
It did not pretend to support every *nix since 1983.
64-bit native.
The code was clean and readable.
I believed I could rely on it as a datastore and that has proven to be true.
I never seriously considered supporting multiple datastores; that's a quagmire with little value.
Omakase.

Sidekiq was the first major Ruby job system to run multi-threaded only.
I knew someone had to entice the community to address thread-safety and my main worry was that the community would reject Sidekiq due to thread-safety fears.
I guess the promise of a huge leap forward in performance won the day;
within a year or so most thread safety problems in popular gems had been discovered and fixed.
I still get occasional emails from customers running Sidekiq with concurrency: 1 because they don't trust their own app code to be thread-safe.
Alas.

After a few months I did something unusual: I declared that Sidekiq was unsustainable and that to solve that problem I wanted to run some ["financial experiments"](https://www.mikeperham.com/2012/08/26/the-sidekiq-experiment-part-i/) to ensure long-term support and maintenance.
In October 2012, [I started selling Sidekiq Pro](https://www.mikeperham.com/2012/10/01/say-hello-to-sidekiq-pro/).
Even today I regularly see talk about the unsustainability of open source software, burnout and "retiring from OSS".
What's old is new again.

My solution to sustainability was to make Sidekiq profitable.
A project the size of Sidekiq requires many years of maintenance while supporting many thousands of users.
That work can be a brutal cross to bear for free but it's a perfectly sensible job.
I settled on the open core business model: Sidekiq is open source but Sidekiq Pro and Sidekiq Enterprise are closed source, commercial add-ons.
I still work in the open where possible;
issues, pull requests, wiki documentation are all on GitHub in the open.

## Some Numbers

What has happened in the past 10 years?

* 11,500 stars
* 4100 commits (from me **and** the community!)
* 5100 issues
* 115 million downloads
* 170 OSS gem versions

But none of that matters if a maintainer's health or well-being is suffering. Here's some business numbers for [Contributed Systems](https://contribsys.com):

* 1 employee (me!)
* 1850 customers
* 3.0m HTTP requests to the commercial gem server per day
* $13.5 million in total gross sales

Ten years later and I'm still here: sustainability ✅ and I did it my way.

But I do wonder: could I have sold out, taken VC, and grown Sidekiq into a billion dollar unicorn?
Maybe... but that wasn't my objective.
Since the beginning I've focused on building Sidekiq with steady, methodical improvement every day.

Four years ago, I started a new project, [Faktory](https://github.com/contribsys/faktory/wiki), to bring Sidekiq's functionality to any programming language, not just Ruby.
Like Sidekiq, it has a commercial version which ensures long-term maintenance.
Unlike Sidekiq, it is designed to work with any programming language: Go, JavaScript, Python, et al.
The bulk of my workday consists of supporting my Sidekiq and Faktory users.

It's been incredibly gratifying to see many other software projects following Sidekiq's lead.
Some copy the pricing, the wiki documentation style, the commercial license or even the [sidekiq.org](https://sidekiq.org) home page!
Once a person blazes a trail, many people can follow the well-worn path.

## The Future

Short term: Ruby 3.1 and Rails 7.0 will require some minor but breaking changes, coming in Sidekiq
7.0. Maintenance never ends.

Long term: it's really hard for me to type this but I likely won't see 2030 as project owner and maintainer.
While I have a few wonderful collaborators, being Sidekiq's [BDFL](https://en.wikipedia.org/wiki/Benevolent_dictator_for_life) means I am a single point of failure.
I'm approaching 50 years old and want to enjoy my success at some point.
What should I do?
One idea is to turn Sidekiq over to [Ruby Central](https://rubycentral.org).
Nothing would making me prouder than seeing Sidekiq sustaining our Ruby community infrastructure.

What a legacy that would be!

Thoughts? Tweet [@getajobmike](https://twitter.com/getajobmike).

<div class="jumbotron" style="padding: 2rem">
  <h1>A Deal for You!</h1>
  <p class="lead">Nate Berkopec's incredible <a href="https://nateberk.gumroad.com/l/sidekiqinpractice"><b>Sidekiq in Practice</b></a> workshop is 10 times cheaper in honor of Sidekiq's 10th Anniversary. You can buy it for $5 with the discount code <tt>SIDEKIQ10</tt>.
  <p>The discount is good for <b>this week only</b> and ends on 2022-01-24.</p>
</div>


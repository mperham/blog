---
author: Mike Perham
categories:
- Personal
date: 2013-01-31T00:00:00Z
title: One Great Year at The Clymb
url: /2013/01/31/one-great-year-at-the-clymb/
---

I joined [The Clymb][1] one year ago today and what an amazing year it's been.

Some context for you: I was employee 33 and the third engineer to join. The test suite had hundreds of failures and had been running red for months. We were on REE, Rails 2.3 and Delayed Job -- a stack that was current two years before -- and had no error service to know what errors were happening in production. The site was deployed with fabric, a Python-based tool. The first two developers were overworked and fought fires all day, every day.  
<!--more-->

  
My first task was to upgrade our entire site infrastructure to state of the art but I also did my best to bring some sanity to our process. My first two weeks were spent just getting the test suite running green so I could start the upgrade process with some way to verify correctness. The entire upgrade process took me six weeks. Today we're on Rails 3.2, Ruby 1.9.3 and Sidekiq Pro with help from Travis-CI Pro, Honeybadger, Librato Metrics, Papertrail and capistrano. We took to using GitHub pull requests like a fish takes to water -- the peer code review has made a marked improvement in code quality. It took about 3 months but we slowly fought fires less and less every day.

Over the last year we've added major new functionality, including:

*   Complete UI overhaul for a great experience on phones and tablets
*   Clymb 365 stores with popular products all year around
*   Overhauled shopping cart and checkout process
*   Adventures and other "non-traditional" product types
*   Multiple images per product
*   Waitlist for sold out products
*   Overnight, 2 and 3 day shipping options
*   And huge improvements to our inventory, returns and administration backends

We've grown to 90 employees with 8 full time engineers and 2 more part time contractors. We now have dedicated teams for site infrastructure (aka devops), product development and business intelligence (aka analytics). If you're in Portland*, interested in one of those areas and in joining a rapidly growing company, contact me (mike @ theclymb.com). I'm really excited for what the next year will hold.

* Unfortunately we can't hire remote employees because it legally requires us to charge sales tax in those states.

 [1]: http://www.theclymb.com/invite-from/mperham

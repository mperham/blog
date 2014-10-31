---
title: Bounded Libraries
author: Mike Perham
layout: post
permalink: /2014/05/22/bounded-libraries/
categories:
  - Sidekiq
  - Software
---
I&#8217;ve been noticing a theme in certain Rubygems recently that I like: opinionated designs which explicitly don&#8217;t allow the user to do certain things. I call these **bounded libraries** because they draw a functional boundary and won&#8217;t go beyond that point.  
<!--more-->

Let&#8217;s face it: when we start a new Open Source project, we just want people to use it. If someone asks us to add a feature, we commonly implement it to make our user happy. *But this can be a terrible idea!* Good gems are written by expert developers, with many years of experience and a vision for what their gem will do, but the best gems also draw a line at what their gem **will not do, ever**.

Part of earning the users trust is not just providing high quality functionality but also pushing back on requests where our experience tells them they should not go. Most recently this came up in using the `minitest` gem. For those that don&#8217;t know, minitest&#8217;s mocking and stubbing support is far more limited than what is available in rspec, mocha or flexmock **and this is a good thing**. Every time I experience pain testing a component with minitest, it&#8217;s because I&#8217;ve got some coupling which can&#8217;t be stubbed or mocked away with minitest. I could do this with the other tools but I would just hurt myself twice: I still have that coupling but now I have brittle test code too! minitest&#8217;s refusal to provide the extensive mocking and stubbing of the others forces me to write better code.

I&#8217;ve tried to be very clear in Sidekiq&#8217;s boundaries: I won&#8217;t provide features which cripple concurrency as this requires distributed locks and coordination. Examples of those features include unique jobs, cron-scheduled jobs, throttling and rate limiting. These features lead to non-deterministic behavior and hit overall performance hard. Lots of people ask for these features but I always point them to 3rd party gems. I can&#8217;t stop someone from using Sidekiq but I can refuse to help.

What are your favorite open source bounded libraries? What boundary lines do they draw?
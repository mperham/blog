---
title: 'Sidekiq &#8211; simple, efficient messaging for Rails'
author: Mike Perham
layout: post
permalink: /2012/02/07/sidekiq-simple-efficient-messaging-for-rails/
categories:
  - Ruby
---
I introduced my latest project, [Sidekiq][1], this morning. Sidekiq is the culmination of several years of research and development into message processing with Ruby. I first wrote a single-threaded mysql-backed queue called QBert for FiveRuns in 2008 before delayed_job was introduced. Next I wrote a single-threaded SQS-based processor called Jobber and then a Fiber-based, RabbitMQ-backed processor called Qanat for OneSpot. Most recently I wrote [girl_friday][2], an Actor-based, redis-backed processor and a custom multi-threaded version of Resque for a Carbon Five client.

So yeah, messaging and I have a history but I think that&#8217;s because Ruby still doesn&#8217;t have a simple, scalable option for message processing. Sidekiq is my attempt to solve that need.

**Simple**

Sidekiq integrates tightly with Rails 3 so your application&#8217;s worker code is nearby and easy for Sidekiq to find and load. I&#8217;d like to support plain Ruby applications but I need a replacement for the nice integration Rails 3 gives me.

**Efficient**

Sidekiq uses multiple threads so you can process hundreds of messages in parallel if you desire without the overhead of hundreds of processes. Internally Sidekiq uses the Celluloid actor library to make threading easier and safer to manage.

**Developer Friendly**

I&#8217;ve tried to make Sidekiq developer friendly in two ways:

*   Resque-compatible &#8211; I love conventions, why reinvent the wheel when you can stick closely to what someone else has done and leverage that work? I aim to make Sidekiq easy to integrate into an existing Resque project and monitorable via resque-ui.
*   Middleware &#8211; Sidekiq pulls in a middleware API similar to Rack for running code before/after/around a processed message and ships with middleware that helps with ActiveRecord and Airbrake.

Please let me know how you like Sidekiq &#8211; I love hearing stories about how people are using it.

 [1]: http://mperham.github.com/sidekiq
 [2]: http://mperham.github.com/girl_friday
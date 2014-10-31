---
title: The Sidekiq Experiment, Part I
author: Mike Perham
layout: post
permalink: /2012/08/26/the-sidekiq-experiment-part-i/
categories:
  - Ruby
  - Software
---
It&#8217;s been about 6 months since I released the first version of [Sidekiq][1], my take on a high-performance background processing library for Ruby which is an order of magnitude more efficient than Resque and DelayedJob.

In some ways, Sidekiq has been a huge success: I&#8217;ve never owned an OSS project that has ramped up this quickly in terms of watchers, users, pull requests, etc. I&#8217;m still blown away that a [Railscast][2] was created for Sidekiq!

But another part of the Sidekiq project is not technological at all but rather an experiment to answer another question: how can I build a library that is simple for others to use but also financially responsible for myself as a husband and father? I&#8217;ve spent hundreds of hours building Sidekiq and managing the project, how can I justify time away from my family in order to build and support the best tool out there for free?

Sidekiq&#8217;s initial release was LGPL (actually GPL but that was my mistake and quickly fixed) and offered a (easy?) way for people to donate $50 in exchange for a more business-friendly license. In the last 6 months, I&#8217;ve sold about 15 licenses for about $700. Assuming I&#8217;ve spent 200 hours on Sidekiq, that&#8217;s $3.50/hr or half of minimum wage. **It&#8217;s safe to say I do this because I love building software, not for the massive payday.** I&#8217;m calling altruism and licensing a failure and an end to this part of the experiment.

What&#8217;s next? Allow your workers to purchase in-app trinkets, a la Zynga? Sell out to IBM and create WebSphere SQ? Nope, but I have some ideas which I think everyone will be happy with. They&#8217;re still early stages so I won&#8217;t give any details but people who have bought a commercial license will be taken care of.

 [1]: http://mperham.github.com/sidekiq
 [2]: http://railscasts.com/episodes/366-sidekiq
---
title: 'The State of Sidekiq &#8211; One Month Later'
author: Mike Perham
layout: post
permalink: /2012/03/02/the-state-of-sidekiq-one-month-later/
categories:
  - Ruby
---
I released [Sidekiq][1] about one month ago and the take up so far has been amazing. Some stats:

*   462 watchers
*   66 issues opened so far.
*   Three contributors earned commit rights.
*   One commercial license purchased!
*   Approximately one pull request per day, far better than any of my previous projects.

I&#8217;ve chatted with two different people running Sidekiq in production and their experience has been the same:

*   &#8220;I&#8217;m expecting to save $2000/month in worker boxes moving from delayed_job to Sidekiq.&#8221;
*   &#8220;I&#8217;ve gone from 160 worker dynos to 10 dynos, saving over $5000/month.&#8221;

Astounding, all in the first month for a one man OSS project. If you use Sidekiq in production, please email me (mperham AT gmail) and tell me your success story!

 [1]: http://mperham.github.com/sidekiq
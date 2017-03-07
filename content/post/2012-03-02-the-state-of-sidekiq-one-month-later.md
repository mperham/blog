---
author: Mike Perham
categories:
- Ruby
date: 2012-03-02T00:00:00Z
title: The State of Sidekiq -- One Month Later
url: /2012/03/02/the-state-of-sidekiq-one-month-later/
---

I released [Sidekiq][1] about one month ago and the take up so far has been amazing. Some stats:

*   462 watchers
*   66 issues opened so far.
*   Three contributors earned commit rights.
*   One commercial license purchased!
*   Approximately one pull request per day, far better than any of my previous projects.

I've chatted with two different people running Sidekiq in production and their experience has been the same:

*   "I'm expecting to save $2000/month in worker boxes moving from delayed_job to Sidekiq."
*   "I've gone from 160 worker dynos to 10 dynos, saving over $5000/month."

Astounding, all in the first month for a one man OSS project. If you use Sidekiq in production, please email me (mperham AT gmail) and tell me your success story!

 [1]: http://mperham.github.com/sidekiq

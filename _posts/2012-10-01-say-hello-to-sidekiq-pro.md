---
title: Say Hello to Sidekiq Pro
author: Mike Perham
layout: post
permalink: /2012/10/01/say-hello-to-sidekiq-pro/
categories:
  - Ruby
---
It&#8217;s been 8 months since the initial release and by now I hope everyone agrees that [Sidekiq][1] has dramatically improved the state of the art in asynchronous processing for Ruby. [The Clymb][2] has been using it in production for 6 months now and it&#8217;s been far faster and more stable than our old Delayed::Job setup.

But Sidekiq just has feature parity with the best of the competition right now. It&#8217;s time to build some next generation functionality on top of that foundation &#8211; <a href="http://sidekiq.org/pro" style="color: #b1003e; font-size: 20px; font-weight: bold;">Sidekiq Pro</a> is a new **commercial** add-on for Sidekiq which adds some great new features that I hope people will find useful and worth paying for.

**Features**

There are three big new features in Sidekiq Pro:

*   **Batches** &#8211; group your jobs into a batch and monitor their progress in the Sidekiq Web UI or API
*   **Notifications** &#8211; get notified via redis pub/sub, webhook, email or campfire when a batch is complete
*   **Metrics** &#8211; report Sidekiq runtime metrics to Statsd for monitoring with Graphite or Librato Metrics

The Sidekiq wiki will be updated to document these Pro features over the next few days. I reserve the right to add even more awesome features in the future.

**Licensing**

The existing commercial license option for Sidekiq is no longer available, Sidekiq by itself is LGPLv3 only now. If you had paid for a license (thank you!), your license is still perfectly valid. From this point forward if you want a commercial license for Sidekiq, you must purchase Sidekiq Pro.

As my way of saying thanks, 100% of the first unit sold will go to Tony Arcieri for his great Celluloid gem. Celluloid is a big part of Sidekiq&#8217;s success and I think he deserves a few nights of karaoke on me in return.

 [1]: http://sidekiq.org
 [2]: http://www.theclymb.com/invite-from/mperham
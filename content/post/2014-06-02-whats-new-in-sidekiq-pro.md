---
author: Mike Perham
categories:
- Sidekiq
date: 2014-06-02T00:00:00Z
title: What's new in Sidekiq Pro
url: /2014/06/02/whats-new-in-sidekiq-pro/
---

Since the Sidekiq 3.0 release, I've been slowly chipping away at some new features in [Sidekiq Pro][1]. What's new and upcoming?  
<!--more-->

**Conference Sponsorship**

Sidekiq Pro is happy to sponsor [Cascadia Ruby][2] 2014. If you're in Portland for the conference, find me for a Sidekiq sticker perfect for those who like to adorn their laptops.

**Pause Queues**

v1.7 added the ability to pause reliable queues via API. Occasionally you might want a system that enables or disables processing of certain types of messages based on time of day or some other external event. This is easily accomplished now:

{{< highlight ruby >}}
q = Sidekiq::Queue.new("business_hours_only")
q.pause!
{{< / highlight >}}


Jobs will accumulate until the queue is unpaused. As you might guess, the Web UI will show when a queue is paused:

[<img src="http://www.mikeperham.com/wp-content/uploads/2014/06/Screen-Shot-2014-06-01-at-1.56.37-PM.png" alt="Screen Shot 2014-06-01 at 1.56.37 PM" class="alignnone size-full wp-image-1673" />][3]

**Batch tweaks**

Previously Batch `complete` and `success` callbacks were executed directly by the middleware, in the context of the job that triggered it. This meant that any failure in the callback would make Sidekiq think the job itself had failed so it would be retried. Now callbacks are executed asynchronously as their own job so they can fail and retry like any other application job.

Successful batches are now removed from the UI so they don't overwhelm the Batches index page. Typically the developer does not want to see successful batches in the UI but wants to see failures or incomplete batches for debugging purposes.

**Eye candy!**

roy-sac on DeviantArt was nice enough to make an ANSI art startup banner for Sidekiq Pro. It's amazing what a real artist can do! This will be available in 1.7.4+.

[<img src="http://www.mikeperham.com/wp-content/uploads/2014/06/Screen-Shot-2014-06-01-at-3.16.46-PM.png" alt="Screen Shot 2014-06-01 at 3.16.46 PM" class="alignnone size-full wp-image-1683" />][4]

**Notification deprecations**

I'm going to remove notification schemes (campfire, hipchat, email, webhook) in Sidekiq Pro 2.0. They made batch notifications simple but the whole thing suffers from the same problem [github-services][5] suffers from: there's a glut of different services out there and I don't want to add and maintain a notification wrapper for each. Since each notification scheme is a simple wrapper around the Batch `complete` callback, it's not hard to reproduce it in your application code. I'll provide examples of how to do just that as part of the upgrade notes.

If you have an idea for a Sidekiq Pro feature, please [open an issue][6] so we can discuss. Happy 'kiqing!

 [1]: http://sidekiq.org/
 [2]: http://cascadiaruby.com/
 [3]: http://www.mikeperham.com/wp-content/uploads/2014/06/Screen-Shot-2014-06-01-at-1.56.37-PM.png
 [4]: http://www.mikeperham.com/wp-content/uploads/2014/06/Screen-Shot-2014-06-01-at-3.16.46-PM.png
 [5]: https://github.com/github/github-services
 [6]: https://github.com/mperham/sidekiq/issues

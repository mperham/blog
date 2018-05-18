---
author: Mike Perham
categories:
- Sidekiq
date: 2014-10-01T00:00:00Z
title: The Path to Full-time Open Source
url: /2014/10/01/the-path-to-full-time-open-source/
---

Two years ago today I released [Sidekiq Pro][1], my commercial extension</a> to Sidekiq, as an experiment to see if I could make OSS development financially viable for individual developers. I had no idea if anyone would trust me and buy it. Can you think of anyone else selling a Rubygem?

<!--more-->

[<img src="http://www.mikeperham.com/wp-content/uploads/2014/09/logo.png" alt="logo" width="400" height="407" class="alignnone size-full wp-image-1875" />][2]

Sidekiq Pro sales for the last three months of 2012 were $7500. In 2013 they totalled $85,000. This year sales should top **$175,000**. **Open Source development is now my full-time job, with no need for a corporate patron!**

I'm being financially transparent here because I want my fellow developers to know: **you can build incredibly valuable software and make real money from it**. A small percentage of your users are willing to pay for extra features and the assurance of ongoing support over the years. It does take time, experience and a little vision. Here's what I did:

**A Path to Success**

1.  Find a tool/library that is non-trivial and an important component to your current system or workflow.
2.  Plan out how you can make it better: **simplify it**, discard superfluous functionality, add useful functionality.
3.  Divide the functionality into open source and commercial parts. Use a GNU license and a commercial license for the respective parts.
4.  Build the open source part, document it.
5.  If it takes off, build the commercial part and the infrastructure necessary to sell it.

This path will take many months and none of these steps are easy! Be patient and work part-time on it for as long as possible. Remember that the open source version itself needs to offer plenty of value for users or there's no reason for them to use your creation. The most important aspect is that **you are your own best customer**: you know the current tool and the pain it causes. So as the old saying goes, build that better mousetrap!

For me, I started with Resque. It was a major component of so many Ruby on Rails websites, and yet it was barely maintained and missing a lot of important features. I knew I could build something better. From this "business plan", I created Sidekiq and Sidekiq Pro by following the steps above.

Now I want to do it again.

**Three months ago I quit my job to work on Sidekiq and build a brand new OSS project and commercial product. [Introducing Inspeqtor][3]!**

 [1]: http://sidekiq.org/
 [2]: http://www.mikeperham.com/wp-content/uploads/2014/09/logo.png
 [3]: http://www.mikeperham.com/2014/10/02/introducing-inspeqtor/

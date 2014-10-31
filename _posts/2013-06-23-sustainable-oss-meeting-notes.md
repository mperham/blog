---
title: Sustainable OSS Meeting Notes
author: Mike Perham
layout: post
permalink: /2013/06/23/sustainable-oss-meeting-notes/
categories:
  - Software
---
André Arko (@indirect, Bundler), Erik Michaels-Ober (@sferik, t/rails\_admin/multi\_json) and myself had a hangout this afternoon to talk about our struggles as Open Source developers and project leads. Here&#8217;s my notes, as I recollect:

Erik:

Enjoys working on his twitter gem, doesn&#8217;t enjoy rails\_admin anymore. There&#8217;s a fair amount of design/theme work in rails\_admin that he&#8217;s not good at and really needs to be abstracted out but would require a lot more time than he wants to invest. Features of rails\_admin were merged in but made it hard to maintain (e.g. mongodb support because he doesn&#8217;t use Mongo personally). Thought for a while how to make rails\_admin into a full time job.

André:

Bundler has tried to bring new people into the project where possible. Managing these people and getting them to commit to work is difficult when you don&#8217;t have any real authority over them. Ruby Central has given him a grant to work on Rubygems and Bundler.

Mike:

I wanted Sidekiq to be better than the status quo but was scared to death of the amount of time needed to support it over the next 5 years if it took off. I had two strategies from the start:

1. Be very picky about the features I accept and how they&#8217;re implemented

It&#8217;s my project so I have to support every line of code in it. Features that I know will cause support issues are redesigned or denied. For example, I won&#8217;t allow any features that require locking or distributed coordination. This keeps the codebase enjoyable.

2. Offer users a way to support the project financially

OSS is hard work, given away for free. I had no real desire to start a services/consulting company as I enjoy my day job. Selling a &#8220;support plan&#8221; is a disincentive to product quality: if your product is easy to use and well documented, you suffer financially. My initial plan to sell commercial licenses brought in beer money, no more. I decided to build a [value-added product][1] on top of the OSS core (who else does this?) which has been very successful so far.

**Conclusions**

Projects can differ radically in how to sustain them.

*   Learning can be a huge personal incentive to start and implement a project but doesn&#8217;t necessarily help support the project over months and years.
*   Help from others and thanks can go a long way. Managing volunteers has its own challenges.
*   Keep the codebase clean and enjoyable to work on, refactoring to improve your enjoyment of the code can be a great idea. Prune features which are support hotspots.
*   If you want to earn anything more than beer money for your efforts, explicitly consider a business model appropriate to you and your project.

 [1]: http://sidekiq.org/pro
---
author: Mike Perham
categories:
- Ruby
date: 2012-10-25T00:00:00Z
title: One Happy User
url: /2012/10/25/one-happy-user/
---

I received a nice email the other day from a programmer who wants to remain anonymous due to his job at LargeCorp™. While efficiency is something I strive for in Sidekiq, this story really proves that you can do an amazing amount of work very quickly with the right architecture.

> Hey Mike,
> 
> Just wanted to drop a line about Sidekiq. I know you've put a lot of thought and work into it and sometimes it's good to hear that not only are people using what you've done, but that they might be using it in ways you never intended to great success.
> 
> My organization had a unique problem. We had to poll around 600,000 nodes via SNMPv1 very quickly to see how operational changes were effecting the nodes. The problem is more complicated in that the poll wasn't simple at all. Each node has agents running on multiple ports, and they may or may not respond based on any number of factors. Sometimes some of the agents on a node would talk back and some wouldn't. The average number of unique GETs per host was 40+. It was a crapshoot.
> 
> Did I also mention the nodes are all on private address space? Yeah, this got complicated. I wasn't going to turn up EC2 instances to deal with this.
> 
> I was told by others that what I wanted to do &mdash; poll all the nodes in less than 15  
> minutes &mdash; was impossible. Not just impossible, but that it couldn't be done in less than hours.
> 
> There are many ways to approach something like this. A lot of folks would reach for a message queue and have the consumers handle the work.
> 
> Well I tried that. The problem? Lots of them. First off, we're talking about a lot of Ruby objects and hitting the garbage collector happened quickly. This isn't a Ruby problem. If I want to poll a lot of nodes quickly with these characteristics, I was hitting similar limits with SNMP4J and Java.
> 
> So to cut a long story short, I moved the logic into Sidekiq workers with an EventMachine-based SNMP poller.
> 
> I think many users may see Sidekiq as a background worker that's more efficient than something like Resque (the reasons are on the wiki, I don't think I need to cover them). Since I approached it with a different mindset, what I saw was a high performance message queue that did all the hard work for me.
> 
> And the performance increase I got?
> 
> I was told it would take no less than four hours to do what I wanted to do, which was 600,000 of the complicated queries in less than four hours (and those guys had LOTS of workers).
> 
> One Sidekiq worker does 500,000 in an hour at a concurrency level of 75. The existing solution had more racks of high performance servers acting as workers, I had no idea really, but the three or four racks of boxes took four hours. The four workers I deployed with did two million in an hour, which met my original objective. Well, almost, but shh.
> 
> Sidekiq is new. It's good. I really hope more people try it out to hack at problems they might have. 

As a developer who's put a lot of heart and soul into building something, these usage stories always make my day. Thank you for the tale and kind words!

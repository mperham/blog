---
author: Mike Perham
categories:
- Sidekiq
date: 2013-05-11T00:00:00Z
title: The Sidekiq Pro Giveaway Winner!
url: /2013/05/11/the-sidekiq-pro-giveaway-winner/
---

I'm happy to announce the winner of my [Sidekiq Pro][1] 1.0 license giveaway is Libin Pan, whose company already uses Sidekiq pretty heavily, having run **billions** of jobs through Sidekiq in the last year. Let's hear his story:  
<!--more-->

> I work for Demandbase, a B2B marketing company, we help our client to identify the companies who visited their online properties.
> 
> We were using resque before, because of the nature of forking, the memory and compute power is a big cost for us. So we switched to sidekiq soon after you released it. And we love it.
> 
> <img src="http://www.mikeperham.com/wp-content/uploads/2013/05/BJzXcEFCcAE-8a2.jpg" alt="BJzXcEFCcAE-8a2" width="658" height="178" class="aligncenter size-full wp-image-1339" />
> 
> We're using it in several projects, this screenshot is just one of them, a larger one of course. This sidekiq cluster handles the aggregation of realtime traffic for some clients. There're two major sidekiq workers, one normalizes the traffic, another one updates all the aggregation counts. Every task is very small and fast, and sidekiq is a perfect tool for it.
> 
> There're 4 sidekiq worker servers, and every one has 4 processes which every one has 25 workers. As we are all on EC2, we use spot instances for part of the cluster so we can add more workers as needed, so it could grow up from 400 to 800 or more.
> 
> The technology is nothing special but solid, Rails + Redis + Sharded MySQL. 

Thanks Libin and everyone else who entered. I hope Sidekiq Pro makes your system even better!

 [1]: http://sidekiq.org/

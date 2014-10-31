---
title: One Quarter of Sidekiq
author: Mike Perham
layout: post
permalink: /2012/05/01/one-quarter-of-sidekiq/
categories:
  - Ruby
---
It&#8217;s been about three months since I released [Sidekiq][1]. Let&#8217;s get to the numbers:

*   668 GitHub watchers
*   171 issues, 11 open
*   7 commercial licenses purchased!
*   54 pull requests with 30+ different developers!
*   1 [EngineYard podcast interview][2]
*   1 RailsConf lightning talk by @jwo
*   1 South African Ruby group talk on Sidekiq!
*   1 new license (LGPL rather than GPL)
*   0 locks in the multithreaded codebase

I consider that a success; I&#8217;ve never had a project grow this fast with just my own promotion and community word of mouth. [TheClymb][3] switched to Sidekiq last week and our biggest problem so far has been that Sidekiq can be **too parallel** and crush servers with traffic; we&#8217;ve had to rewrite some jobs to be serial!

My goals remain the same:

*   Provide the easiest and best supported queueing system for Ruby.
*   Be the first Rubygem people mention or consider when choosing a queueing system
*   Improve Ruby&#8217;s overall efficiency and perceived performance through multi-threading.
*   Evangelize multi-threaded infrastructure written with actor abstractions as relatively straightforward for knowledgable developers to build. [Celluloid][4] continues to be a huge asset to Sidekiq&#8217;s ease of development and stability.

Thank you all for your support so far! Thank you especially to EngineYard, Tony Arcieri and the early adopters that have made hacking on Sidekiq an exciting adventure rather than a lonely chore.

 [1]: https://github.com/mperham/sidekiq
 [2]: http://www.engineyard.com/podcast/sidekiq-the-clymb-motorcycles
 [3]: https://www.theclymb.com/invite-from/mperham
 [4]: https://github.com/celluloid/celluloid
---
author: Mike Perham
categories:
- Ruby
date: 2009-01-14T00:00:00Z
title: The Future of memcache-client
url: /2009/01/14/the-future-of-memcache-client/
---

Good news, everybody! Consistent hashing was the last remaining feature on my roadmap for 1.6.0. Release checklist:

*   Fork the fiveruns repository to an [mperham repository][1] to make it clear this is my project, not FiveRuns. This will be the official source location for 1.6.0+. **Done**
*   Pull in 37 Signals' socket timeout fixes, which should fix the rare issues we were seeing in production. **Done**
*   Create a 1.6.0 release candidate for testing purposes. `gem install mperham-memcache-client -s http://gems.github.com` **Done**
*   Run 1.6.0 in production for a week. If all goes well, publish it to RubyForge as memcache-client 1.6.0.

We'll be testing the 1.6.0 release at FiveRuns but feedback is always welcome, especially if you are running Ruby 1.9. Let me know if you have any problems.

 [1]: http://github.com/mperham/memcache-client

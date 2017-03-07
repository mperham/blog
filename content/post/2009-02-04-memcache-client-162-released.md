---
author: Mike Perham
categories:
- Ruby
- Software
date: 2009-02-04T00:00:00Z
title: memcache-client 1.6.2 released
url: /2009/02/04/memcache-client-162-released/
---

I released the first official update to memcache-client since 1.5.0 tonight. In the last year, my fork added a number of stability features, became the de facto "best" version and is now the official version. My goal for the next year is to get the latest version integrated into Rails.

**Highlights since 1.5.0**

*   Socket failover -- client will retry once if a SocketError is thrown
*   Server failover -- client will gracefully handle server death
*   Socket timeouts -- remote hang won't hang the client
*   Consistent hashing

**Source and Installation**

<http://github.com/mperham/memcache-client>  
`gem install memcache-client`

**Thanks**

*   FiveRuns for supporting me in this work
*   37signals for working on some of these features and using it in production
*   Eric Hodel for blessing me as the new maintainer
*   All the people who've sent bug reports and patches

If you want to give something back to me for my work, please recommend me at [Working with Rails][1]!

 [1]: http://workingwithrails.com/person/10797-mike-perham

---
title: memcache-client 1.6.2 released
author: Mike Perham
layout: post
permalink: /2009/02/04/memcache-client-162-released/
categories:
  - Ruby
  - Software
---
I released the first official update to memcache-client since 1.5.0 tonight. In the last year, my fork added a number of stability features, became the de facto &#8220;best&#8221; version and is now the official version. My goal for the next year is to get the latest version integrated into Rails.

**Highlights since 1.5.0**

*   Socket failover &#8211; client will retry once if a SocketError is thrown
*   Server failover &#8211; client will gracefully handle server death
*   Socket timeouts &#8211; remote hang won&#8217;t hang the client
*   Consistent hashing

**Source and Installation**

<http://github.com/mperham/memcache-client>  
`gem install memcache-client`

**Thanks**

*   FiveRuns for supporting me in this work
*   37signals for working on some of these features and using it in production
*   Eric Hodel for blessing me as the new maintainer
*   All the people who&#8217;ve sent bug reports and patches

If you want to give something back to me for my work, please recommend me at [Working with Rails][1]!

 [1]: http://workingwithrails.com/person/10797-mike-perham
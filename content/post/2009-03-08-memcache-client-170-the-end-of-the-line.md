---
author: Mike Perham
categories:
- Ruby
date: 2009-03-08T00:00:00Z
title: memcache-client 1.7.0 -- the End of the Line
url: /2009/03/08/memcache-client-170-the-end-of-the-line/
---

I believe that memcache-client has reached the end of its development lifecycle. I inherited a project which implemented basic memcached functionality and made it much faster, more reliable and expanded the implemented functionality to basically the entire memcached client protocol. At this point, there's not much left to do -- maintenance will be required if people find bugs in the newer functionality -- but I don't see a lot more releases coming soon. At this point, the project should stabilize so that Rails and other projects can build interesting functionality on top of it.

If you appreciate my work on memcache-client, please recommend me on [Working with Rails][1].

 [1]: http://workingwithrails.com/person/10797-mike-perham

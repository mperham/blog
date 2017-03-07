---
author: Mike Perham
categories:
- Software
date: 2007-10-04T00:00:00Z
title: Amazon's Dynamo
url: /2007/10/04/amazons-dynamo/
---

Here's a fascinating article by Amazon on how they built a highly scalable and reliable key/value store for use with their e-commerce platform.  It's incredible to hear that a single page request to amazon.com might involve over 100 invocations to other fine-grained services, all of which must return within 300ms 99.9% of the time.  Having worked on a (much smaller) e-commerce site, it's really interesting to hear the steps required to scale a site orders of magnitude farther than we ever did.

[Amazon's Dynamo -- All Things Distributed][1]

 [1]: http://www.allthingsdistributed.com/2007/10/amazons_dynamo.html

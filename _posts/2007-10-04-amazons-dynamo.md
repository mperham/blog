---
title: 'Amazon&#039;s Dynamo'
author: Mike Perham
layout: post
permalink: /2007/10/04/amazons-dynamo/
categories:
  - Software
---
Here&#8217;s a fascinating article by Amazon on how they built a highly scalable and reliable key/value store for use with their e-commerce platform.  It&#8217;s incredible to hear that a single page request to amazon.com might involve over 100 invocations to other fine-grained services, all of which must return within 300ms 99.9% of the time.  Having worked on a (much smaller) e-commerce site, it&#8217;s really interesting to hear the steps required to scale a site orders of magnitude farther than we ever did.

[Amazon&#8217;s Dynamo &#8211; All Things Distributed][1]

 [1]: http://www.allthingsdistributed.com/2007/10/amazons_dynamo.html
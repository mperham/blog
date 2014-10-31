---
title: Old versus New
author: Mike Perham
layout: post
permalink: /2009/07/29/old-versus-new/
categories:
  - Rails
  - Ruby
---
We had some performance issues recently and discovered we were using memcache-client 1.5.0. Our daemon was blocked by memcached socket operations hanging forever, which caused monit to kill and restart the daemon after 5 minutes.

I performed the brain surgery to use 1.7.4 (since we are using Rails 2.1) and deployed. See if you can guess when. Graph shows operations per hour (more is better).

[<img src="http://www.mikeperham.com/wp-content/uploads/2009/07/picture-1.png" alt="picture-1" title="picture-1" width="515" height="777" class="aligncenter size-full wp-image-311" />][1]

 [1]: http://www.mikeperham.com/wp-content/uploads/2009/07/picture-1.png
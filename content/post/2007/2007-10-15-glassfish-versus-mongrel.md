---
author: Mike Perham
categories:
- Rails
date: 2007-10-15T00:00:00Z
title: Glassfish versus Mongrel
url: /2007/10/15/glassfish-versus-mongrel/
---

I've been working on my upcoming AOR Glassfish talk. Here's some interesting numbers. (Unfortunately WordPress is pretty bad at offering good HTML formatting tools so you'll have to put up with some sad formatting.)

#### Memory Usage

```
Glassfish - 230MB resident, 840MB virtual
Mongrel Cluster (2 nodes) - 46MB resident, 104MB virtual
Nginx (2 workers) - 2MB resident, 84MB virtual
```

#### Page Times

This metric used Apache JMeter to simulate 25 users (threads) to request the home page for ThoughtWorks's Petstore2 Rails demo application as fast as possible. The application was tweaked so that there was no database usage. Numbers are requests/minute and denote with/without downloading associated static content (js/css/etc). Everything was running locally on my MacBook Pro 2.2Ghz.

```
Glassfish 790/833
Mongrel 309/621
2 Mongrels 318/1077
2 Mongrels + Nginx 888/1050
Glassfish + Nginx 815/845
```

#### Findings

As you can see, Glassfish suffers from Java's extreme memory usage. There's no point in using Java in a resource constrained server. On the performance side, Mongrel's static file handling is pathetically slow; there's a reason why everyone uses NginX as a frontend to Mongrel -- to serve static content. Glassfish's static content handling is much faster -- I didn't see much improvement when disabling static content or using Nginx to serve it, which shows that it wasn't taking significant amounts of CPU time. Ultimately Glassfish is constrained by JRuby's underlying Ruby performance -- since this is currently making leaps forward, we should see much faster performance from Glassfish/JRuby in the next six months as the JRuby compiler and other improvements become available. I don't see any hope for the memory issue though. What options are there to control the JVM's voracious appetite for RAM?

Realistically, there's no technical reason I can determine to use Glassfish currently. It doesn't offer better performance than a Mongrel cluster, uses more memory and has a total lack of documentation and tuning options. It will certainly become more viable as performance improves and documentation becomes available.

UPDATE: I tried running Glassfish with JRuby HEAD and there was no significant performance difference.  Disappointing, considering there are supposed to be major performance improvements coming soon.

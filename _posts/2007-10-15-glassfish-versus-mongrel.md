---
title: Glassfish versus Mongrel
author: Mike Perham
layout: post
permalink: /2007/10/15/glassfish-versus-mongrel/
categories:
  - Rails
---
I&#8217;ve been working on my upcoming AOR Glassfish talk. Here&#8217;s some interesting numbers. (Unfortunately WordPress is pretty bad at offering good HTML formatting tools so you&#8217;ll have to put up with some sad formatting.)

#### Memory Usage

<pre>Glassfish - 230MB resident, 840MB virtual
Mongrel Cluster (2 nodes) - 46MB resident, 104MB virtual
Nginx (2 workers) - 2MB resident, 84MB virtual</pre>

#### Page Times

This metric used Apache JMeter to simulate 25 users (threads) to request the home page for ThoughtWorks&#8217;s Petstore2 Rails demo application as fast as possible. The application was tweaked so that there was no database usage. Numbers are requests/minute and denote with/without downloading associated static content (js/css/etc). Everything was running locally on my MacBook Pro 2.2Ghz.

<pre>Glassfish 790/833
Mongrel 309/621
2 Mongrels 318/1077
2 Mongrels + Nginx 888/1050
Glassfish + Nginx 815/845</pre>

#### Findings

As you can see, Glassfish suffers from Java&#8217;s extreme memory usage. There&#8217;s no point in using Java in a resource constrained server. On the performance side, Mongrel&#8217;s static file handling is pathetically slow; there&#8217;s a reason why everyone uses NginX as a frontend to Mongrel &#8211; to serve static content. Glassfish&#8217;s static content handling is much faster &#8211; I didn&#8217;t see much improvement when disabling static content or using Nginx to serve it, which shows that it wasn&#8217;t taking significant amounts of CPU time. Ultimately Glassfish is constrained by JRuby&#8217;s underlying Ruby performance &#8211; since this is currently making leaps forward, we should see much faster performance from Glassfish/JRuby in the next six months as the JRuby compiler and other improvements become available. I don&#8217;t see any hope for the memory issue though. What options are there to control the JVM&#8217;s voracious appetite for RAM?

Realistically, there&#8217;s no technical reason I can determine to use Glassfish currently. It doesn&#8217;t offer better performance than a Mongrel cluster, uses more memory and has a total lack of documentation and tuning options. It will certainly become more viable as performance improves and documentation becomes available.

UPDATE: I tried running Glassfish with JRuby HEAD and there was no significant performance difference.  Disappointing, considering there are supposed to be major performance improvements coming soon.
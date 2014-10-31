---
title: Apache Tuning
author: Mike Perham
layout: post
permalink: /2010/11/22/apache-tuning/
categories:
  - Software
---
Want to wreck your afternoon? Just have a poorly configured WordPress install linked from Hacker News. Here&#8217;s the postmortem.

In my case, my slice was freezing. I didn&#8217;t know what the problem was until I ran `top` and saw [this][1]. Yikes.

The problem was the Apache is configured by default to allow up to 150 Apache processes. Each process took 5-10MB of real memory so my slice&#8217;s 512MB was quickly overwhelmed. But why was it creating 150 processes in the first place? Shouldn&#8217;t WP-SuperCache respond very quickly, such that the process can serve many requests per second? Yes, but&#8230;

**Keep-Alives**

[Keep-Alives][2] try to help client performance. This is a performance tweak that will kill you. By default, Apache is configured to hold the process locked for a given socket for 15 seconds (!!?) in case that socket makes another request. **That&#8217;s a terrible, terrible default: you should never lock resources waiting for human input.** So in 15 seconds, Hacker News delivered me 50-100 requests. These requests all generated their own process, quickly overwhelming my RAM and swap and effectively freezing my slice.

I lowered the maximum number of processes (MaxClients) to 20 and the keep-alive timeout from 15 to 2 seconds. Before I was seeing load averages in the 100s and since reconfiguration, my slice&#8217;s load average has been under 1 all afternoon. Here&#8217;s the config I changed:

> #  
> \# KeepAliveTimeout: Number of seconds to wait for the next request from the  
> \# same client on the same connection.  
> #  
> KeepAliveTimeout 2
> 
> ##  
> \## Server-Pool Size Regulation (MPM specific)  
> ##
> 
> \# prefork MPM  
> \# StartServers: number of server processes to start  
> \# MinSpareServers: minimum number of server processes which are kept spare  
> \# MaxSpareServers: maximum number of server processes which are kept spare  
> \# MaxClients: maximum number of server processes allowed to start  
> <IfModule mpm\_prefork\_module>  
> StartServers 5  
> MinSpareServers 5  
> MaxSpareServers 10  
> MaxClients 20  
> </IfModule>

 [1]: https://gist.github.com/c94c6596447c9544c1a0
 [2]: http://virtualthreads.blogspot.com/2006/01/tuning-apache-part-1.html
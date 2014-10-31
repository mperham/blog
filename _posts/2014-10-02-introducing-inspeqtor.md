---
title: Introducing Inspeqtor
author: Mike Perham
layout: post
permalink: /2014/10/02/introducing-inspeqtor/
categories:
  - Inspeqtor
---
I&#8217;ve written server-side applications for a decade now, and monitoring the components of your application is critical but painful. What monitors the CPU and RAM usage of your custom daemons? What monitors Redis, MySQL, memcached and the other parts of your system to ensure they are all behaving normally? What if I told you you could do all that and set it up in less than 5 minutes?

Say hello to [Inspeqtor][1]!

[<img src="http://www.mikeperham.com/wp-content/uploads/2014/09/logo-inspeqtor.png" alt="logo-inspeqtor" width="370" height="74" class="alignnone size-full wp-image-1840" />][2]

<!--more-->

Inspeqtor is a Linux daemon which understands processes and major, popular pieces of application infrastructure. You write very simple rules about the services running on the machine and Inspeqtor will notify you when those rules are breached, processes disappear or change PID.

Inspeqtor understands the notion of an **application deploy** and will not notify you during the deploy process since change is normal and expected.

I want Inspeqtor to be incredibly easy to set up and monitor common, useful metrics. Here&#8217;s how to monitor mysql:

<pre class="brush: bash; gutter: false; title: ; notranslate" title=""># /etc/inspeqtor/conf.d/mysql.inq
check service mysql with username dbuser, password thepass, socket /tmp/mysql.sock
  if memory:rss &gt; 1g then alert
  if cpu:user &gt; 90% then alert
  # inspeqtor checks every 15 seconds
  # more than 50 queries per sec, let me know
  if mysql:Queries &gt; 750 then alert
  # watch out for those slow queries!
  if mysql:Slow_queries &gt; 10 then alert
  # you can even monitor slave replication lag!
  if mysql:Seconds_Behind_Master &gt; 30 then alert
</pre>

**That&#8217;s it**, just a few words of readable English, no XML, YAML or other painful formats. Inspeqtor talks to your init system to find the PID and monitor CPU and RAM. It knows how to log into mysql to gather metrics.

**Look at this awesomeness**

Get current status of all services with `inspeqtorctl status`:

[<img src="http://www.mikeperham.com/wp-content/uploads/2014/09/Screen-Shot-2014-09-29-at-10.15.39.png" alt="Screen Shot 2014-09-29 at 10.15.39" width="545" height="158" class="alignnone size-full wp-image-1906" />][3]

See the graph for a specific metric over the last hour **right in your console** with `inspeqtorctl show host load:1`:

[<img src="http://www.mikeperham.com/wp-content/uploads/2014/09/Screen-Shot-2014-09-26-at-10.39.09.png" alt="Screen Shot 2014-09-26 at 10.39.09" width="524" height="42" class="alignnone size-full wp-image-1892" />][4]

Inspeqtor is a single binary written in Go. It has no runtime dependencies and uses little memory. I&#8217;m hoping a fast, efficient language makes for a monitoring tool you can rely on.

**But wait, THERE&#8217;S MORE!**

Of course there&#8217;s [Inspeqtor Pro][1]. The commercial version adds even more features:

*   route alerts to different teams or individuals per machine, per service or per rule
*   route alerts to your team chat room via Slack, HipChat, Campfire or Flowdock
*   monitor legacy init.d services via pid files
*   **many** more features to come&#8230;
*   dedicated email support
*   that blissful feeling knowing you are supporting high quality OSS

This is a tool I&#8217;ve wanted to build for years and I finally got the opportunity to make it real. I hope Inspeqtor becomes an indispensable tool in your devops toolkit but please remember this is brand new software and we&#8217;re not at version 1.0 yet. **I&#8217;m going to spend the next few years making it awesome. [If you want to help me, here&#8217;s the place to start][5].**

Finally, thank you to @obfuscurity, @benbjohnson and other early reviewers for their great pre-release feedback.

Useful Links:  
* [Getting Started][6]  
* [Inspeqtor documentation][7]  
* [Inspeqtor source][5]  
* [Inspeqtor Pro][1]

 [1]: http://www.contribsys.com/inspeqtor/
 [2]: http://www.contribsys.com/inspeqtor/ "Inspeqtor"
 [3]: http://www.mikeperham.com/wp-content/uploads/2014/09/Screen-Shot-2014-09-29-at-10.15.39.png
 [4]: http://www.mikeperham.com/wp-content/uploads/2014/09/Screen-Shot-2014-09-26-at-10.39.09.png
 [5]: https://github.com/mperham/inspeqtor
 [6]: https://github.com/mperham/inspeqtor/wiki#getting-started
 [7]: https://github.com/mperham/inspeqtor/wiki
---
title: 'Inspeqtor 0.6.0 &#8211; init.d, cron and statsd!'
author: Mike Perham
layout: post
permalink: /2014/10/23/inspeqtor-0-6-0-init-d-cron-and-statsd/
categories:
  - Inspeqtor
---
Inspeqtor is my new take on application infrastructure monitoring. You use it to verify rules about your database, web server, caches, etc and if anything is wrong, Inspeqtor will alert you. After the initial release 3 weeks ago, I was distracted a bit by a DMCA takedown from a similar project but thankfully that went away quickly. Since then I&#8217;ve added several awesome new features!

**What&#8217;s new?**
<!--more-->

### Init.d Support

I&#8217;ll admit, I got this decision wrong. Init.d support was initially an Inspeqtor Pro feature but it&#8217;s been pulled down into Inspeqtor and open sourced. Unfortunately there are many instances of core infrastructure (e.g. nginx) still distributing themselves with a dumb sysvinit script. Users can&#8217;t control this and it&#8217;s not fair to tell them I won&#8217;t support it due to my own dislike of init.d.

Inspeqtor can now monitor init.d-based services that use PID files. Follow the instructions on the Initd [wiki page][1] to ensure Inspeqtor can find the PID file for your service.

### Rate Support

You can now specify your rules in &#8220;per second&#8221; rates. Previously you had to give a raw number which implicitly depended on the 15 second cycle time. Now your threshold is clearer:

<pre>
# /etc/inspeqtor/services.d/mysql.inq
check service mysql
  # before
  if mysql:Queries &gt; 750 then alert
  # now!
  if mysql:Queries &gt; 50/sec then alert
</pre>

### Export data

Use the new `inspeqtorctl export` command to dump the latest metric data in JSON format. There&#8217;s a million things you can do once you have the raw data: your imagination is the only limit!

Inspeqtor got a few new features and so did [Inspeqtor Pro][2].

### Pro &#8211; Monitor recurring jobs

Cron jobs are special because they run in their own cron environment sandbox and are easy to misconfigure. At some point every developer has seen a cron job which works perfectly on their own machine but fails in production due to some environmental bug. With Inspeqtor Pro you give it a list of jobs in /etc/inspeqtor/jobs.d/*.inq along with how often they should &#8220;check in&#8221; and Inspeqtor will alert you if a job has not checked in within the given window.

<pre>
# /etc/inspeqtor/jobs.d/whatever.inq
check jobs
  bank_transfer happens every 2 hours
  warehouse_ftp happens every day
</pre>

Each job calls inspeqtorctl to check in and tell Inspeqtor it finished successfully.

<pre>
&gt; inspeqtorctl job_done warehouse_ftp
OK
</pre>

If Inspeqtor does not see a check in within the given period of time, it will fire an alert. [More detail in the wiki][3].

### Pro &#8211; Export to Statsd

Inspeqtor Pro can send collected metrics directly to your Statsd server, meaning you can graph and visualize them with Graphite, Librato, Datadog or others. The integration literally couldn&#8217;t be simpler, requiring just a single line to your inspeqtor.conf:

<pre>
# /etc/inspeqtor/inspeqtor.conf
set statsd_location localhost:8125
</pre>

Now you can see your metrics, like this:

[<img src="/wp-content/uploads/2014/10/Screen-Shot-2014-10-22-at-10.49.24.png" alt="Screen Shot 2014-10-22 at 10.49.24" width="623" height="203" class="alignnone size-full wp-image-1979" />][4]

That&#8217;s 0.6.0 in a nutshell! If you aren&#8217;t using Inspeqtor yet, [here&#8217;s how to get started][5].

 [1]: https://github.com/mperham/inspeqtor/wiki/Initd
 [2]: http://contribsys.com/inspeqtor
 [3]: https://github.com/mperham/inspeqtor/wiki/Pro-Recurring-Jobs
 [4]: http://www.mikeperham.com/wp-content/uploads/2014/10/Screen-Shot-2014-10-22-at-10.49.24.png
 [5]: https://github.com/mperham/inspeqtor/wiki

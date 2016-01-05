---
title: "Contributed Systems: the 2015 wrapup"
author: Mike Perham
layout: post
permalink: /2016/01/05/contributed-systems-2015
---

In July 2014 I started my company Contributed Systems and work on Sidekiq full-time.
Let's review how 2015 went.  The end of January will be Sidekiq's 4th
birthday so here's some birthday numbers:

<style>
table {
  border-collapse: separate;
  border-spacing: 0;
  border: 1px solid #000;
}

th, td, caption {
  border: 1px solid #000;
  padding: 0.3em;
}
</style>
<table width="100%">
<tr><th>&nbsp;</th><th>1st Birthday</th><th>2nd Birthday</th><th>4th Birthday</th></tr>
<tr><th>Downloads</th><td>214,300</td><td>1,192,259</td><td>5,505,145</td></tr>
<tr><th>Stars</th><td>2144</td><td>3535</td><td>5846</td></tr>
<tr><th>Closed Issues</th><td>663</td><td>1420</td><td>1887</td></tr>
<tr><th>Forks</th><td>266</td><td>563</td><td>1003</td></tr>
<tr><th>Closed PRs</th><td>228</td><td>380</td><td>836</td></tr>
<tr><th>Versions</th><td>44</td><td>74</td><td>110</td></tr>
<tr><th>Customers</th><td>25</td><td>200</td><td>675</td></tr>
<tr><th>Employees</th><td>0</td><td>0</td><td>1</td></tr>
</table>
<br/>

### Good News

In 2015, I:

* released Sidekiq Pro 2.0 with nested batches and expiring jobs
* introduced Sidekiq Enterprise, with rate limiting, cron job and unique job features
* released Sidekiq 4.0 with a simpler and higher performance core
* released Sidekiq Pro 3.0 and Enterprise 1.0 major upgrades
* attended Railsconf and Rubyconf, passing out t-shirts and stickers

As for business numbers, **my revenue is up 2.6x YoY from 2014**.
Average sales price has doubled due to the introduction and demand for Sidekiq Enterprise.

When I started Sidekiq and Sidekiq Pro in 2012, I had three goals I
never mentioned to anyone to measure my own success:

1. change the standard advice of "use resque or DJ" to "use resque, sidekiq or DJ"
1. pass resque as the most popular job framework
1. make $1 million from Sidekiq Pro by selling 2000 copies for $500 over five years.

The latest [State of the Rails Stack 2016][0] shows that I've blown away
(1) and (2).  Sidekiq now has more market share than Resque and DJ
combined.  Market leader achievement unlocked!

![market share](/images/marketshare.png)

(3) has been a learning experience: note the slow down in customer
growth from 1 -> 2 -> 4 years.  Like any business-focused niche software product,
a small customer pool means a higher price is demanded (versus the original $500 price);
it turns out to be easier to convert 500 customers at $2000 each.
Given the amount of functionality in Pro and Enterprise, it doesn't take long
for businesses to realize that the value is there:
no engineering time and effort necessary to build and maintain their own
gems, a steady stream of fixes and improvements, expert support only an email away, etc.

(3) will be met: 2016 will be the year I pass $1 million in total revenue, right on schedule.

### Bad News

At the end of 2014 I introduced Inspeqtor and Inspeqtor Pro as a
second product line for Contributed Systems with the vision of
building a modern process monitoring system.

I still believe the product is amazing -- it's the replacement for monit
that I've always wanted -- but it's hard to argue with the facts:
uptake and sales have been minimal.  What's there is stable and people
are welcome to use it; I won't be adding any more features.

### Conclusion

Sidekiq has been a success, Inspeqtor a failure.  In baseball, a .500 batting
average is superhuman.  I'll take it.  I hope your 2015 went well and cheers to 2016!

[0]: http://blog.scoutapp.com/articles/2015/12/29/state-of-the-2016-rails-stack

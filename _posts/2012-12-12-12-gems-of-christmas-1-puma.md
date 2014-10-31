---
title: '12 Gems of Christmas #1 &#8211; puma'
author: Mike Perham
layout: post
permalink: /2012/12/12/12-gems-of-christmas-1-puma/
categories:
  - Ruby
---
I&#8217;ve spent the last few years working to advance and improve Ruby&#8217;s efficiency through concurrency, first with EventMachine and fibers and now with Actors and multithreading so it shouldn&#8217;t surprise you that my #1 pick is [puma][1]. It&#8217;s my belief that puma and [sidekiq][2] are a new breed of Ruby infrastructure that can dramatically improve your application&#8217;s efficiency &mdash; should you decide to take advantage of them.

puma is a pure Ruby, Rack-based web server and drops right in as a replacement for thin or unicorn. Unlike unicorn or thin, puma is designed to run multithreaded by default so you get far better memory efficiency. A typical single threaded Rails unicorn process takes 250MB. puma defaults to a maximum of 16 threads per process so one puma process can replace 16 unicorn processes taking 4GB of RAM! puma, like all multithreaded libraries, works best in a truly concurrent Ruby VM like JRuby or Rubinius but you&#8217;ll still get a big win running on MRI.

To test this, I ran 50 concurrent requests 20 times for a total of 1000 requests against a non-trivial endpoint on [TheClymb.com][3] Rails application. config.threadsafe! was enabled, a database pool size of 10 and puma&#8217;s default of 16 threads. Each request makes two database queries and renders a slim-based template.

[<img src="http://www.mikeperham.com/wp-content/uploads/2012/12/Screen-Shot-2012-12-04-at-9.56.49-PM.png" alt="" title="Screen Shot 2012-12-04 at 9.56.49 PM" width="612" height="227" class="aligncenter size-full wp-image-1070" />][4]

Unicorn/MRI 1.9.3 is the baseline: single-threaded, it runs the 1000 requests in 19 seconds. Puma/MRI manages to speed up a bit but is still hampered by the GIL and runs in 15 seconds. Puma/JRuby unlocks the second core on my MacBook Air and runs in under 9 seconds!

What this means is simple: threading with puma will get you better performance than Unicorn, even on MRI, and jumping to [JRuby][5] gets you a significantly bigger boost by giving you truly parallel threads. It took me about one hour to get our Rails app, which has always run on MRI, working with JRuby. Give JRuby a try some weekend and you might be surprised how well it works!

I hope you enjoyed my 12 Gems of Christmas series and found a few gems that were worthy of further study.

 [1]: http://puma.io
 [2]: http://sidekiq.org
 [3]: http://theclymb.com/invite-from/mperham
 [4]: http://www.mikeperham.com/wp-content/uploads/2012/12/Screen-Shot-2012-12-04-at-9.56.49-PM.png
 [5]: http://jruby.org
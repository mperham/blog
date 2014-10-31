---
title: '12 Gems of Christmas #5 &#8211; lograge'
author: Mike Perham
layout: post
permalink: /2012/12/08/12-gems-of-christmas-5-lograge/
categories:
  - Rails
---
Rails has a problem: its production logging is somewhat lacking. By default, Rails will emit a bunch of lines for each request, which makes grepping the output tougher than it should be. Look at this, it&#8217;s nice to look at but painful to aggregate:

<pre>Started GET "/" for 127.0.0.1 at 2012-03-10 14:28:14 +0100
Processing by HomeController#index as HTML
  Rendered text template within layouts/application (0.0ms)
  Rendered layouts/_assets.html.erb (2.0ms)
  Rendered layouts/_top.html.erb (2.6ms)
  Rendered layouts/_about.html.erb (0.3ms)
  Rendered layouts/_google_analytics.html.erb (0.4ms)
Completed 200 OK in 79ms (Views: 78.8ms | ActiveRecord: 0.0ms)
</pre>

[Lograge][1] &#8216;tames&#8217; Rails production logging setup to emit one line per request, a la Apache or nginx. The output is key-value pairs; parsing it into a hash is trivial. Here&#8217;s some output from [The Clymb][2] production logging with lograge enabled:

<pre>Nov 24 13:31:27 app-1 rails[22622]: method=GET path=/brand-event/2818/show-product/183537?f=mi format=html controller=presentations action=show_product status=200.00 duration=237.54 view=206.14 db=17.12
Nov 24 13:31:28 app-1 rails[22630]: method=GET path=/brand-event/2818/show-product/183539?f=mi format=html controller=presentations action=show_product status=200.00 duration=125.37 view=94.05 db=17.59
Nov 24 13:31:28 app-1 rails[22622]: method=GET path=/brand-event/2818/show-product/183541?f=mi format=html controller=presentations action=show_product status=200.00 duration=117.47 view=86.00 db=16.79
Nov 24 13:31:28 app-1 rails[22630]: method=GET path=/brand-event/2818/show-product/183548?f=mi format=html controller=presentations action=show_product status=200.00 duration=132.09 view=97.69 db=20.69
Nov 24 13:31:28 app-1 rails[22622]: method=GET path=/brand-event/2818/show-product/183554?f=mi format=html controller=presentations action=show_product status=200.00 duration=119.36 view=84.44 db=18.87
Nov 24 13:31:29 app-1 rails[22622]: method=GET path=/basket/tracking_pixels format=html controller=baskets action=tracking_pixels status=200.00 duration=71.47 view=41.00 db=23.65
</pre>

Ah, much cleaner! (and notice the HTTP status value is a float. :-) This format gives us the critical request information required for performance tuning and is easily digestible by simple scripts. Enabling it is trivial:

<pre lang="ruby"># config/environments/production.rb
MyApp::Application.configure do
  config.lograge.enabled = true
end
</pre>

Much happier logs lead to much happier developers. Happy logging! Tomorrow I&#8217;ll cover a gem (or two!?) designed to make email development happier&#8230;

 [1]: https://github.com/roidrage/lograge
 [2]: http://theclymb.com/invite-from/mperham
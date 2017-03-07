---
author: Mike Perham
categories:
- Rails
- Ruby
date: 2009-03-25T00:00:00Z
title: Caching and Rails
url: /2009/03/25/caching-and-rails/
---

Here's the slides from my AOR talk last night: [Caching, Memcached and Rails][1] (600KB).

<div style="width:425px;text-align:left" id="__ss_1196725">
  <a style="font:14px Helvetica,Arial,Sans-serif;display:block;margin:12px 0 3px 0;text-decoration:underline;" href="http://www.slideshare.net/guestac752c/caching-memcached-and-rails?type=presentation" title="Caching, Memcached And Rails">Caching, Memcached And Rails</a> <div style="font-size:11px;font-family:tahoma,arial;height:26px;padding-top:2px;">
  </div>
</div>

I was a little unhappy with my wrapup -- the one thing I wanted to teach people was when to use each different caching mechanism provided by Rails and I didn't really revisit and summarize that content. So here's a quick summary:

*   HTTP caching -- prefer this over all other mechanisms. This is really the only mechanism that prevents the request from ever hitting Ruby. This topic is big enough for a book so I won't cover it here but review the Expires, Etag and Cache-Control headers to understand how HTTP caching works. You'll need to configure Varnish, Squid, mod_cache or some other HTTP caching proxy.
*   Page caching -- I believe this is really legacy from before Rails supported HTTP caching properly. Stick with HTTP caching and proper headers.
*   Action caching -- useful when the entire page contents can be cached but you need to run before_filters (e.g. to ensure the user is logged in). Use AJAX/javascript to do minor customization to the cached content.
*   Fragment caching -- useful when various boxes of content on the page can be cached, but have different dependencies and need to be expired at different times
*   Object caching (the Rails.cache.fetch method) -- the most granular mechanism. Good for caching the results of intensive logic or queries.

I hope this helps demystify the myriad of caching mechanisms Rails supports. If you want to learn even more, Gregg Pollack has an amazing set of videos on [Scaling Rails][2] which covers caching in great depth. Happy Caching!

 [1]: http://www.mikeperham.com/wp-content/uploads/2009/03/caching-memcached-and-rails.key
 [2]: http://railslab.newrelic.com/scaling-rails

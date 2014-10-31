---
title: Introducing Phat, an Asynchronous Rails app
author: Mike Perham
layout: post
permalink: /2010/04/03/introducing-phat-an-asynchronous-rails-app/
categories:
  - Rails
tags:
  - eventmachine
---
[Phat][1] is my new Rails 2.3.5 application which runs 100% asynchronous, supporting many concurrent requests in a single Ruby process.

This is a new breed of Rails application which uses a new mode of execution available in Ruby 1.9: single Thread, multiple Fiber. Existing modes of execution suck:

*   Single thread harkens back to the days of Rails 1.x, where you started N mongrels to handle up to N concurrent requests.
*   Multiple threads is better but still has fundamental issues in Ruby. [Autoloading is simply broken][2] and Ruby&#8217;s thread implementation does not scale at all due to the GIL.

Here&#8217;s a sample action which uses memcached and the database. There&#8217;s nothing odd here &#8211; it&#8217;s the same old Rails API and codebase we are used to as Ruby developers, it just executes differently under the covers.

<pre lang="ruby">class HelloController &lt; ApplicationController
  def world
    site_ids = Rails.cache.fetch 'site_ids', :expires_in => 1.minute do
      Site.all.map(&#038;:id)
    end
    render :text => site_ids
  end
end
</pre>

How does it work? If you want the nitty-gritty, [watch my talk on EventMachine and Fibers][3]. Everything that does network access ideally should be modified to be Fiber-aware. I&#8217;ve updated many gems to be Fiber-aware: [memcache-client][4], [em_postgresql][5] (and activerecord), cassandra, bunny and rsolr to name a few. You&#8217;ll also need to run thin as your app server, since all of this code assumes it is executing within EventMachine.

Additionally we need to ensure that each request runs in its own Fiber. My new gem, [rack-fiber_pool][6], will do this for you, just add it as Rack middleware in `config/environment.rb`. Here&#8217;s the basic configuration:

<pre lang="ruby"># Asynchronous DNS lookup
require 'em-resolv-replace'
require 'rack/fiber_pool'
# Pull in the evented memcache-client.
# You'll need to configure config.cache_store as normal.
require 'memcache/event_machine'

Rails::Initializer.run do |config|
  config.cache_store = :mem_cache_store
  # Run each request in a Fiber
  config.middleware.use Rack::FiberPool
  # Get rid of Rack::Lock so we don't kill our concurrency
  config.threadsafe!
end
</pre>

Additionally we need to [configure Postgresql][7] and [disable ActionController&#8217;s reloader mutex][8] as it really doesn&#8217;t like fibered execution. This is ok because remember &#8211; there&#8217;s only a single thread executing in our process!

With that done, we can try some tests to see how we scale now. EventMachine works best when you have significant network latency. A simple test with database access over coffeeshop WiFi:

> Without EventMachine:  
> Requests per second: 4.39 \[#/sec\] (mean)
> 
> With EventMachine:  
> Requests per second: 21.31 \[#/sec\] (mean) 

That&#8217;s it! There&#8217;s no magic here: you can make your Rails app a &#8220;phat&#8221; app by following the same guidelines above. Fire up one thin instance per processor/core, put nginx in front of it and it should scale like crazy!

 [1]: http://github.com/mperham/phat
 [2]: http://redmine.ruby-lang.org/issues/show/921
 [3]: /2010/01/27/scalable-ruby-processing-with-eventmachine/
 [4]: http://github.com/mperham/memcache-client
 [5]: http://github.com/mperham/em_postgresql
 [6]: http://github.com/mperham/rack-fiber_pool
 [7]: http://github.com/mperham/phat/blob/master/config/database.yml
 [8]: http://github.com/mperham/phat/blob/master/config/initializers/disable_locking.rb
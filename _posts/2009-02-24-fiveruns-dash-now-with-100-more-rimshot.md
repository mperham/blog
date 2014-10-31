---
title: FiveRuns Dash, now with 100% more rimshot!
author: Mike Perham
layout: post
permalink: /2009/02/24/fiveruns-dash-now-with-100-more-rimshot/
categories:
  - Personal
  - Rails
---
I&#8217;m giving away a free copy of my iPhone app, [Zinger][1], to every person who gets their app running with our new metrics service, [Dash][2]. Just email me. Steps ([documented in more depth here][3]):

1) Request an invite by signing up at <https://dash.fiveruns.com>  
2) Log into Dash, create a new Rails application and note your application token.  
3) Install the gem:

<pre>sudo gem install json
sudo gem install fiveruns-dash-rails -s http://gems.github.com
</pre>

4) Add the gem to your `config/environment.rb`

<pre lang="ruby">Rails::Initializer.run do |config|
  config.gem 'json' # needed because of a bug in json_pure
  config.gem 'fiveruns-dash-rails',
             :lib => 'fiveruns_dash_rails',
             :source => 'http://gems.github.com'
</pre>

5) Add the initializer file `config/initializers/dash.rb` to start Dash:

<pre lang="ruby">if defined?(Fiveruns::Dash)
  Fiveruns::Dash::Rails.start(:production => 'YOUR-APP-TOKEN-HERE')
end
</pre>

This will start Dash in the production environment. We don&#8217;t recommend using Dash in development mode. If you have a staging environment, you can create a separate app for that environment and combine the two like so:

<pre lang="ruby">if defined?(Fiveruns::Dash)
  Fiveruns::Dash::Rails.start(:production => 'PROD-TOKEN', :staging => 'STAGE-TOKEN')
end
</pre>

Email me if you have problems &#8211; I&#8217;m happy to help people give Dash a test drive. Dash is 100% free right now until we&#8217;ve worked out pricing models but rest assured there will always be a free tier so you don&#8217;t have to worry about your app costing you money in the future. I hope your Dash test drive is full of rimshots with no sad trombones!

 [1]: http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=301088210&mt=8
 [2]: http://dash.fiveruns.com
 [3]: http://support.fiveruns.com/faqs/dash/rails
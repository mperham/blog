---
author: Mike Perham
categories:
- Personal
- Rails
date: 2009-02-24T00:00:00Z
title: FiveRuns Dash, now with 100% more rimshot!
url: /2009/02/24/fiveruns-dash-now-with-100-more-rimshot/
---

I'm giving away a free copy of my iPhone app, [Zinger][1], to every person who gets their app running with our new metrics service, [Dash][2]. Just email me. Steps ([documented in more depth here][3]):

1) Request an invite by signing up at <https://dash.fiveruns.com>  
2) Log into Dash, create a new Rails application and note your application token.  
3) Install the gem:

```
sudo gem install json
sudo gem install fiveruns-dash-rails -s http://gems.github.com
```

4) Add the gem to your `config/environment.rb`

```ruby
Rails::Initializer.run do |config|
  config.gem 'json' # needed because of a bug in json_pure
  config.gem 'fiveruns-dash-rails',
             :lib => 'fiveruns_dash_rails',
             :source => 'http://gems.github.com'
```

5) Add the initializer file `config/initializers/dash.rb` to start Dash:

```ruby
if defined?(Fiveruns::Dash)
  Fiveruns::Dash::Rails.start(:production => 'YOUR-APP-TOKEN-HERE')
end
```

This will start Dash in the production environment. We don't recommend using Dash in development mode. If you have a staging environment, you can create a separate app for that environment and combine the two like so:

```ruby
if defined?(Fiveruns::Dash)
  Fiveruns::Dash::Rails.start(:production => 'PROD-TOKEN', :staging => 'STAGE-TOKEN')
end
```

Email me if you have problems -- I'm happy to help people give Dash a test drive. Dash is 100% free right now until we've worked out pricing models but rest assured there will always be a free tier so you don't have to worry about your app costing you money in the future. I hope your Dash test drive is full of rimshots with no sad trombones!

 [1]: http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=301088210&mt=8
 [2]: http://dash.fiveruns.com
 [3]: http://support.fiveruns.com/faqs/dash/rails

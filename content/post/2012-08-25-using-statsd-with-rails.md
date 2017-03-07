---
author: Mike Perham
categories:
- Rails
- Ruby
date: 2012-08-25T00:00:00Z
title: Using Statsd with Rails
url: /2012/08/25/using-statsd-with-rails/
---

One of the things I've had on my mind at [The Clymb][1] is better runtime monitoring for our website and servers. We have NewRelic but I always want more. With this in mind, I decided to try out [statsd][2] to collect and aggregate metrics for visualization. By using statsd, you get two benefits: 1) metric aggregation so you don't have to pay for N machines reporting metrics to a pay service and 2) control over where your metrics go so you can route them to Graphite, Librato Metrics or any other standard metrics service.

First you'll need to install a [Ruby client][3]. The Ruby client has a nice simple API for collecting various types of metrics: counters, gauges, timings, etc.

<pre lang="sh">gem install statsd-ruby
</pre>

Next you'll create an initializer to instantiate the client. Note I use a namespace to differentiate between a Rails process and a Sidekiq process.

<pre lang="ruby">METRICS = Statsd.new('stats-collector.acmecorp.com', 8125)
METRICS.namespace = (Sidekiq.server? ? 'sidekiq' : 'web')
</pre>

Now you'll need to sprinkle metrics reporting throughout the important parts of your application. I hooked up some basic metrics for [Rack][4], Redis and ActiveRecord:

<pre lang="ruby"># Rack stats, courtesy of technoweenie
Rails.application.middleware.insert_before ActionDispatch::Static, RackStatsD::ProcessUtilization, :stats => METRICS

SELECT_DELETE = / FROM `(w+)`/
INSERT = /^INSERT INTO `(w+)`/
UPDATE = /^UPDATE `(w+)`/

ActiveSupport::Notifications.subscribe "sql.active_record" do |name, start, finish, id, payload|
  case payload[:sql]
  when /^SELECT/
    payload[:sql] =~ SELECT_DELETE
    METRICS.increment('sql.select')
    METRICS.timing("sql.#{$1}.select.query_time", (finish - start) * 1000, 1)
  when /^DELETE/
    payload[:sql] =~ SELECT_DELETE
    METRICS.increment('sql.delete')
    METRICS.timing("sql.#{$1}.delete.query_time", (finish - start) * 1000, 1)
  when /^INSERT/
    payload[:sql] =~ INSERT
    METRICS.increment('sql.insert')
    METRICS.timing("sql.#{$1}.insert.query_time", (finish - start) * 1000, 1)
  when /^UPDATE/
    payload[:sql] =~ UPDATE
    METRICS.increment('sql.update')
    METRICS.timing("sql.#{$1}.update.query_time", (finish - start) * 1000, 1)
  end
end

class Redis::Client
  # HACK: This overrides the normal Redis gem debug logging.
  def logging(commands, &#038;block)
    METRICS.time("redis.#{commands.first.first}.time", &#038;block)
  end
end
</pre>

Now that we have some basic runtime stats, we still have two never-ending tasks:

1) more metrics! Once you have a good solution in place, it becomes easy to add more metrics for new functionality or infrastructure -- something which no pre-packaged system can provide. You'll want to better tune what metrics you have and add more if you still need more data.  
2) alerts and visualization! Metrics are pointless if you aren't using them to monitor for problems and/or determine a course of action. Ideally a graph can show at a glance if there is a problem.

 [1]: http://www.theclymb.com/invite-from/mperham
 [2]: http://github.com/etsy/statsd
 [3]: https://github.com/reinh/statsd
 [4]: https://github.com/TheClymb/rack-statsd

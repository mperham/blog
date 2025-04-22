---
author: Mike Perham
categories:
- Ruby
date: 2012-12-02T00:00:00Z
title: '12 Gems of Christmas #11 -- statsd-ruby'
url: /2012/12/02/12-gems-of-christmas-11-statsd-ruby/
---

As software developers, it's often our job to monitor the systems we build. Step one is to collect the data necessary for monitoring.

Statsd is a nice metrics aggregation server open sourced by Etsy. We use Statsd at [The Clymb][1] to collect and aggregate various technical and business metrics before uploading them to Librato Metrics for storage and display on our dashboards.

<img alt="" src="http://sidekiq.org/examples/librato.png" title="metrics" class="alignleft" width="320" height="200" />

The [statsd-ruby][2] client sends metrics from all our Unicorn and Sidekiq processes to statsd. One thing I really like about statsd is that it uses UDP for network transport so sending a metric doesn't incur much overhead at all and I don't have to have statsd installed locally or in staging -- the metric send will just silently fail. We set up a global METRICS variable with a Statsd client instance (instances are thread-safe so this is ok, even with Sidekiq) so our code can send metrics trivially:

```ruby
statsd_host = Rails.env.production? ? '10.10.1.100' : '127.0.0.1'
METRICS = Statsd.new(statsd_host, 8125)
METRICS.namespace = (Sidekiq.server? ? 'sidekiq' : 'web')
```

Now we just sprinkle metrics throughout our code. Want to track the number and value of orders that your e-commerce site gets?

```ruby
METRICS.increment('orders')
METRICS.count('orders.total', @basket.total) if @basket.total > 0
```

Remember that we might have hundreds of Unicorn processes so statsd will collect and aggregate all the individual metric packets from each process into a single metric value to upload to your metrics service. With statsd and statsd-ruby working for you, you can monitor the metrics important to your business and verify the behavior of your system at runtime.

Tomorrow we'll discuss a bane of the Rails world: testing JavaScript!

 [1]: http://www.theclymb.com/invite-from/mperham
 [2]: https://github.com/reinh/statsd "statsd-ruby"

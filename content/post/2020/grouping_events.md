---
title: "Grouping Events for Later Processing"
date: 2020-12-14T10:03:29-08:00
publishdate: 2020-12-14
lastmod: 2020-12-14
tags: []
---

A customer recently wondered how they could handle aggregate events in
Sidekiq. They don't want one background job per event but rather a
background job to handle the last N events.

Let's pretend we work for
an ecommerce vendor and we want to track product clicks: User A clicks
on Product B. This is a naive way to show interest in a product or
category; we want to store this data for long-term data mining purposes.

```ruby
# example method that is called each time the user clicks a product
def click(uid)
  product_id = rand(1_000_000)
  # create a background job for each click
  ClickWorker.perform_async(uid, product_id)
  puts "User #{uid} clicked #{product_id}"
end

# a few sample clicks
click(15)
click(12)
click(12)
```

But we see enough traffic that we don't want to turn every single click
into a background job. We want to aggregate the clicks and process them
regularly. There's several ways to do this; I'm going to show you how
to implement it using a cron job running every minute.

```ruby
def click(uid)
  product_id = rand(1_000_000)
  # put a JSON payload of click data into a custom Redis list to be processed later
  Sidekiq.redis do |conn|
    conn.lpush("product-click-staging", JSON.generate({ "uid": uid, "pid": product_id }))
  end
  puts "User #{uid} clicked #{product_id}"
end
```

Now we need to create a cron job which will process this list in Redis
every minute.

```ruby
class AggregateClickJob
  include Sidekiq::Worker

  DAY = 24 * 60 * 60

  def perform
    mylist = "product-click-#{jid}"

    (_, _, elements) = Sidekiq.redis do |conn|
      conn.pipelined do

        # create our own set of clicks to process by renaming
        # the list to something private to us: our JID.
        # Remember: we need to consider job retries so this
        # must be idempotent, renamenx to the rescue!
        conn.renamenx("product-click-staging", mylist)

        # all data in redis should have an expiry to ensure no memory leaks
        conn.expire(mylist, 7*DAY)

        # now get the list of clicks to process
        conn.lrange(mylist, 0, -1)
      end
    end

    # we now have our own private list to process.
    # TODO process the hashes in "elements"

    elements.each do |str|
      hash = JSON.parse(str)
      p hash
    end


    # Now that we are done with the data, delete it.
    # Otherwise it will expire after 7 days.
    Sidekiq.redis do |conn|
      conn.del(mylist)
    end

  rescue Redis::CommandError => ex
    # if no clicks were registered in the last minute, the staging
    # list won't exist so there's nothing to do.
    return logger.info("Nothing to do") if ex.message =~ /no such key/i
    raise
  end
end
```

Note that each click event goes to a public "staging" list.
When each AggregateClickJob runs for the first time, it uses a little trick: it renames
the public "staging" list to a private key name based on its JID (the "mylist" variable).
Once renamed, the previous contents of the staging list are private to this job;
further clicks will go into a new staging list to be processed in the next minute.

Now that we have our own list of clicks to process, we can process them all
at once which can be **much** faster than one at a time. Every
database supports bulk insert: it can be 10-100x faster to insert records
in bulk! Rails 6.0 added official bulk loading support via `insert_all` but you can
always fall back to raw SQL and database-specific tools.

We need to configure our aggregate processing job to run every minute.
This is how you do it with Sidekiq Enterprise.

```ruby
Sidekiq.configure_server do |config|
  config.periodic do |mgr|
    mgr.register("* * * * *", "AggregateClickJob")
  end
end
```

Exercises for the reader:

* Implement with an OSS cron package.
* Implement a solution which fires a job every N clicks, not every N
seconds (hint: what is LPUSH's return value?)

That's all, folks. I can understand how the code above can be a little
daunting if you are not a Redis expert but I strongly recommend learning
more about Redis. It's a really flexible tool and valuable in many cases.
Like databases and SQL, Redis is rapidly becoming one of those
omnipresent tools that solve a huge number of engineering problems.

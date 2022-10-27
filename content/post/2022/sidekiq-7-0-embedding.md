---
title: "Sidekiq 7.0: Embedding"
date: 2022-10-27T09:21:22-07:00
publishdate: 2022-10-27
lastmod: 2022-10-27
tags: []
---

Sidekiq 7.0 can be embedded within another process so you do not need to run a separate Sidekiq process. This is called **embedding**.

## Why?

Why would you want to do this?
Embedding can make for a simpler deployment: you deploy one larger process instead of two separate processes, now you only need to monitor and manage one process.
Embedding also requires less total memory since both subsystems will share most of the Ruby data structures and code in memory.
Embedding does have a serious limitation: Ruby's Global VM Lock limits the process to one core which pretty drastically limits how many threads you can run in a process.

## Definition

The process owning library (e.g. puma or passenger) will typically have some sort of lifecycle callbacks which you can use to create, start and stop the Sidekiq instance.
Here's how you can do this with `puma` but the principle is the same for `passenger` or any other process.

```ruby
# config/puma.rb 
workers 2
threads 1, 3

require "sidekiq"
# preloading the application is necessary to ensure
# the configuration in your initializer runs before
# the boot callback below.
preload_app!

x = nil
on_worker_boot do
  x = Sidekiq.configure_embed do |config|
    # config.logger.level = Logger::DEBUG
    config.queues = %w[critical default low]
    config.concurrency = 2
  end
  x.run
end

on_worker_shutdown do
  x&.stop
end
```

I strongly recommend keeping your concurrency very low, i.e. 1-2.
Embedding Sidekiq within an Ruby process means that it shares one CPU with all other threads within the process.
A good rule of thumb is that your puma threads + sidekiq concurrency should never be greater than 5.
You'll create a puma process for every core so if your machine has 8 cores, you'll have 8\*3 = 24 Puma threads and 8\*2 = 16 Sidekiq threads.
As with any rule of thumb, YMMV.

## Notes

* The process owner (i.e. puma or passenger) owns any signal traps; the embedded Sidekiq instance does not directly respond to Ctrl-C, TERM or any other signal.
* The embedded instance does not look at `config/sidekiq.yml` or command line arguments.
  You can only configure it via Ruby.
* `Sidekiq.server?` will return `false` because this is not a Sidekiq process but it will run `configure_server` blocks so every instance is set up automatically for any local gems.
* Graceful restarts (a Sidekiq Enterprise feature) are not supported because we do not have full control of the process.

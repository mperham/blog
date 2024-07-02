---
title: "Iteration and Sidekiq 7.3.0"
date: 2024-07-03T09:00:00-07:00
publishdate: 2024-07-03
lastmod: 2024-07-03
tags: []
---

Sidekiq is the most popular background job framework for Ruby and works really well if you follow the design guidelines: keep your jobs short and idempotent.
What happens if you have a job which processes a large amount of data serially, the infamous long-running job?
In that case, deployments can lead to the job failing mid-way because the job will not gracefully allow the Sidekiq process to restart.
To fix this, Sidekiq 7.3 just shipped with a major new feature: [**Iterable Jobs**](https://github.com/sidekiq/sidekiq/wiki/Iteration).

The MVP for Sidekiq 7.3 is [Dima Fatko](https://github.com/fatkodima), who's worked on several Sidekiq improvements in the last six months, including the majority of the Iteration work.
Thank you Dima!

## Iteration

A common cause of long-running jobs is processing a large amount of data in a loop.
For example, below we iterate through each each Product in our database.
If there are one million Products, this might take a while!

```ruby
class ProductImageChecker
  include Sidekiq::Job

  def perform(*args)
    Product.all.each do |store|
      # do something with product
      product.check_image
    end
  end
end
```

Note the major flaw in the code above: if an error occurs or a deploy is triggered, the job will restart Product processing from the very beginning.

With `Sidekiq::IterableJob`, we break the loop into discrete chunks which Sidekiq knows about, allowing Sidekiq to break the processing at any point in the loop.
Notice we don't provide a `perform` method but rather two methods which control the work loop:

```ruby
class ProductImageChecker
  include Sidekiq::IterableJob

  def build_enumerator(*args, cursor:)
    active_record_records_enumerator(Product.all, cursor: cursor)
  end

  def each_iteration(item, *args)
    item.check_image
  end

  def on_complete
    logger.info { "Finished checking product images!" }
  end
end
```

Internally this looks something like:

```ruby
def perform(*args)
  e = build_enumerator(*args)
  e.each do |item, cursor|
    save_cursor(cursor) if stopping? || five_seconds_passed?
    raise Sidekiq::Job::Interrupted if stopping?
    each_iteration(item, *args)
  end
end
```

The magic is in that cursor; it tracks where we are within the sequence.
Sidekiq will persist the cursor automatically, either upon `stopping?` or every five seconds.
If the job needs to stop halfway through, it will resume right where it left off.
If the Sidekiq process crashes, your loop will resume within five seconds of where it crashed.

## Enumerators

There are helper methods for creating enumerators for ActiveRecord, CSV and arrays, all of which are cursor-aware.
See [`lib/sidekiq/job/iterable/enumerators.rb`](https://github.com/sidekiq/sidekiq/blob/main/lib/sidekiq/job/iterable/enumerators.rb).
These helper methods are available to all `Sidekiq::IterableJob` instances.

## Callbacks

Iterable jobs support four callback methods which you can override:

- `on_start` - the first time this job is started
- `on_resume` - any future time this job is started after interruption
- `on_stop` - when we are done processing for now, can be due to completion or interruption
- `on_complete` - when your Enumerator has finished

Callbacks take no arguments.
You can save the job arguments in `build_enumerator` if you want access to them in the callbacks.

## Iteration vs Batches

How does Iteration compare with Sidekiq Pro's Batches?
Batching allows you to decompose some work into a set of smaller jobs which can execute in parallel.
Iteration allows you to decompose some work into a sequence of steps, but which still execute serially as a single job.
You can override the `on_complete` callback to run a task after the sequence has been processed but you won't see the benefit of parallel execution.

## History

Job iteration first appeared from Shopify, with their [`shopify/job-iteration`](https://github.com/shopify/job-iteration) gem.
Dima Fatko built a version of that API for native Sidekiq jobs with his [`fatkodima/sidekiq-iteration`](https://github.com/fatkodima/sidekiq-iteration) gem.
I approached him about the feature and he kindly agreed to promote the code to Sidekiq core.

## Web Security

The one other change I want to highlight is a move to increase the security of the Web UI.
Version 7.2.0 had a XSS CVE slip into the release so I decided to improve our security by disabling all &lt;script&gt; tags within the Web UI html.
Starting in v7.3.0 you can use static JS files, but not raw JS code:

```html
<script> ... </script>       // bad, wont work
<script src="my-extension/file.js"></script> // good, will work
```

Instead I've added a new API to register web extensions, along with a `script_tag` helper method which can reference your static .js files.
See [`examples/webui-ext`](https://github.com/sidekiq/sidekiq/tree/main/examples/webui-ext) for all of the details.
I'm hopeful that, with this change, Sidekiq's Web UI will be immune to future XSS attacks.

## Anything Else?

* Sidekiq Enterprise can now use Redis Cluster for its rate limiters, allowing rate limiters to scale horizontally. Sidekiq's core functionality still cannot use Redis Cluster.
* Sidekiq's default job logging (the "start" and "done" lines) can now be disabled.
* The default Redis timeout has been raised from 1 second to 3 seconds, as this was generating ReadTimeoutErrors for some heavily loaded Sidekiq processes.

Please see the [changelog](https://github.com/sidekiq/sidekiq/blob/main/Changes.md) for issue numbers and further discussion.
Thanks for reading and I hope Sidekiq 7.3 works well for you. 
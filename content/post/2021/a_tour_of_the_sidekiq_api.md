---
title: "A Tour of the Sidekiq API"
date: 2021-04-20T09:00:00-07:00
---

Sidekiq provides an underappreciated but powerful tool for all users:
the Sidekiq API. The API gives comprehensive and idiomatic access to Sidekiq's
underlying real-time job and queue data within Redis.

## The Glossary

To explore the API, first it helps to understand the basic entities in
Sidekiq's universe:

* A `job` is a unit of work in your Ruby application
* A `queue` is a list of jobs which are ready to execute **right now**
* A `process` is a Sidekiq process with one or more threads for
executing jobs.

**NB**: I never use the term `worker` as it is nebulous
and confusing. Use `process`, `thread` or `job class` so your meaning is
clear.

## Usage and Warning

Sidekiq uses the API to implement its Web UI. Every action which you can
perform in the Web UI can also be done directly with the API. But
remember: **the Web UI is designed to be used by humans to perform manual
operations slowly.** The API exposes some operations which are not
scalable and will put a heavy load on Redis. If you are using those
operations in your app, you can cause serious harm to your application
at scale.

For example: lets say you want to build a unique jobs feature.
This prevents enqueuing a new job when an identical copy of that job is already enqueued.
Your first thought is to use the Sidekiq API to iterate through each job in the queue and check if it matches the new job.
This might work fine in development when the queue has 10-20 jobs in it but it will utterly fail in the case
where your production queue has 10,000+ jobs in it.
**Achtung!** **Cuidado!** **Warning!**
Take care when using these APIs in production.

To use the API, you need to require it:

```ruby
require 'sidekiq/api'
```

It's impossible for this blog post to fully document every last method
in the API, this post covers about 10% of what's there. Please dig into
[`sidekiq/api`](https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/api.rb)
if you want to see the full majesty 👑 of the Sidekiq API.

## Jobs

Sidekiq stores each job as a Hash of JSON data:

```ruby
$ bin/rails console

> SecretWorker.perform_async("foo", 123)
=> "1704fc9272746d0cba87c2f6"

> job = Sidekiq::Queue.new.first
=> #<Sidekiq::Job:0x00007fb30d0c8060 ...>

> job.value
=> "{\"class\":\"SecretWorker\",\"args\":[\"foo\",\"BAhTOhFTaWRla2lxOjpFbmMKOgZjSSIQYWVzLTI1Ni1nY20GOgZFVDoIdGFnIhWZI9cHOalTr475-9lIS0dyOgdpdiIRxcn72zsyzUnxDwh8OgZ2aQY6CWJsb2IiCnCz22JV\"],\"retry\":true,\"queue\":\"default\",\"encrypt\":true,\"jid\":\"1704fc9272746d0cba87c2f6\",\"created_at\":1618777117.251842,\"enqueued_at\":1618777117.253449}"

> pp JSON.parse(job.value)
{"class"=>"SecretWorker",
 "args"=>
  ["foo",
   "BAhTOhFTaWRla2lxOjpFbmMKOgZjSSIQYWVzLTI1Ni1nY20GOgZFVDoIdGFnIhVCXh1SNPysah7H0QcQNjKaOgdpdiIRd-Llb2KCN3xRuqaROgZ2aQY6CWJsb2IiCjPNio3T"],
 "retry"=>true,
 "queue"=>"default",
 "encrypt"=>true,
 "jid"=>"b3701748f571ccf97560e617",
 "created_at"=>1618777253.048657,
 "enqueued_at"=>1618777253.048795}
```

Note a couple of things:

* the job was pushed to the `default` queue. When we call
`Sidekiq::Queue.new`, that points to the `default` queue because, well,
because it's the default queue! `Sidekiq::Queue.new("critical")` opens
the `critical` queue.
* We can call `first` because a Sidekiq::Queue is `Enumerable`. You can page
through a queue like any old Ruby Array; `first` will return the first
Sidekiq::Job, `each` will yield each Sidekiq::Job, etc.
* We are manually parsing the String of JSON to get a Ruby Hash which is the actual
job but Sidekiq::Job will do this for you. Note the standard elements: `jid`, `created_at`, `queue`, `class`,
`args`, `retry`.
* `SecretWorker` is a job which uses Sidekiq Enterprise's encrypted job
feature so the `123` argument was encrypted and is an opaque set of
bytes in Redis.

## Queues

`Sidekiq::Queue.all` will get you a list of all known queues within Redis.
With queues, you can get their current size, latency, clear the queue and find a job by JID.
This last operation is a good example of a dangerous operation that I warned about before.
Redis doesn't have any efficient way to index data within a queue so a search is like a full table scan in your database.

The implementation is tiny but will not scale well.
We leverage the Enumerable module's `detect` method to scan through each element in
the Queue, parse each JSON and check the JID attribute.

```ruby
class Sidekiq::Queue
  ##
  # Find the job with the given JID within this queue.
  #
  # This is a slow, inefficient operation.  Do not use under
  # normal conditions.
  def find_job(jid)
    detect { |j| j.jid == jid }
  end
end
```

Note that this data is real-time.
Maybe you have thousands of jobs in the queue.
Maybe you have hundreds of Sidekiq threads pulling jobs from this queue at the same moment.
Will it find your job?  `¯\_(ツ)_/¯`

But Mike, why provide these operations at all if they are dangerous?
Because sometimes, hopefully rarely, you might need to handle some production emergency manually; finding that one rogue job could be critical.

## Sorted Sets

Sidekiq uses the Sorted Set structure to hold jobs sorted by a timestamp when Sidekiq should take some action.
These sets represent the Retries, Scheduled and Dead tabs in the Web UI.
For Scheduled, the timestamp is when the job is scheduled to run.
For Retry, the timestamp is when the job will retry next.
For Dead, the timestamp is when the job expires permanently.
Every N seconds, Sidekiq checks the timestamp of the first element. If
it is less than now, Sidekiq takes action. Rinse. Repeat.

Each sorted set has a cooresponding class in the API, here's a random
sampling:

```ruby
Sidekiq::RetrySet.new.size
Sidekiq::DeadSet.new.clear
Sidekiq::ScheduledSet.new.each {|job| job.add_to_queue }
Sidekiq::RetrySet.new.each {|job| job.kill }
Sidekiq::RetrySet.new.kill_all
```

Basically any button or action you see in the Web UI has a corresponding
API method.

## Scanning and Filtering

Sorted sets have the ability to quickly perform a server-side scan of
the contents as a filter:

```ruby
Sidekiq::RetrySet.new.scan "some_value" do |job|
  # job payload contains some_value
end
```

Remember how I was saying that some API calls are really, really slow?
That's true if you are iterating for each element in the Set.
This is a good example of how to speed up your API logic: use
`scan` as a server-side filter to ensure the only jobs you work on are
likely to be relevant:

```ruby
def delete_retries_by_class(klass)
  Sidekiq::RetrySet.new.scan klass.to_s do |job|
    # we still need this `if` because the job payload may contain the
    # class name for other reasons, remember that `scan` is a
    # regexp on the job's JSON string in Redis
    job.delete if job.display_class == klass.to_s
  end
end
```

The `display_class` for a Job is the actual class name. ActiveJobs all
use the same `SidekiqAdapter` class as the job type unfortunately so we
have to use this as a workaround to work with both ActiveJobs and native
Sidekiq::Workers.

## Optimization

A [blog post](https://blog.arkency.com/how-to-delete-jobs-from-sidekiq-retries/) was recently published with a few one-liners and I wrote
this blog post in response. The author has the right idea but is
generally missing the `scan` call to filter and minimize the number
of jobs processed in Ruby.

```ruby
# their suggestions
rs = Sidekiq::RetrySet.new
rs.select { |j| j.display_class == "AJob" }.map(&:delete)
rs.select { |j| j.display_class == "AJob" }.count

# my optimizations
rs.scan("AJob").select { |j| j.display_class == "AJob" }.map(&:delete)
rs.scan("AJob").count { |j| j.display_class == "AJob" }
```

If there are 10,000 elements in the Retry set but only 100 AJobs, my
version will run ~100x faster than their initial suggestion.

## Processes

Each Sidekiq process sends a heartbeat to Redis every 5 seconds with
runtime info about the jobs it is working on and various other
metrics.
The Busy page lists those processes and jobs.
`Sidekiq::ProcessSet.new` gives you the current set of processes.

```ruby
> ps = Sidekiq::ProcessSet.new
> ps.total_concurrency
=> 75
> ps.total_rss_in_kb
=> 750000
> ps.each {|pro| pro.labels }
> ps.each {|pro| pro.dump_threads }
> ps.each {|pro| pro.quiet! }
> ps.each {|pro| pro.stop! }
```

The API makes it really easy to remotely control your Sidekiq processes,
you can quiet or shut them down in one line of Ruby, good for deployment
tasks.

## Work

The Busy page also lists all of the work happening in your Sidekiq
cluster. The `Sidekiq::WorkSet` will yield the process and thread ids
for every job in progress.

```ruby
Sidekiq::WorkSet.new.each {|process_id, thread_id, work| ... }
```

## Commercial Features

Remember: if you see it in the Web UI, there is an underlying API for it in Ruby.
That's true even of the commercial features:

Batches provide `Sidekiq::BatchSet` which allows access to every open batch.
```ruby
Sidekiq::BatchSet.new.any? {|status| status.complete? }
```

Periodic jobs provide `Sidekiq::Periodic::LoopSet` which allows access to every
registered periodic job, a.k.a. a Loop.
```ruby
Sidekiq::Periodic::LoopSet.new.map {|loupe| [loupe.schedule,
loupe.history] }
```

Rate limiters provide `Sidekiq::LimiterSet` which gives a status object for each limiter.
```ruby
Sidekiq::LimiterSet.new.map {|limiter| [limiter.name, limiter.type] }
```

There's lots of APIs here which can power arcane features or specialized devops logic.
I strongly urge readers to skim through the
[`sidekiq/api`](https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/api.rb) file and consider the possibilities.
*The only limit... is your imagination!* 🌈✨

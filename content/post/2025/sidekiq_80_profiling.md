---
title: "Sidekiq 8.0: Profiling"
date: 2025-04-08T11:30:52-07:00
publishdate: 2025-04-08
lastmod: 2025-04-08
tags: []
---

Sidekiq is the most popular background job framework for Ruby applications and over the last 13 years, it has reached maturity in its feature set.
It has filled out much of its original design so adding a major new feature is a comparatively rare event these days.

For years I've wanted Ruby to support thread-safe profiling.
Historically Ruby's profiling APIs were process-global.
Data is collected for everything running in the process, making job profiling within a running Sidekiq process noisy and harder to read than ideal.

But Ruby 3.2 changed the game!
Thread profiling APIs took a big leap forward where we can target a specific thread and focus on its data and now that Sidekiq 8.0 requires Ruby 3.2, all the stars are aligned for a **major new feature**!
In fact Vernier's overhead is low enough that we can profile in production without a significant impact on job throughput.

## Why Profiling?

Profiling allows you to see exact runtime performance numbers for your code, showing you exactly where your code is spending its time.
One quick profile can show one or more major performance problems in your code.
Want to be a 10x developer?
Profiling is one of those tools you need to learn.

## Profiling at Runtime

Activating profiling takes two steps:

1. Include `vernier` in your Gemfile:
```ruby
gem "vernier"
```
2. Create a job in production (not development!) with a `profile` token:
```ruby
> SomeJob.set(profile: "bob").perform_async(...)
```

> Unfortunately profiling doesn't work with Active Job because AJ doesn't allow arbitrary key/values in the job payload; it ignores the `profile` element whereas Sidekiq::Job retains unknown key/values. I hope Active Job will support custom elements for triggering middleware and other aspects like profiling and logging in the future.

Profiling is activated right before the Rails Executor is activated (`@reloader` below).
This ensures that any Rails callbacks and server middleware are included in the profiling data as they can contain performance hotspots.

```ruby
# lib/sidekiq/processor.rb
@job_logger.prepare(job_hash) do
  @retrier.global(jobstr, queue) do
    @job_logger.call(job_hash, queue) do
      stats(jobstr, queue) do
        profile(job_hash) do # <=========== Call into profiler
          @reloader.call do
            klass = Object.const_get(job_hash["class"])
```

The integration code is right here: [lib/sidekiq/profiler.rb](https://github.com/sidekiq/sidekiq/blob/main/lib/sidekiq/profiler.rb).
When the job executes, Sidekiq looks for a `profile` token in the job.
If found, it does three things:

1. Set up the runtime data for this profile run.
2. Activate Vernier and yields execution to `Vernier.profile` to run your job code with the profiling APIs active.
3. Push the generated profiler output and runtime data to Redis so the user can access the data within the Web UI.

The result is that Redis now has a Hash object with the name `$token-$jid` which stores the profile data for that job.

## Viewing the Profile

Once you've got a job profiled, you'll want to view the data to find performance problems or hotspots.
The Web UI's Profiles tab contains your profiling data.
Profiling data expires after one day, this is aggressive because profiling is usually very easy to re-run (just create a new job) and can change with every deployment so we don't want to hang on to obsolete data.
NB: you can download and store the profile data elsewhere if you need more long term storage for before/after comparisons (it's a gzipped blob of JSON).

If there is no data in your Profiles tab, double check that you are creating the job in the same environment and that you aren't using Active Job.

Viewing your profile is as simple as clicking "View" which will open your data in Firefox Profiler, a single page JavaScript app.
First thing I always do is check "Invert call stack"; that's how you immediately drill into the places which took the most wall time when executing.
From that point you'll expand the call tree to find where your code is calling those hotspots; there's a good chance you'll immediately have ideas on how to minimize those hotspots and speed up your code.

[Here's a sample profile of a Rails request](https://vernier.prof/from-url/https%3A%2F%2Fraw.githubusercontent.com%2Fjhawthorn%2Fvernier-examples%2Fmain%2Fsimple_rails_request.json/calltree/?globalTrackOrder=0&invertCallstack&thread=0&timelineType=category&v=10).
It looks pretty optimized, I don't see any immediate hot spots to tune.
If you see one method taking 50% of the time, you've found something to optimize, maybe your database query needs an index or to eager load an association to fix an N+1 bug.
Those are pervasive issues with Active Record.

## Caveats

Ruby's newer profiling APIs are thread-friendly but they are still process-global.
You can't profile two different jobs at the same time.
For this reason, don't **ever** add `sidekiq_options profile: <token>` so every single job of a particular type is profiled.
The job will crash with an error.

## Results

Profiling is one of those skills that requires a mental model which is hard to teach in a blog post.
Try out the profiling functionality, play with the Firefox Profiler UI and you'll start to understand the data and what's happening.
Open an issue if you have a problem or if we can improve something.
Good luck and happy profiling!
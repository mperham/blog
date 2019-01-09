+++
date = "2017-09-29T09:00:00-07:00"
title = "Retries and Exceptions"
+++

Do you hate getting your inbox filled with errors you know you can
ignore?  Here's one cool trick to make them disappear.

If you are writing a background job, it is best practice to have that
job retry in the case of unexpected errors.  Networks can be flaky,
code can be buggy, data can be sketchy -- as they say, "stuff happens".

Sidekiq's default policy for jobs and retries is simple:

* if a job returns normally, it is considered a success.
* if a job raises an error, the error is reported and a retry is
  scheduled.

Many people have asked me: "I have a flaky service, how can I retry the
job **without** reporting the error to my error service and filling my
inbox".  Sometimes the
asker will want to disable retries or their error service: no way!
Retries and error reporting are there to handle **unexpected** problems that you need to
know about.  They should be
enabled by default and disabled only if your job is truly optional.

Instead, your job should flag errors that can be ignored; we'll configure our
error service to ignore them.  First we add a flag to the root of all
errors:

```ruby
# config/initializers/exceptions.rb
class Exception
  attr_accessor :ignore_please
end
```

Now we update our job to rescue and flag those flaky errors:

```ruby
# your job/worker class
def perform
  begin
    sketchy_service.call
  rescue FlakyError => ex
    # flag it to be ignored
    ex.ignore_please = true
    # re-raise it so Sidekiq will retry
    raise ex
  end
end
```

Now configure your error service gem to ignore those errors.  Here's how
to do it for Bugsnag and Honeybadger:

```ruby
# https://docs.bugsnag.com/platforms/ruby/rails/configuration-options/#ignore_classes
# config/initializers/bugsnag.rb
Bugsnag.configure do |config|
  config.ignore_classes << lambda {|ex| ex.ignore_please }
end

# http://docs.honeybadger.io/ruby/getting-started/ignoring-errors.html#ignore-programmatically
# config/initializers/honeybadger.rb
Honeybadger.exception_filter do |notice|
  notice[:exception].ignore_please
end
```

Done!  Now your inbox should be a little cleaner.

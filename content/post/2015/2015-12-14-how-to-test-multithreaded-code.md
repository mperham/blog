---
author: Mike Perham
date: 2015-12-14T00:00:00Z
title: How to Test Multithreaded Code
url: /2015/12/14/how-to-test-multithreaded-code/
---

<figure style="float: right;">
  <img style="border: solid white 10px;" src="http://yourhigherlevellife.com/wp-content/uploads/2013/02/TangledMess.png" width="260px" />
</figure>

Multithreaded code is hard to write and even harder to test.
Since much of my work is dedicated to making Ruby
threading easier for my users and customers, I thought some might be
interested in the patterns I've developed to make multithreaded code as simple
and testable as possible.

## Separate Threading from Work

> If you can't test a big block of code, break it into a set of smaller testable pieces.

[Sidekiq::Processor][0] is an object which is designed to run in its own
thread and doesn't have any public API aside from starting/stopping the
thread.

```ruby
p = Sidekiq::Processor.new
p.start
```

Interally it has quite a bit of complexity - think of it like an iceberg.
In order to test those complex internals, I make its [internal API public][1] so that the test suite has full
access to the methods.  The `start` method spins up a thread which calls a very simple `run` loop similar this:

```ruby
def run
  while !@done
    job = fetch
    process(job) if job
  end
end
```

I've kept the run method as simple as possible since we can't call it in
the test suite but we can call `fetch` and `process` in order to test them:

```ruby
def test_process_fake_job
  p = Sidekiq::Processor.new
  result = p.process(some_fake_job)
  # asserts...
end
```

In this case, I've kept the thread management code as simple as
possible and pushed as much of the code complexity into separate methods
which can be called directly by the test suite and deterministically
verified.

How do I test the thread management code?  Simple: in some cases I don't.  100% test
coverage is for fundamentalists.  Keep the code simple, verify it
manually and then don't change it.  Code complexity leads to churn which
leads to bugs.  Since most of the complexity in Sidekiq::Processor is in the `process` and
`fetch` methods, they are most likely to change so we test those methods directly.

## Use Callbacks

If you must test multithreaded code, you'll want to design testability
into the API.  Ever seen or written a test littered with `sleep` calls?
We've all been there but you can test threaded code without sleep calls, I swear!
Generally the pattern is:

1. Start the other thread
2. Tell the other thread to process something
3. Wait for the result
4. Assert results

Most people don't know how to do (3) properly so they use `sleep` as a
hack.  Here's a complete example of how to do it in Ruby:

```ruby
require 'thread'

# We want to test Upcaser by exercising its full API,
# including the internal threading.
class Upcaser
  Request = Struct.new(:args, :block)

  def initialize
    @queue = Queue.new
  end

  def start
    @thread = Thread.new(&method(:run))
  end

  def process(*args, &block)
    @queue << Request.new(args, block)
    true
  end

  def terminate
    @queue << nil
  end

  private

  def run
    loop do
      req = @queue.pop
      break unless req
      # perform the actual work
      result = req.args[0].upcase
      # call the block with the result
      req.block.call(result)
    end
  end
end

def test_upcaser
  m = Mutex.new
  cv = ConditionVariable.new

  a = Upcaser.new
  # Step 1
  # tell Upcaser to start its internal thread
  a.start

  results = nil

  # the main thread will lock the mutex so it can pass data
  # to Upcaser and then wait for the results
  m.synchronize do

    # Step 2
    # pass "something" to Upcaser for its internal thread to process
    # the internal thread must call the block with results when done
    a.process("something") do |res|
      results = res
      m.synchronize do
        cv.signal
      end
    end

    # Step 3
    # the main thread will wait here for Upcaser's thread to finish.
    cv.wait(m)
  end

  # Step 4
  # assert whatever you want about the results
  assert_equal "SOMETHING", results

  # shut down Upcaser's internal thread
  a.terminate
end
```

The "trick" is the callback block passed to the `process` method.  That callback
will save the results and unlock the main thread once Upcaser's thread is finished processing.  If your API
exposes a similar callback mechanism, it can be properly tested across threads.

I hope this helps people untangle some of their messy threading.  Got any other
patterns for making threading easier to manage?  Please link to them in
the comments.

[0]: https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/processor.rb#L24
[1]: https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/processor.rb#L62

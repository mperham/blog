---
title: "Advanced Data Structures in Ruby"
author: Mike Perham
layout: post
permalink: /2015/11/05/advanced-data-structures-in-ruby
published: true
---

Ruby provides several complex data structures out of the box; hash, array, set,
and queue are all I need 99% of the time.  However knowing about more
advanced data structures means you know when to reach for something more
esoteric.  Here's two examples I've used recently.

### ConnectionPool::TimedStack

My `connection_pool` gem implements a [thread-safe Stack][1] with a
time-limited `pop` operation.  This can be very useful when coordinating
time-sensitive operations between threads.  Recently I used it as an alternative
to `sleep` so I could wake up a sleeping thread immediately:

{% highlight ruby %}
def initialize
  @done = false
  @sleeper = ConnectionPool::TimedStack.new
end

def terminate
  @done = true
  @sleeper << nil
end

def start
  @thread ||= Thread.new do
    while !@done
      do_something
      # normally we'll sleep 60 seconds.
      # terminate will wake up the sleeper early so it can exit
      # immediately.
      begin
        @sleeper.pop(60)
      rescue Timeout::Error
      end
    end
  end
end
{% endhighlight %}

### The algorithms gem

Although somewhat misnamed, the [algorithms][0] gem contains a large
set of advanced data structures for use in Ruby code.  [Sidekiq
Enterprise][2]'s cron feature uses a [Heap](https://github.com/kanwei/algorithms/blob/master/lib/containers/heap.rb) to store jobs
in-memory, sorted based on their next occurrence; this makes checking
for the next job to run a constant time operation, no matter how many
jobs are defined.

I'd suggest reading over the [API documentation][3], this gem has a lot of
good structures that can turbocharge your Ruby code: trees, deques, and
many others.

### Time Complexity

When should you use a Heap?  A Queue?  A Stack?  A Tree?

Part of understanding advanced data structures is understanding the
complexity of their operations: how long will it take to add an
element, remove an element, change an element?  The time complexity of an operation can be
constant (O(1), great), logarithmic (O(log N), good), linear (O(N), meh), or worse,
where N is the number of elements in the data structure.
Read more about [Time complexity][4] on Wikipedia.

Knowing about more advanced data structures and time complexity will make you a better developer.
If you understand the operations that your code will perform frequently
and the expected data structure size, you can pick a structure which best
suits your own needs.

[0]: https://github.com/kanwei/algorithms
[1]: https://github.com/mperham/connection_pool/blob/master/lib/connection_pool/timed_stack.rb
[2]: http://sidekiq.org
[3]: https://kanwei.github.io/algorithms/
[4]: https://en.wikipedia.org/wiki/Time_complexity

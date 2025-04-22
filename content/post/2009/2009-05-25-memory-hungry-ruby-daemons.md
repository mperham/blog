---
author: Mike Perham
categories:
- Ruby
date: 2009-05-25T00:00:00Z
title: Memory-hungry Ruby daemons
url: /2009/05/25/memory-hungry-ruby-daemons/
---

We've had a perplexing issue with our Ruby daemons at [OneSpot][1]: they seem to grow to 300-400MB each within about 30 minutes, at which point our Monit scripts restart them. We suspected a memory leak and so upgraded from stock Ruby 1.8.5 shipped with CentOS to the latest REE 1.8.6 but nothing changed. I also saw a very similar issue at [FiveRuns][2]. Why is this problem seemingly endemic, even with completely different source code? After some thought and research I think I understand the root clause of the problem: it's part of Ruby's history and design.

## Memory Management in Ruby

Ruby uses 5 constants to control how it manages an application's heap, 3 of which are important to this discussion. From the [REE user's guide][3]:

> *   **RUBY\_HEAP\_MIN_SLOTS**  
>     This specifies the initial number of heap slots. The default is 10000. 
> *   **RUBY\_HEAP\_SLOTS_INCREMENT**  
>     The number of additional heap slots to allocate when Ruby needs to allocate new heap slots for the first time. The default is 10000.
>     For example, suppose that the default GC settings are in effect, and 10000 Ruby objects exist on the heap (= 10000 used heap slots). When the program creates another object, Ruby will allocate a new heap with 10000 heap slots in it. There are now 20000 heap slots in total, of which 10001 are used and 9999 are unused.
>     *   **RUBY\_HEAP\_SLOTS\_GROWTH\_FACTOR**  
>         Multiplicator used for calculating the number of new heaps slots to allocate next time Ruby needs new heap slots. The default is 1.8.

Take the program in the last example. Suppose that the program creates 10000 more objects. Upon creating the 10000th object, Ruby needs to allocate another heap. This heap will have 10000 * 1.8 = 18000 heap slots. There are now 20000 + 18000 = 38000 heap slots in total, of which 20001 are used and 17999 are unused.

The next time Ruby needs to allocate a new heap, that heap will have 18000 * 1.8 = 32400 heap slots.

So MRI will initially allocate the application RUBY\_HEAP\_MIN\_SLOTS or 10,000 slots. Let's assume for ease of math that this corresponds to 1MB of memory. Now Rails and our application code can't fit into anything less than 50MB so Ruby will need to allocate additional heaps for the necessary objects. It does this by using RUBY\_HEAP\_SLOTS\_INCREMENT and RUBY\_HEAP\_SLOTS\_GROWTH\_FACTOR each time. So we allocate 1.8MB, 3.24, 5.83, 10.5, 18.9, 34, 61, 110, 198, ... where the size of the newest heap is expanded by 1.8x each time. As you can see, just to get us to our 50MB minimum, we're now allocating 34MB for the latest heap. Once the app starts actually processing data, we'll allocate 61 and then 110 MB!

This is the core of the problem: loading Rails expands the Ruby process so much that additional memory allocation grows much larger than we actually need, due to the exponential growth factor. And since MRI never gives back unused memory, our daemon can easily be taking 300-400MB when it's only using 100-200.

It's important to note that this is essentially by design. Ruby's history is mostly as a command line tool for text processing and therefore it values quick startup and a small memory footprint. It was not designed for long-running daemon/server processes. Java makes a similar tradeoff in its client and server VMs.

Our solution was to move to [Ruby Enterprise Edition][4]. It allows those constants to be modified via environment variables, so that you can greatly increase MIN\_SLOTS and greatly reduce GROWTH\_FACTOR. Our settings:

> export RUBY_HEAP_MIN_SLOTS=800000
> export RUBY_HEAP_SLOTS_INCREMENT=100000
> export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1

That gives our daemon ~80MB to start and each heap is a fixed 10MB. Our daemon stabilizes at ~120MB and the memory usage doesn't change, even after hours of processing. My takeaway: if you own a Ruby daemon, you need to tune the heap to ensure it does not take too much memory!

[1]: http://www.onespot.com
[2]: http://www.fiveruns.com
[3]: http://www.rubyenterpriseedition.com/documentation.html#_garbage_collector_performance_tuning
[4]: http://www.rubyenterpriseedition.com

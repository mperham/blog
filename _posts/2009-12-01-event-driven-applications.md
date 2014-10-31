---
title: Event-Driven Applications
author: Mike Perham
layout: post
permalink: /2009/12/01/event-driven-applications/
categories:
  - Ruby
  - Software
---
Getting concurrency in Ruby is tough: Ruby 1.8 threads are green so they don&#8217;t execute concurrently. Ruby 1.9 threads are native but they don&#8217;t execute concurrently due to the GIL (global interpreter lock) necessary to ensure thread-safety with native extensions. Only JRuby provides a stable, concurrent Ruby VM today. On top of that, writing thread-safe code is tough &#8211; code execution is non-deterministic and so everyone gets it wrong, the code is hard to test and bugs painful to track down.

For these reasons, I would argue that IO-intensive applications need to either use an event-driven application model or a language designed for concurrency like [Clojure][1]. Since I like to work with Ruby, the former is the route to follow.

This overview is important to understand because the main deployment pattern with Rails apps is to instantiate 5-10 Rails processes, which can each handle one request at a time. If a request takes 5-10 seconds to process (maybe it is calling Amazon S3 or SimpleDB), that entire Rails process is stuck waiting for the data. Even a multi-threaded Rails application is limited due to the GIL. For this reason, people use a message queue to handle long-running tasks but often that just passes the buck: now the message queue processor is the one stuck for 5-10 seconds instead. You don&#8217;t have a user waiting for a response but you still are limited in how fast you can process the queue based on the amount of memory you have and the number of daemon processes you can start.

<img src="http://www.mikeperham.com/wp-content/uploads/2009/12/EventMachineLogo.png" alt="EventMachineLogo" title="EventMachineLogo" width="413" height="66" class="alignnone size-full wp-image-388" /><img src="http://www.mikeperham.com/wp-content/uploads/2009/12/neverblock.jpg" alt="neverblock" title="neverblock" width="218" height="67" class="alignnone size-full wp-image-389" />

This is where an event-driven model would help immensely. The fundamental tools at your disposal are [NeverBlock][2] and [EventMachine][3]. EventMachine provides the *reactor*, the fundamental &#8220;switch&#8221; in your application which decides what code is ready to run now, and NeverBlock provides various drop-in replacements for the common Ruby code used for network and IO: mysql and postgres database drivers, tcp sockets, etc. Using these, the message queue processor can process many messages at the same time: there&#8217;s never any concurrent execution but as one message performs some IO request, eventmachine and neverblock will seamlessly switch to handle another message while waiting for the IO response. That&#8217;s the fundamental difference with threaded code: instead of switching threads at a non-deterministic point in the future, event-driven code only switches when the code tries to perform IO. Your code does not need to be thread-safe because your code will not be interrupted while modifying variables and data structures in memory.

Sounds good, right? Well, a few caveats:

*   CPU-intensive processes won&#8217;t gain much. There&#8217;s still only a single actual thread of execution under the covers so event-driven applications will only take advantage of a single processor/core.
*   Your application should run on Ruby 1.9 to take advantage of Fibers. Fibers have been backported to Ruby 1.8 but I encourage you to try Ruby 1.9. Most extensions are Ruby 1.9 safe now and Rails is fully supported on Ruby 1.9. Without Fibers, your application code needs to change dramatically to work as success/error callbacks. With Fibers, your code needs little change and can be written in the more familiar procedural style.
*   Application exception handling becomes tricky, just as with threads. It&#8217;s easy to lose an exception.

Next time, we&#8217;ll take a deeper look into some event-driven code and how it works.

 [1]: http://github.com/richhickey/clojure
 [2]: http://github.com/espace/neverblock/
 [3]: http://github.com/eventmachine/eventmachine
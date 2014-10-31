---
title: Threads Fibers Events and Actors
author: Mike Perham
layout: post
permalink: /2011/05/19/threads-fibers-events-and-actors/
categories:
  - Ruby
---
I presented (from 3000 miles away!) today at [EMRubyConf][1]. My talk, &#8220;[Threads Fibers Events and Actors][2]&#8220;, is a short 13min chat on current trends in Ruby scalability and concurrency. To summarize:

Ruby&#8217;s threading has historically been terrible. So we turned to event-based systems like EventMachine but the reactor pattern brings its own set of drawbacks. So we turned to Fibers to solve some of those problems but they bring along another set of drawbacks. In the end though, all of this is a workaround for Ruby&#8217;s historically terrible threading implementation. But what if Ruby&#8217;s threading didn&#8217;t suck?

JRuby has great threads. Rubinius will soon have great threads. Both have really matured into excellent, stable runtimes over the last year. Make no mistake threads have issues too; locks and race conditions are notoriously hard to write well and Ruby code can&#8217;t be autoloaded safely in a multithreaded system. The former is what Actors attempt to solve: making concurrency simpler and safer by passing messages rather than sharing mutable state and requiring locks.

I think the Ruby community needs to give threads another chance: ensure their gems are thread-safe and use Actors when needing to write safe multithreaded code. [Celluloid][3] and the [Rubinius Actor API][4] are two APIs which provide Actors to Ruby. My new gem [girl_friday][5] leverages actors for safe concurrency. The autoloading problem is the only hard problem remaining; I hope some time and effort can determine ways around this issue.

 [1]: //emrubyconf.com
 [2]: http://vimeo.com/23933313
 [3]: https://github.com/tarcieri/celluloid
 [4]: http://rubini.us/doc/en/systems/concurrency/
 [5]: http://mperham.github.com/girl_friday
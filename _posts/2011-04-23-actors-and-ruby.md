---
title: Actors and Ruby
author: Mike Perham
layout: post
permalink: /2011/04/23/actors-and-ruby/
categories:
  - Ruby
---
I&#8217;ve spent the last month learning Rubinius&#8217;s Actor API for safer concurrency with threads. My entire career really has been focused on learning and building scalable and high performance infrastructure. My explorations with Fibers over the last year lead me to believe that they are essentially a workable hack to get around Ruby&#8217;s current issues but not really something that developers should use widely. Debugging is difficult and testing very difficult with any reactor-based system.

On the other hand, I do think Actors are a good step forward for concurrency by making Threads safer to utilize. By the end of this year, we&#8217;ll have several Ruby VMs (JRuby, MacRuby, Rubinius) that can execute threads in parallel, allowing a single Ruby process to peg a multi-core machine; Actors will be helpful in building applications that can take advantage of this.

I&#8217;ve written two posts on the [Carbon Five][1] blog, the first covering [Actors in general][2] and the second covering my new, simple but full-featured [asynchronous processing library, girl_friday][3], which leverages Actors. Take a look and let me know what you think!

 [1]: http://blog.carbonfive.com
 [2]: http://blog.carbonfive.com/2011/04/19/concurrency-with-actors/
 [3]: http://blog.carbonfive.com/2011/04/20/asynchronous-processing-with-girl_friday/
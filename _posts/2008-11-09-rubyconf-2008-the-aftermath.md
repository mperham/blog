---
title: 'RubyConf 2008: The Aftermath'
author: Mike Perham
layout: post
permalink: /2008/11/09/rubyconf-2008-the-aftermath/
categories:
  - Ruby
---
I got back to Austin last night after a great three days in Orlando at RubyConf. I thought my talk went well and the crowd had several interesting questions so I know someone was paying attention. :-)

Given that my interests lie in server-side performance and scalability, I saw two linked trends developing:

**Threads suck (on Ruby?)**

They work reasonably well in Java but you should avoid them if humanly possible in Ruby. They have two fundamental drawbacks: 1) the programming model makes safe concurrency difficult to code and test; and 2) the various Ruby VMs have enough differences in their threading models that you can&#8217;t get good, reliable concurrency even with well-written multi-threaded code. The current best practice is to move to an evented IO model, which allows a single process to handle many requests concurrently and will peg a single core on a modern processor. To peg all the cores, you should scale with multiple Ruby processes, a la the traditional pack of Mongrels with Rails.

**Real concurrency requires a new language**

Even if Ruby had Java&#8217;s excellent VM and threading model, it still is not suited to developing scalable apps on many-core machines because of its more traditional, mutable state nature. Traditionally pure functional languages excel at concurrency because of their nature: they don&#8217;t allow mutable state or &#8220;side effects&#8221; in the code. Guess what: these are the two things you need to synchronize when dealing with threads; programming in a good functional language means you don&#8217;t ever need to worry about synchronization.

A note: new languages should not build their own VM anymore. The Java VM is an incredible feat of engineering and recent languages have starting using it as their platform in order to get a good threading model, excellent garbage collection and a vast array of third-party libraries which can be accessed easily. Scala and Clojure, for example, are two functional languages which leverage the JVM. Clojure is my favorite of the two: it&#8217;s more pure, doesn&#8217;t have a compilation step (the compilation is done at runtime) and the syntax is much nicer.

My takeaway was that I need to learn a functional programming language. FP and compilers were the two weaknesses I had when I graduated Cornell and it looks like being able to switch modes of thought from iterative to functional will be important to top notch engineers in the future. I&#8217;m going look at Clojure and see what I can do with it.

The ideas in this post came from talks by several people: Jim Weirich, Ilya Grigorik and W. Idris Yasser. Kudos to them for excellent talks.
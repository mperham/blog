---
author: Mike Perham
categories:
- Personal
- Ruby
- Software
date: 2008-11-06T00:00:00Z
title: Introducing Politics
url: /2008/11/06/introducing-politics/
---

I'm going to be introducing my new [Politics][1] gem at RubyConf 2008 tomorrow. This gem provides a few modules which solve a couple of distributed computing problems we were having at [FiveRuns][2] in providing fault tolerant, scalable processing across many machines.

Here's my [RubyConf slides][3] (1MB, Keynote), minus the screencasts I created to demo the two worker modules in action.

There are two modules provided:

*   `TokenWorker` ensures that one process from a group of redundant processes will be elected to perform processing for the next N seconds.
*   `StaticQueueWorker` distributes a predefined set of work to a dynamic set of processes every N seconds.

Both depend on the standard Ruby library and `memcached`. `StaticQueueWorker` also depends on `net-mdns` for Bonjour functionality.

You can find the [code on github][1] with a more detailed overview and examples of how to use the modules in your own code. If you find the software useful, please consider recommending me at [Working On Rails][4].

 [1]: http://github.com/mperham/politics
 [2]: http://www.fiveruns.com
 [3]: /wp-content/uploads/2008/11/patternsindistributedcomputing.zip
 [4]: http://workingwithrails.com/person/10797-mike-perham

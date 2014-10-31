---
title: Background Processing vs Message Queueing
author: Mike Perham
layout: post
permalink: /2011/05/04/background-processing-vs-message-queueing/
categories:
  - Software
---
One common simplification I see engineers make is equating message queueing with background processing. This is what they are missing: **message queueing is a superset of background processing**. All message processing is done in the background but background processing does not have to be done via message queues.

Take a simple use case: &#8220;I want to send a welcome email when a user registers&#8221;. Commonly you want to send this email in the background so it does not impact the user&#8217;s experience. Do you need to install ActiveMQ, RabbitMQ or Resque to do this? Certainly not.

Message queueing is a fundamental architectural pattern when building complex systems. Your various system components might be written by different teams but they communicate through messages sent via queues. One component can send a message to another component, saying &#8220;please send this email&#8221;. But message queueing systems have their cost: they are complex because they are designed to be the foundation of your distributed system. They must be deployed and monitored like the rest of your infrastructure; they must be reliable and highly available.

I think that a lot of people install a message queue to perform simple background processing; it doesn&#8217;t need to be that complicated. The fundamental question to me is, &#8220;Am I communicating between different subsystems or just trying to spin off some work?&#8221; The registration email use case comes up almost immediately when building nearly every website. Consider also the case where you want to perform some action that might take 30-60 seconds and have the user&#8217;s browser poll for the result. Spinning off a separate thread to perform this work is entirely sufficient and much simpler. This is the reasoning behind my [girl_friday][1] project. I want a simple and reliable way to perform background processing without needing the complexity of an MQ system. Let&#8217;s examine a few characteristics of girl_friday:

*   In-process &#8211; your background processor is part of your Ruby application and has access to the exact same codebase as your webapp. No need to share ActiveRecord models across projects via git or filesystem trickery. No need to deploy or monitor a separate set of processes.
*   Threaded &#8211; huge memory savings because you don&#8217;t have to spin up other processes which load the exact same code. Threads are notoriously tricky to get correct so girl_friday uses Actors for the equivalent behavior in a simpler and safer API.

I have issues with the other contenders in the space:

*   delayed_job &#8211; stores jobs in your RDBMS and polls for jobs which is a terribly unscalable idea. Spins off processes instead of threads.
*   resque &#8211; forks a new process for every message. Safe but memory hungry.

The biggest caveat with girl_friday is threading, of course. Typical Ruby deployments aren&#8217;t thread-friendly but I&#8217;d like to help change that. Rainbows! is thread-friendly, as are all the JRuby app servers. The [girl_friday wiki][2] gives more specifics about features and usage. Are there any other dimensions to the problem that I&#8217;m missing? Any other projects that solve a similar problem? Post a comment and let me know!

 [1]: https://github.com/mperham/girl_friday
 [2]: http://github.com/mperham/girl_friday/wiki
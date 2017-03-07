---
author: Mike Perham
categories:
- Ruby
date: 2010-01-27T00:00:00Z
enclosure:
- "|\n    http://www.mikeperham.com/wp-content/uploads/2010/01/eventmachine.mp3\n
  \   49024105\n    audio/mpeg\n    \n"
- "|\n    http://dl.dropbox.com/u/3933641/Austin%20on%20Rails%20EventMachine%20Jan%202010%20%28small%29.m4v\n
  \   476422107\n    video/mp4\n    \n"
tags:
- eventmachine
- Ruby
title: Scalable Ruby Processing with EventMachine
url: /2010/01/27/scalable-ruby-processing-with-eventmachine/
---

I gave a talk at Austin On Rails last night on using EventMachine, focused on maximizing concurrency when processing a message queue. There were a lot of questions, mostly revolving around the flow of execution within EventMachine code. To this point, there were two common stumbling points people seemed to have:

*   Ruby developers are not used to treating blocks as true callbacks where they are executing at some point in the future. Blocks are usually yielded by the method they are passed to. Understanding when a block will be called is confusing.
*   Understanding how Fibers work and how they can make an asynchronous API appear to be synchronous to the outside world is tricky.

I hope everyone came away a little more knowledgeable about EventMachine and the types of problems it can solve. Here's the slides for others to peruse. The presentation was recorded and I will link to recordings when I find out about them.

[Scalable Ruby Processing with EventMachine][1] (Keynote 2009, 1.2 MB)  
[Scalable Ruby Processing with EventMachine][2] (Scribd)  
[Scalable Ruby Processing with EventMachine][3] (Audio MP3, 49MB)  
[Scalable Ruby Processing with EventMachine][4] (Vimeo)

 [1]: http://www.mikeperham.com/wp-content/uploads/2010/01/EventMachine.key
 [2]: http://www.scribd.com/doc/25939580/Event-Machine
 [3]: http://www.mikeperham.com/wp-content/uploads/2010/01/eventmachine.mp3
 [4]: http://vimeo.com/10849958

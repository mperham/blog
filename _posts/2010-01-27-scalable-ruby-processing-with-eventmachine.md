---
title: Scalable Ruby Processing with EventMachine
author: Mike Perham
layout: post
permalink: /2010/01/27/scalable-ruby-processing-with-eventmachine/
enclosure:
  - |
    |
        http://www.mikeperham.com/wp-content/uploads/2010/01/eventmachine.mp3
        49024105
        audio/mpeg
        
  - |
    |
        http://dl.dropbox.com/u/3933641/Austin%20on%20Rails%20EventMachine%20Jan%202010%20%28small%29.m4v
        476422107
        video/mp4
        
categories:
  - Ruby
tags:
  - eventmachine
  - Ruby
---
I gave a talk at Austin On Rails last night on using EventMachine, focused on maximizing concurrency when processing a message queue. There were a lot of questions, mostly revolving around the flow of execution within EventMachine code. To this point, there were two common stumbling points people seemed to have:

*   Ruby developers are not used to treating blocks as true callbacks where they are executing at some point in the future. Blocks are usually yielded by the method they are passed to. Understanding when a block will be called is confusing.
*   Understanding how Fibers work and how they can make an asynchronous API appear to be synchronous to the outside world is tricky.

I hope everyone came away a little more knowledgeable about EventMachine and the types of problems it can solve. Here&#8217;s the slides for others to peruse. The presentation was recorded and I will link to recordings when I find out about them.

[Scalable Ruby Processing with EventMachine][1] (Keynote 2009, 1.2 MB)  
[Scalable Ruby Processing with EventMachine][2] (Scribd)  
[Scalable Ruby Processing with EventMachine][3] (Audio MP3, 49MB)  
[Scalable Ruby Processing with EventMachine][4] (Vimeo)

 [1]: http://www.mikeperham.com/wp-content/uploads/2010/01/EventMachine.key
 [2]: http://www.scribd.com/doc/25939580/Event-Machine
 [3]: http://www.mikeperham.com/wp-content/uploads/2010/01/eventmachine.mp3
 [4]: http://vimeo.com/10849958
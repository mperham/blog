---
title: The Dangers of Shortcuts
author: Mike Perham
layout: post
permalink: /2011/03/01/the-dangers-of-shortcuts/
categories:
  - Software
---
[MongoDB][1] has amazing write performance. [Node.js][2] has great I/O concurrency. [Telehash][3] is an extremely efficient wire protocol. All three of these systems have a common theme: they take a shortcut in order to provide a leap in performance over existing systems.

*   In MongoDB&#8217;s case, they don&#8217;t provide true durability so writes can be batched into a large set of writes when actually persisting to disk. This gets them great performance but means they don&#8217;t provide true ACID transactions. Side note: the latest release has a new `--dur` flag which gives true durability with the resultant loss in write performance.
*   For Node.js, the trade-off is in programming style: everything is done asynchronously so you have to learn an entirely new style of programming. Great performance but great developer learning curve.
*   With Telehash, UDP is a more efficient network protocol than TCP by design. TCP is essentially UDP with reliable delivery baked on top, so it suffers from round trip latency and the state required to track the current network packets in flight in order to ensure delivery. You can use UDP but if a router drops a UDP packet, your application will never know.

When you are looking at a new system that promises better performance or scalability than existing systems, ask yourself &#8220;what shortcuts did they take to get that performance or scalability?&#8221; **Sometimes those shortcuts are worth it but it is completely dependent on your own situation.** If you are writing a small, high-traffic network service, Node.js makes sense. Writing a high volume of low-priority logging data with MongoDB makes sense. I would argue there are very few instances where UDP is a good idea, realtime data streaming is the best case I can think of, off hand. Part of being an engineer is learning when these shortcuts are unreasonable and what you are paying for that shortcut.

 [1]: http://mongodb.org/
 [2]: http://nodejs.org/
 [3]: http://www.telehash.org/
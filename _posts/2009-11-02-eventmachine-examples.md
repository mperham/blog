---
title: EventMachine Examples
author: Mike Perham
layout: post
permalink: /2009/11/02/eventmachine-examples/
categories:
  - Ruby
---
I needed to create a simple, but IO-intensive, thumbnailing service for OneSpot last week. This service acts as a proxy to S3 and so a blocking implementation would not scale well, even if threaded. I wanted to use EventMachine instead. Lessons learned:

*   The programming model is a mind twist and takes a long time to understand. The sprinkling of implementation at various layers makes it harder. I&#8217;ve spent several days now reading through EventMachine, Thin, Rack and em-http-request source code.
*   There&#8217;s **no** non-trivial examples out there. It seems like every example is 10 lines of &#8220;Hello World&#8221; code with no samples of how to integrate multiple pieces. Ok, here&#8217;s a 10 line async web server. Now how do I integrate an async call to the DB? How do I make an async 3rd party web service call?
*   There&#8217;s **no** testing support. No libraries for doing async testing and no best practices or suggestions on how to test.

So how can we make things better rather than just complain? I&#8217;m going to show you a non-trivial example. In return, I want you to send me more examples. [Evented][1] is my new Github repository for EventMachine examples. The first example is that big chunk of code that I puzzled over for the last few days which implements the thumbnailing service using Thin, S3, image_science and em-http-request. But I want more examples and I&#8217;d love to hear ideas on how to test this type of code. Leave a comment, send a pull request, and help me help you!

 [1]: http://github.com/mperham/evented
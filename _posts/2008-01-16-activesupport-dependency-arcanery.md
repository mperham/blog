---
title: ActiveSupport Dependency arcanery
author: Mike Perham
layout: post
permalink: /2008/01/16/activesupport-dependency-arcanery/
categories:
  - Rails
---
I was getting the following error when running some Ruby code and a Google search  did not clarify what the problem was.  **&#8216;to\_constant\_name': Anonymous modules have no name to be referenced by (ArgumentError)**

Essentially the problem was dependency load order.  The error was due to this line:

<pre>      ActiveRecord::Base.send(:include, AttributeMapper)</pre>

The problem was that I had not required ActiveRecord yet so ActiveSupport blew up with this arcane error.  So, if you start to see odd errors like above, stop and think about any require/load changes you might have recently made.  A quick &#8216;svn diff&#8217; showed me exactly what I had changed 5 minutes before to cause this problem.
---
author: Mike Perham
categories:
- Rails
date: 2008-01-16T00:00:00Z
title: ActiveSupport Dependency arcanery
url: /2008/01/16/activesupport-dependency-arcanery/
---

I was getting the following error when running some Ruby code and a Google search  did not clarify what the problem was.  **'to\_constant\_name': Anonymous modules have no name to be referenced by (ArgumentError)**

Essentially the problem was dependency load order.  The error was due to this line:

<pre>      ActiveRecord::Base.send(:include, AttributeMapper)</pre>

The problem was that I had not required ActiveRecord yet so ActiveSupport blew up with this arcane error.  So, if you start to see odd errors like above, stop and think about any require/load changes you might have recently made.  A quick 'svn diff' showed me exactly what I had changed 5 minutes before to cause this problem.

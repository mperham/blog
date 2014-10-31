---
title: Ruby, Threads and Exit Codes
author: Mike Perham
layout: post
permalink: /2008/05/06/ruby-threads-and-exit-codes/
categories:
  - Ruby
---
A question for you Ruby nerds: the **$?** variable gives access to the exit code for the last process launched by Ruby. Is referencing **$?** a race condition in a system with many threads launching many subprocesses? If it is truly a global variable, then it&#8217;s inherently unsafe, but it could also be implemented with a thread-local variable. Any idea which it is?

``</p>
<pre>
      output = `#{command}`
      if $? != 0 # Race condition?
        raise output
      end
</pre>
<p>``
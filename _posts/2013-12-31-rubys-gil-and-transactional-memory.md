---
title: 'Ruby&#039;s GIL and transactional memory'
author: Mike Perham
layout: post
permalink: /2013/12/31/rubys-gil-and-transactional-memory/
categories:
  - Ruby
---
I saw a link to a really interesting paper this morning: [Eliminating Global Interpreter Locks in Ruby through Hardware Transactional Memory][1]. This blew my mind when I read it as it&#8217;s a really interesting concept; let me explain.

<!--more-->

### What is Hardware Transactional Memory?

[Transactional Memory][2] ensures that a set of operations in memory happen in a consistent manner. If my code reads a variable, changes that variable and writes it back to memory, TM tries to ensure that these operations yield a predictable outcome. TM can be implemented in software (e.g. see Clojure&#8217;s STM support) or in hardware[^3].

### What is the GIL?

(or, How to stop concurrency problems by stopping concurrency)

Ruby[^1]&#8216;s GIL is a VM-wide mutex that a thread must obtain before that thread can execute Ruby code. This is necessary because C extensions and many parts of Ruby are not actually thread-safe (including Array and Hash!) By holding the GIL, we guarantee that our thread&#8217;s Ruby code is the only Ruby code executing; there can&#8217;t be any concurrency issues.[^2]

### What does TM have to do with the GIL?

The point of the GIL is to ensure that two threads don&#8217;t look at and modify memory at the same time. Two threads can look at the same memory but if one thread modifies the memory, the other thread needs to start its operation over. This is necessary for atomic, consistent transactions: the operation should have a consistent view of memory or else it needs to rollback.

The GIL is one way to get that atomic, consistent view but HTM is another way. When executed, Ruby code actually takes the form of lots of tiny operations: load a variable, branching, method invocation, yielding, etc. The researchers turned each one of those operations into a small transaction. If two threads execute operations that touch the same memory, the hardware will abort one of them so it can start the operation over.

The performance gains were modest: a simple Rails app app saw 1.3x performance improvement with 3 threads vs 1 thread. But the researchers found a number of hotspots which caused a lot of transaction aborts, including Ruby&#8217;s GC, the regexp library and various C global variables. Fixing these hotspots would be just one of many changes necessary to remove the GIL and make Ruby truly thread-safe but would also improve HTM scalability greatly.

That&#8217;s a **very** brief overview of the paper but I think it&#8217;s a fascinating idea and one worth pursuing further.

[^3]:    
    HTM is available via Intel&#8217;s TSX extensions, available on some recent Haswell processors. Hopefully this will become standard in future generations of x86 CPUs.

[^1]:    
    Ruby in this case means MRI. JRuby and Rubinius are thread-safe. <3

[^2]:    
    As with everything, it&#8217;s more complicated than that. Concurrency != parallelism and all that; please skip the comments arguing at me, trying to win Internet points.

 [1]: http://researcher.watson.ibm.com/researcher/files/jp-ODAIRA/PPoPP2014_RubyGILHTM.pdf
 [2]: https://en.wikipedia.org/wiki/Transactional_memory
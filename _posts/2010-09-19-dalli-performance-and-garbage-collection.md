---
title: Dalli Performance and Garbage Collection
author: Mike Perham
layout: post
permalink: /2010/09/19/dalli-performance-and-garbage-collection/
categories:
  - Ruby
---
I did an interesting experiment to compare memcache-client and [Dalli][1] performance this morning. I wanted to understand which library allocated more objects in order to know which library would have more GC overhead. Ruby 1.9 has a new module [GC::Profiler][2] which will generate a report with stats about each GC run. Since both gems have an identical benchmark suite, I ran the GC Profiler on the benchmark suite for each:

<table cellpadding="5" cellspacing="10">
  <tr>
    <th>
      &nbsp;
    </th>
    
    <th>
      Runs
    </th>
    
    <th>
      GC Time
    </th>
    
    <th>
      Total Time
    </th>
  </tr>
  
  <tr>
    <th>
      memcache-client
    </th>
    
    <td>
      596
    </td>
    
    <td>
      3.40
    </td>
    
    <td>
      18.35
    </td>
  </tr>
  
  <tr>
    <th>
      dalli
    </th>
    
    <td>
      153
    </td>
    
    <td>
      1.73
    </td>
    
    <td>
      15.29
    </td>
  </tr>
</table>

memcache-client runs the GC 4x as much as Dalli and roughly half of Dalli&#8217;s speed improvement over memcache-client is due to more efficient object allocation requiring less garbage collection. Note that Dalli&#8217;s GC runs seem to take twice as long as the memcache-client runs. Anyone know Ruby 1.9&#8217;s GC implementation and have an idea why this might be?

 [1]: http://github.com/mperham/dalli
 [2]: http://rdoc.info/docs/ruby-core/1.9.2/GC/Profiler
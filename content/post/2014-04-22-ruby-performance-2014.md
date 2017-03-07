---
author: Mike Perham
categories:
- Ruby
date: 2014-04-22T00:00:00Z
title: Ruby Performance 2014
url: /2014/04/22/ruby-performance-2014/
---

Last year I posted [a comparison of various Ruby VMs and how fast they could process N empty jobs][1]. This is the equivalent of pumping out "Hello World" responses in an app server: it's not very useful for application developers but it's far more useful than a microbenchmark in determining real Ruby VM performance. Let's take a look at the most popular three versions available today: MRI 2.1.1, MRI 2.0.0 and JRuby 1.7.11.

Time required to process 50,000 empty jobs with a single Sidekiq process running 25 threads.

<table>
  <tr>
    <th>
      Version
    </th>
    
    <th>
      Time
    </th>
    
    <th>
      With Logging
    </th>
  </tr>
  
  <tr>
    <td>
      2.1.1
    </td>
    
    <td>
      46 sec
    </td>
    
    <td>
      67 sec
    </td>
  </tr>
  
  <tr>
    <td>
      2.0.0
    </td>
    
    <td>
      50 sec
    </td>
    
    <td>
      70 sec
    </td>
  </tr>
  
  <tr>
    <td>
      1.7.11
    </td>
    
    <td>
      33 sec
    </td>
    
    <td>
      51 sec
    </td>
  </tr>
</table>

&nbsp;

Like last year, JRuby continues to dominate in raw runtime performance. 2.1.1 shows a small performance advantage over 2.0.

"With Logging" shows some interesting data: just logging the start and finish times of the jobs to the global logger proves to be a major performance hit. The reason is that Ruby's Logger contains an internal Mutex to ensure that data is logged to the stream atomically. This Mutex becomes a source of contention when 25 threads are processing those no-op jobs. Your first impression might be to optimize the Logger but this is a red herring! During normal execution the logger won't be as heavily contented because your jobs are actually doing work.

Details:

[The actual code is here][2].

Run on a late 2013 MBP retina with 2.8Ghz Core i7 with 2 cores running on battery. Defaults were used for everything.

java version "1.7.0_45"  
Java(TM) SE Runtime Environment (build 1.7.0_45-b18)  
Java HotSpot(TM) 64-Bit Server VM (build 24.45-b08, mixed mode)

 [1]: /2013/06/30/background-job-processing-overhead/
 [2]: https://gist.github.com/mperham/9880935

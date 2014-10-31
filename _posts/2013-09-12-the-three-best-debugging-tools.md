---
title: The Three Best Debugging Tools
author: Mike Perham
layout: post
permalink: /2013/09/12/the-three-best-debugging-tools/
categories:
  - Software
---
**1. Your Coworker**

It&#8217;s happened to me over and over: I&#8217;ll spend hours trying to track down a problem. In frustration, I&#8217;ll ask a coworker to look at the code and frequently they will point out the problem in seconds. It&#8217;s called situational blindness and it means that you will often overlook the bug right in front of your eyes because you&#8217;ve looked at it so much, your mind has started to ignore it.

Your coworker has another valuable trait: they are different than you. They think differently and have a different set of knowledge. A hard bug for you to find might be easy for them. Next time you&#8217;re frustrated, call over a coworker and see what happens.

**2. Your Creative Side**

It&#8217;s happened to me over and over: I&#8217;ll build something with a flaw that doesn&#8217;t quite work right. I&#8217;ll go to sleep frustrated and wake up the next morning knowing exactly what the problem is.

It&#8217;s well known that we think in two different manners: creatively and logically. When focused on details (such as debugging a problem), we&#8217;re 100% logical as we jump from thought A to B to C. But it&#8217;s your creative side that can jump from thought A to thought Z via intuition. Like your coworker, your creative brain thinks differently from your logical brain. By going to sleep, you&#8217;re calling over that &#8220;creative coworker&#8221; and asking for help.

**3. Your Mental Model of the System**

If you don&#8217;t know the software tools and APIs you are using to solve problems really well, you&#8217;ll find yourself endlessly debugging. When learning a system like Ruby on Rails for the first few years, debugging is often really just learning how the system works. Software is insanely complex and **every level of the stack is insanely complex**. Abstractions hide much of the complexity and understanding those abstractions well allows you to fit it all within your head.

Malcom Gladwell&#8217;s maxim that expertise comes with 10,000 hours of practice holds here too. After 5 years of full-time experience (40hrs/wk \* 50 wk/yr \* 5), you&#8217;ll have a very strong understanding of your system of choice. That knowledge is very valuable.

**Pro tip**: read the documentation for a library that you are going to use, implement your first attempt at using that library, **and then read the documentation again**. The first time will give you an overview and things to look for but frequently you won&#8217;t comprehend certain aspects due to your inexperience with the library. You almost certainly will comprehend more when you read it the second time.

**Conclusion**

All of these things have one thing in common: thought. Debugging is thinking through the execution of code **in your head**. By improving your knowledge and looking at the problem from different angles, you can much more effectively debug those hard problems that can be so frustrating.
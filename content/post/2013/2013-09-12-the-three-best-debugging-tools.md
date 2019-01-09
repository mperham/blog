---
author: Mike Perham
categories:
- Software
date: 2013-09-12T00:00:00Z
title: The Three Best Debugging Tools
url: /2013/09/12/the-three-best-debugging-tools/
---

**1. Your Coworker**

It's happened to me over and over: I'll spend hours trying to track down a problem. In frustration, I'll ask a coworker to look at the code and frequently they will point out the problem in seconds. It's called situational blindness and it means that you will often overlook the bug right in front of your eyes because you've looked at it so much, your mind has started to ignore it.

Your coworker has another valuable trait: they are different than you. They think differently and have a different set of knowledge. A hard bug for you to find might be easy for them. Next time you're frustrated, call over a coworker and see what happens.

**2. Your Creative Side**

It's happened to me over and over: I'll build something with a flaw that doesn't quite work right. I'll go to sleep frustrated and wake up the next morning knowing exactly what the problem is.

It's well known that we think in two different manners: creatively and logically. When focused on details (such as debugging a problem), we're 100% logical as we jump from thought A to B to C. But it's your creative side that can jump from thought A to thought Z via intuition. Like your coworker, your creative brain thinks differently from your logical brain. By going to sleep, you're calling over that "creative coworker" and asking for help.

**3. Your Mental Model of the System**

If you don't know the software tools and APIs you are using to solve problems really well, you'll find yourself endlessly debugging. When learning a system like Ruby on Rails for the first few years, debugging is often really just learning how the system works. Software is insanely complex and **every level of the stack is insanely complex**. Abstractions hide much of the complexity and understanding those abstractions well allows you to fit it all within your head.

Malcom Gladwell's maxim that expertise comes with 10,000 hours of practice holds here too. After 5 years of full-time experience (40hrs/wk \* 50 wk/yr \* 5), you'll have a very strong understanding of your system of choice. That knowledge is very valuable.

**Pro tip**: read the documentation for a library that you are going to use, implement your first attempt at using that library, **and then read the documentation again**. The first time will give you an overview and things to look for but frequently you won't comprehend certain aspects due to your inexperience with the library. You almost certainly will comprehend more when you read it the second time.

**Conclusion**

All of these things have one thing in common: thought. Debugging is thinking through the execution of code **in your head**. By improving your knowledge and looking at the problem from different angles, you can much more effectively debug those hard problems that can be so frustrating.

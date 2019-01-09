---
author: Mike Perham
categories:
- Software
date: 2008-06-16T00:00:00Z
title: 'Lesson of the Day: Question Everything'
url: /2008/06/16/question-everything/
---

Just when you think you are doing well, someone comes along and points out how dumb you are. I was discussing my need to patch ActiveRecord with [Bruce][1] today and mentioned how I would patch the Ruby files in the activerecord-2.0.2 gem on staging, test everything and then patch the same files on production.

Bruce didn't even pause before asking, "Why don't you just monkey patch the code?".

Oops, caught red-handed, thinking like a Java programmer. It's so easy to fall back on old habits and forget the need to question how you are doing things. You can question your need to question eveything but then it's just [turtles all the way down][2]. :)

**Question everything**: just one of the topics coming in my talk "How NOT to Build a Service".

 [1]: http://codefluency.com
 [2]: http://en.wikipedia.org/wiki/Turtles_all_the_way_down

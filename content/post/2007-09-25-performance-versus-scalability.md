---
author: Mike Perham
categories:
- Rails
- Software
date: 2007-09-25T00:00:00Z
title: Performance versus Scalability
url: /2007/09/25/performance-versus-scalability/
---

I see many, many people confusing terms when it comes to Ruby and Rails.

*   Ruby is a language, just like Java or Python.  Languages have **performance** problems when they can't execute lines of code fast enough for whatever reason (poor choice of algorithms, limited resources, etc).
*   Rails is a framework, just like JEE or Django.  Frameworks are code written in a language so they can have performance problems, but they also span process boundaries (e.g. they access a database, provide shared state, etc) and so can have **scalability** problems.

That's the general rule of thumb I use when internally deciding which word to use in conversation.  If you are unable to support 100 users concurrently with your single Ruby process, that's a performance problem.  If you are unable to add a second Ruby process to share the 100 user load, that's a scalability problem.

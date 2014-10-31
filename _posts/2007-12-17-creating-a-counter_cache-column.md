---
title: Creating a counter_cache column
author: Mike Perham
layout: post
permalink: /2007/12/17/creating-a-counter_cache-column/
categories:
  - Rails
---
A counter\_cache provides a reasonable way to speed up code which faults in a collection just to get the size.  In my experience, the most painful part is initializing the column with the first value.  Traditionally the Rails blogs use Ruby code to iterate through every instance, calculating the value by performing an individual query and saving the result.  It&#8217;s much, much faster (and easier in many cases) to initialize the column value with a single query.  Imagine POSTS and COMMENTS tables where you want a COMMENTS\_COUNT column to speed up the lookup of posts.comments.size. Here&#8217;s the beef:

> update posts, (select post\_id, count(*) as the\_count from comments group by post\_id) as comm set posts.comments\_count = comm.the\_count where posts.id = comm.post\_id;

Note the use of a temporary table to hold the intermediate, calculated size.  This has been tested in MySQL.  YMMV.
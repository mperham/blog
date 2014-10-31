---
title: ActiveRecord 2.1 Performance (Part 1)
author: Mike Perham
layout: post
permalink: /2008/05/03/activerecord-21-performance-1/
categories:
  - Rails
---
I&#8217;ve been playing with the upcoming ActiveRecord 2.1 release in order to gauge any performance concerns.  First let me explain the scenario being tested here: we load a lot of data into a database (both inserts and updates) so my testing mostly concerns optimizing bulk loading. This is definitely not the common case of ActiveRecord usage so you&#8217;ll need to keep this in mind.

First thing I noticed was just going from 2.0.2 to 2.1 led my test case time to go from 17.4 sec to 19.9 sec. While not earth shattering, a 15% performance decrease is of some concern. The decrease seems mostly due to this:

<pre>1.14  	 0.06  	 0.00  	 1.09  	 3659/3659  	ActiveRecord::Dirty#write_attribute</pre>

The smoking gun points to 2.1&#8217;s partial_updates feature. While useful in many cases, it does entail a small bit of runtime overhead. In my case of bulk loading, this feature is not used. It would be nice to be able to disable dirty attribute tracking completely per process or per model. Disabling the Dirty module by hand led to times in the 17.9 sec range.

In the meantime, if you need to skip the overhead, you can use the <tt>write_attribute_without_dirty</tt> method to bypass dirty tracking.  You will of course want to have partial_updates disabled for this model.

<pre>ActiveRecord::Base.partial_updates = false</pre>

And now you need to change this:

<pre>obj.name = 'Foo'</pre>

to this:

<pre>obj.write_attribute_without_dirty('name', 'Foo')</pre>

Remember that this is a hack and not recommended unless this code is in a critical performance path.  The benefits of partial_updates and code cleanliness should almost always outweigh the small performance cost associated with it.
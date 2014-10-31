---
title: Performance and ActiveRecord::Base.establish_connection
author: Mike Perham
layout: post
permalink: /2008/01/07/performance-and-activerecordbaseestablish_connection/
categories:
  - Rails
---
I&#8217;ve got a library which requires its own database so I&#8217;m using a shared superclass for my models which uses establish_connection to point to a different database than the default one used by ActiveRecord::Base.connection.  The problem is performance.  I&#8217;m inserting and updating a large amount of data in a single unit test method and finding that when I use the customized connection, my performance goes from 20 seconds to 45 seconds!  If I change my library to use ActiveRecord::Base&#8217;s connection, the peformance returns to 20 seconds.  I&#8217;m using AR 2.0.1 with the mysql C driver on OSX.

Anyone know why using a custom connection would cause such a dramatic performance degradation?  My base class couldn&#8217;t be simpler:

<pre>    class ContextBase &lt; ActiveRecord::Base</pre>

<pre>      self.abstract_class = true</pre>

<pre>      establish_connection "context_#{ENV['RAILS_ENV'] || 'development'}"</pre>

<pre>    end</pre>
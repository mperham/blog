---
author: Mike Perham
categories:
- Rails
date: 2008-01-07T00:00:00Z
title: Performance and ActiveRecord::Base.establish_connection
url: /2008/01/07/performance-and-activerecordbaseestablish_connection/
---

I've got a library which requires its own database so I'm using a shared superclass for my models which uses establish_connection to point to a different database than the default one used by ActiveRecord::Base.connection.  The problem is performance.  I'm inserting and updating a large amount of data in a single unit test method and finding that when I use the customized connection, my performance goes from 20 seconds to 45 seconds!  If I change my library to use ActiveRecord::Base's connection, the peformance returns to 20 seconds.  I'm using AR 2.0.1 with the mysql C driver on OSX.

Anyone know why using a custom connection would cause such a dramatic performance degradation?  My base class couldn't be simpler:

```ruby
class ContextBase &lt; ActiveRecord::Base
  self.abstract_class = true</pre>
  establish_connection "context_#{ENV['RAILS_ENV'] || 'development'}"
end
```

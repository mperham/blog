---
author: Mike Perham
categories:
- Rails
date: 2008-05-03T00:00:00Z
title: ActiveRecord 2.1 Performance (Part 1)
url: /2008/05/03/activerecord-21-performance-1/
---

I've been playing with the upcoming ActiveRecord 2.1 release in order to gauge any performance concerns.  First let me explain the scenario being tested here: we load a lot of data into a database (both inserts and updates) so my testing mostly concerns optimizing bulk loading. This is definitely not the common case of ActiveRecord usage so you'll need to keep this in mind.

First thing I noticed was just going from 2.0.2 to 2.1 led my test case time to go from 17.4 sec to 19.9 sec. While not earth shattering, a 15% performance decrease is of some concern. The decrease seems mostly due to this:

```sh
1.14  	 0.06  	 0.00  	 1.09  	 3659/3659  	ActiveRecord::Dirty#write_attribute
```

The smoking gun points to 2.1's partial_updates feature. While useful in many cases, it does entail a small bit of runtime overhead. In my case of bulk loading, this feature is not used. It would be nice to be able to disable dirty attribute tracking completely per process or per model. Disabling the Dirty module by hand led to times in the 17.9 sec range.

In the meantime, if you need to skip the overhead, you can use the `write_attribute_without_dirty` method to bypass dirty tracking.  You will of course want to have partial_updates disabled for this model.

```ruby
ActiveRecord::Base.partial_updates = false
```

And now you need to change this:

```ruby
obj.name = 'Foo'
```

to this:

```ruby
obj.write_attribute_without_dirty('name', 'Foo')
```

Remember that this is a hack and not recommended unless this code is in a critical performance path.  The benefits of partial_updates and code cleanliness should almost always outweigh the small performance cost associated with it.

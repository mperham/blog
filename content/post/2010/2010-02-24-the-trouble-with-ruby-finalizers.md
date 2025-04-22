---
author: Mike Perham
categories:
- Ruby
date: 2010-02-24T00:00:00Z
title: The Trouble with Ruby Finalizers
url: /2010/02/24/the-trouble-with-ruby-finalizers/
---

I was test driving [Devil][1], the developer's image library, recently to see if it would work for us in a long-living daemon. Task #1 to that end is to verify the absence of memory leaks, which seem to be common in image libraries. It was almost immediately apparent that Devil contained a large memory leak. So I worked with John Mair to fix the issue.

Devil has a Devil::Image class which uses a finalizer to delete native resources when the image is garbage collected. The problem is that Ruby finalizers are notoriously difficult to use properly so often times they aren't actually run. Here's why:

```ruby
class Devil::Image
  attr_reader :name, :file

  def initialize(name, file)
    @name = name
    @file = file

    ObjectSpace.define_finalizer( self, proc { IL.DeleteImages(1, [name]) } )
  end
end
```

So what's wrong with this code? The issue is that the finalizer proc is a closure which holds a reference to it's `self`, thus making it impossible for the image object to ever be garbage collected. When creating a finalizer proc, you should always use a class method to create the proc so that it does not hold a reference to the corresponding instance, like so:

```ruby
def initialize(name, file)
  @name = name
  @file = file

  ObjectSpace.define_finalizer( self, self.class.finalize(name) )
end
def self.finalize(name)
  proc { IL.DeleteImages(1, [name]) }
end
```

A subtle and evil bug, just like its namesake!

 [1]: http://banisterfiend.wordpress.com/2009/10/14/the-devil-image-library-for-ruby/

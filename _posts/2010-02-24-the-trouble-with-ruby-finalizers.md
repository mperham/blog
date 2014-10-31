---
title: The Trouble with Ruby Finalizers
author: Mike Perham
layout: post
permalink: /2010/02/24/the-trouble-with-ruby-finalizers/
categories:
  - Ruby
---
I was test driving [Devil][1], the developer&#8217;s image library, recently to see if it would work for us in a long-living daemon. Task #1 to that end is to verify the absence of memory leaks, which seem to be common in image libraries. It was almost immediately apparent that Devil contained a large memory leak. So I worked with John Mair to fix the issue.

Devil has a Devil::Image class which uses a finalizer to delete native resources when the image is garbage collected. The problem is that Ruby finalizers are notoriously difficult to use properly so often times they aren&#8217;t actually run. Here&#8217;s why:

<pre lang="ruby">class Devil::Image
    attr_reader :name, :file

    def initialize(name, file)
        @name = name
        @file = file

        ObjectSpace.define_finalizer( self, proc { IL.DeleteImages(1, [name]) } )
    end
end
</pre>

So what&#8217;s wrong with this code? The issue is that the finalizer proc is a closure which holds a reference to it&#8217;s `self`, thus making it impossible for the image object to ever be garbage collected. When creating a finalizer proc, you should always use a class method to create the proc so that it does not hold a reference to the corresponding instance, like so:

<pre lang="ruby">def initialize(name, file)
      @name = name
      @file = file

      ObjectSpace.define_finalizer( self, self.class.finalize(name) )
  end
  def self.finalize(name)
    proc { IL.DeleteImages(1, [name]) }
  end
</pre>

A subtle and evil bug, just like its namesake!

 [1]: http://banisterfiend.wordpress.com/2009/10/14/the-devil-image-library-for-ruby/
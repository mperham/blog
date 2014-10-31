---
title: Current Thoughts on MRI Performance
author: Mike Perham
layout: post
permalink: /2012/11/03/current-thoughts-on-ruby-performance/
categories:
  - Ruby
  - Software
---
Threading and concurrency, as usual, have been a big topic of conversation at Rubyconf 2012. Myself, Tony Arcieri, Charles Nutter, Brian Ford and others all beat the drum of our multi-core future and the reality that MRI is not ready for it.

That&#8217;s why I&#8217;m disappointed in the Ruby 2.0 release. I had hoped they would use the major version bump to break backwards compatibility and unlock a lot of the problems that have been holding back MRI. My understanding is that the native extensions API is responsible for much of the problems: if user-level C code is executing, nothing else can execute because of unprotected, direct access to memory.

What&#8217;s sadly ironic is that the Native C extension API is there to *speed up Ruby*! This was very relevant a decade ago when Ruby&#8217;s VM was primitive and slow. Ruby 1.9 has gotten much faster though and at this point though it is that native API which is preventing us from moving forward with performance and scalability. We might get, say, 50% more speed versus well-tuned Ruby but that speed up comes at a very dear cost: we can&#8217;t use the **800%** speed up that would come by threading across 8 cores!

I think we need a Ruby 2.1 release with FFI or an FFI-like API which allows access to C libraries but is also designed for concurrency. Deprecate the native API at the same time then remove it and the GIL completely in Ruby 2.2. With that we can unlock future VM performance improvements, better GC and unlock our threads!
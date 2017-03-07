---
author: Mike Perham
categories:
- Ruby
date: 2010-08-30T00:00:00Z
tags:
- memcached
title: Dalli -- memcached for Ruby
url: /2010/08/30/dalli-memcached-for-ruby/
---

<img src="http://www.mikeperham.com/wp-content/uploads/2010/08/memcache_logo.png" alt="" title="memcache_logo" width="76" height="75" class="alignleft size-full wp-image-619" />[Dalli][1] is my brand new memcached client for Ruby. I've maintained Ruby's memcache-client for two years now and been dissatisfied with the codebase for a while.  
<img src="http://www.mikeperham.com/wp-content/uploads/2010/08/NorthScale-Labs.gif" alt="" title="NorthScale Labs" width="171" height="62" class="alignright size-full wp-image-617" />  
Coincidentally, [NorthScale][2] approached me recently about building a pure Ruby memcached client which used the new [binary protocol][3] defined in memcached 1.4. We worked out an arrangement to sponsor the OSS project which became Dalli.

My goals for Dalli were threefold:

1.  Clean sheet codebase using the binary protocol
2.  Drop-in replacement for memcache-client in Rails for a very simple upgrade path for Rails developers
3.  Equivalent or faster performance than memcache-client

I'm happy to say that Dalli meets all those goals. For one, the Dalli core is almost half the size of the memcache-client core, 700 vs 1250 LOC! But wait, there's more! Using Rails 3? Dalli drops right in! Using Heroku? Dalli works without any additional configuration! [Take a look at the README][1] for more details.

Please [file an issue][4] if you find a bug or have a feature you'd like to see. In the meantime, happy caching!

 [1]: http://github.com/mperham/dalli
 [2]: http://www.northscale.com
 [3]: http://code.google.com/p/memcached/wiki/MemcacheBinaryProtocol
 [4]: http://github.com/mperham/dalli/issues

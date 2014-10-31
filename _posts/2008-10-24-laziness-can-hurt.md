---
title: Laziness Can Hurt
author: Mike Perham
layout: post
permalink: /2008/10/24/laziness-can-hurt/
categories:
  - Rails
  - Software
---
I like Rails&#8217;s `config.gem` feature: it&#8217;s simple and gives you a lot of functionality for cheap, much like Rails itself.  I just spent half a day tracking down a problem because we were overusing it.

I tend to be fanatical about minimizing dependencies as it has bit me several times in the past.  In this case, we were using `config.gem` to load a test dependency, **redgreen**.  All that gem does is colorize your test output.  There&#8217;s no reason to list it as an application dependency but the team wanted all gems to install with `rake gems:install`. It didn&#8217;t sit right with me at the time but I didn&#8217;t feel strongly enough to raise the issue.  Well as it turns out when you add **redgreen** via `config.gem`, it adds a test/unit `at_exit` handler that exhibits some odd behavior, including breaking the test suite on our sandbox/ci server.

I&#8217;m not blaming **redgreen** and I&#8217;m not blaming `config.gem` since we really weren&#8217;t using either as designed.  Once it was loaded as normal, everything worked as expected. Lesson reinforced: *keep your app&#8217;s dependencies as simple as possible*. There&#8217;s no reason why **redgreen** should be installed on our production servers.
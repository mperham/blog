---
author: Mike Perham
categories:
- Rails
- Software
date: 2008-10-24T00:00:00Z
title: Laziness Can Hurt
url: /2008/10/24/laziness-can-hurt/
---

I like Rails's `config.gem` feature: it's simple and gives you a lot of functionality for cheap, much like Rails itself.  I just spent half a day tracking down a problem because we were overusing it.

I tend to be fanatical about minimizing dependencies as it has bit me several times in the past.  In this case, we were using `config.gem` to load a test dependency, **redgreen**.  All that gem does is colorize your test output.  There's no reason to list it as an application dependency but the team wanted all gems to install with `rake gems:install`. It didn't sit right with me at the time but I didn't feel strongly enough to raise the issue.  Well as it turns out when you add **redgreen** via `config.gem`, it adds a test/unit `at_exit` handler that exhibits some odd behavior, including breaking the test suite on our sandbox/ci server.

I'm not blaming **redgreen** and I'm not blaming `config.gem` since we really weren't using either as designed.  Once it was loaded as normal, everything worked as expected. Lesson reinforced: *keep your app's dependencies as simple as possible*. There's no reason why **redgreen** should be installed on our production servers.

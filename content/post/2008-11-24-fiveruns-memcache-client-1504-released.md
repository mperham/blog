---
author: Mike Perham
categories:
- Ruby
date: 2008-11-24T00:00:00Z
title: fiveruns-memcache-client 1.5.0.4 released
url: /2008/11/24/fiveruns-memcache-client-1504-released/
---

I've pulled a few changes from Jeffrey Hardy at 37signals, and added a few of my own. Most of the fixes are for Ruby 1.9 compatibility. From the history:

*   Get test suite working again (packagethief)
*   Ruby 1.9 compatiblity fixes (packagethief, mperham)
*   Consistently return server responses and check for errors (packagethief)
*   Properly calculate CRC in Ruby 1.9 strings (mperham)
*   Drop rspec in favor of test/unit, for 1.9 compat (mperham)

`sudo gem install fiveruns-memcache-client -s http://gems.github.com`

Please comment if you have any issues or questions.

UPDATE: And just as soon as I'm done with the announcement, I [release 1.5.0.5][1].

 [1]: http://github.com/fiveruns/memcache-client/commit/9f81841bbb4fc6a3dfe5525a285a045d3da1a589

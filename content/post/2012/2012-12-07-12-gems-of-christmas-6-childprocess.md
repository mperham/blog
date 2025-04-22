---
author: Mike Perham
categories:
- Ruby
date: 2012-12-07T00:00:00Z
title: '12 Gems of Christmas #6 -- childprocess'
url: /2012/12/07/12-gems-of-christmas-6-childprocess/
---

Ruby has many different gems and APIs for spawning child processes but none I like more than childprocess. [posix-spawn][1] and [open4][2] are popular alternatives but [childprocess][3] has a clean Ruby API and aims to work on all Ruby platforms.

Here we have an example setting up a child process pipeline, performing the equivalent of `ps aux | grep -E 'redis|memcached'`.

```ruby
require 'childprocess'

listing = ChildProcess.build("ps", "aux")

search = ChildProcess.build("grep", '-E', %w(redis memcached).join('|'))
search.duplex = true
search.io.stdout = STDOUT
search.start

listing.io.stdout = search.io.stdin
listing.start
listing.wait

search.io.stdin.close
search.wait
```

With subprocesses, the tricky bit is usually hooking up the IO streams correctly. In this case, the `duplex` flag signals that you want to write to STDIN of the process (i.e. use it as the RHS of a pipe). Everything else is pretty straightforward; childprocess makes multi-processing with Ruby simple.

Tomorrow I'll dive into a little gem which aims to improve Rails logging in production.

 [1]: https://github.com/rtomayko/posix-spawn
 [2]: https://github.com/ahoward/open4
 [3]: https://github.com/jarib/childprocess

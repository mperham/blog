---
author: Mike Perham
categories:
- Rails
date: 2009-02-07T00:00:00Z
title: Improved Deadlock Retry
url: /2009/02/07/improved-deadlock-retry/
---

Anyone who's built a reasonably complex web site on top of a database has seen database deadlock. MySQL will throw a timeout error after waiting for 30 seconds, thereby ending the deadlock in a brutal but effective manner. Rails has a plugin, known as deadlock_retry, which will catch those errors and simply retry the transaction. There's a good chance this will work since deadlocks are race conditions but it's not very effective for finding and solving the underlying problem.

So I've [forked the code][1] and spruced it up a bit:

1.  If a deadlock happens, the code will log the output of SHOW INNODB STATUS, which will indicate who was waiting for what. Knowing the tables in contention goes a long way to understanding the problem.
2.  The code now runs as a gem, not as a plugin. You don't need to put the code in your application, just add this config.gem reference in config/environment.rb and use `rake gems:install` to install it:

```ruby
config.gem 'mperham-deadlock_retry', :lib => 'deadlock_retry', :source => 'http://gems.github.com'
```

This is code I wrote for our internal usage of deadlock_retry at [FiveRuns][2]. Please let me know if you find this improvement useful.

 [1]: http://github.com/mperham/deadlock_retry
 [2]: http://fiveruns.com

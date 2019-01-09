---
author: Mike Perham
categories:
- Software
date: 2014-09-22T00:00:00Z
title: Don't Daemonize your Daemons!
url: /2014/09/22/dont-daemonize-your-daemons/
---

For years developers have followed the same arcane [dozen steps][1] to create a long-lived daemon process on Unix-based systems. **These steps were state of the art in 2000 but they are no longer best practice today.** [Jake Gordon's recent blog post on daemonizing Ruby processes][2] is 100% factual but his approach is not recommended these days. Your application code should not be dealing with PID files, log redirection or other low-level concerns.  
<!--more-->

**Best Practices**

Don't take my word for it, read [systemd's daemon man page][3]. There's a lot of systemd-specific cruft in that list but the net is:

1.  Log to stdout.
2.  Shut down on TERM/INT.
3.  Reload config on HUP.
4.  Provide the necessary config file for your favorite init system to control your daemon.

This makes developing a modern daemon **much** easier. The init config file is what you use to configure logging, run as a user, and many other things you previous did in code. You tweak a few init config settings; your code focuses less on housekeeping and more on functionality.

What's the result? In development mode, your process will run in the foreground, as yourself and log to stdout: perfect for developers. In production mode, the init system will run your process as a configured user with logging sent to a specific location and log rotated automatically. Less system administration, easier debugging, simpler code, all because you leveraged the init system to do the work for you!

**Worst Practices**

Using a deployment tool like Capistrano to directly start any process is a bad idea. What happens when that process crashes? (Most likely it disappears and now your application is broken.) Who rotates the logs to ensure they don't fill the disk? (Most likely you after filling the disk the first time.) Instead, integrate your daemon into the init system, configure it to respawn if it crashes and have Capistrano manage the process via init:

<pre class="brush: ruby; title: ; notranslate" title="">task :restart do
  run "initctl restart sidekiq"
end
</pre>

As always, KISS. Let your operating system handle daemons, respawning and logging while you focus on your application features and users.

 [1]: http://0pointer.de/public/systemd-man/daemon.html#SysV%20Daemons
 [2]: http://codeincomplete.com/posts/2014/9/15/ruby_daemons/
 [3]: http://0pointer.de/public/systemd-man/daemon.html#New-Style%20Daemons

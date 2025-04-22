---
author: Mike Perham
categories:
- Software
date: 2012-12-05T00:00:00Z
title: '12 Gems of Christmas #7 -- lunchy'
url: /2012/12/05/12-gems-of-christmas-7-lunchy/
---

I couldn't resist covering one of my own gems in the 12 Gems of Christmas. While I'm best known for [dalli][1] and [sidekiq][2], [lunchy][3] has little place in my heart because it solves a minor annoyance all OSX-based developers have: starting and stopping system daemons.

Here's how everyone does it with standard OSX:

```
launchctl load [oh, what's the blasted filename?]
cd ~/Library/LaunchAgents
ls
launchctl load ~/Library/LaunchAgents/io.redis.redis-server.plist
```

That's a lot of typing and annoyance every time you want to start Redis. Here's how you do it in lunchy:

```
lunchy start redis
```

No need to remember the filename of the plist file, lunchy just scans for a plist with the given substring in it. `lunchy ls` will show you all the agents you can control. See the README for the full command set available and happy l(a)unching!

Tomorrow I'll show you an elegant gem for starting and managing your own child processes!

 [1]: https://github.com/mperham/dalli
 [2]: http://sidekiq.org
 [3]: https://github.com/mperham/lunchy

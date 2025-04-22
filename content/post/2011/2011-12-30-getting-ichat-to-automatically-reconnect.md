---
author: Mike Perham
categories:
- Software
date: 2011-12-30T00:00:00Z
title: Getting iChat to automatically reconnect
url: /2011/12/30/getting-ichat-to-automatically-reconnect/
---

I've noticed a problem with iChat for the last year or two: if your network drops, you stay Disconnected until you manually tell iChat to log back in. That's pretty lame, my Comcast cable drops several times a day so I need something a little more robust than that. I found a workaround: use cron to do the work for you. Fire up a Terminal, run `crontab -e` and put this in it:

```
*/5 * * * * osascript -e 'tell application "System Events" to if (processes whose name is "iChat") exists then tell application "iChat" to log in'
```

This uses AppleScript to tell iChat to log in every 5 minutes. Now if the network drops, you'll only be disconnected a few minutes.

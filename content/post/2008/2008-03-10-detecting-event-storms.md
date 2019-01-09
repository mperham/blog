---
author: Mike Perham
categories:
- Software
date: 2008-03-10T00:00:00Z
title: Detecting Event Storms
url: /2008/03/10/detecting-event-storms/
---

I've got an interesting problem I'm trying to solve.  We detect outage events for our customers.  However, if we have a bug or an outage on our side, it's very possible that we can create a false positive and send spurious events.  How do you detect these false positives (in very near real time!) in order to route them to /dev/null rather than bigwig@fatcatenterprise.com?  :)  I'm guessing this is one of those problems I get about once or twice per year which really require mulling for a week or two before I can come up with a comprehensive solution.  If you have any brilliant ideas, please comment dear reader.  Else I will devote a future posting to what I came up with.

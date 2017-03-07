---
author: Mike Perham
categories:
- Software
date: 2008-07-15T00:00:00Z
title: Web 2.0 and Databases
url: /2008/07/15/web-20-and-databases/
---

Below is an interesting series of interviews by Tim O'Reilly on large web sites and their database usage.  Every single organization was sharding their data.  Note the series is over two years old and some advice is plainly wrong these days; note that Craigslist's advice to use MyISAM "because it works" is no longer relevant.  I've found InnoDB to be more predictable and faster in my real world testing and [Baron agrees][1] (pdf)...

[Web 2.0 and Databases Part 1: Second Life -- O'Reilly Radar][2]

 [1]: http://www.percona.com/files/presentations/Percona_OfferPal_Outrun_TheLions.pdf
 [2]: http://radar.oreilly.com/2006/04/web-20-and-databases-part-1-se.html

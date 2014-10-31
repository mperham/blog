---
title: Web 2.0 and Databases
author: Mike Perham
layout: post
permalink: /2008/07/15/web-20-and-databases/
categories:
  - Software
---
Below is an interesting series of interviews by Tim O&#8217;Reilly on large web sites and their database usage.  Every single organization was sharding their data.  Note the series is over two years old and some advice is plainly wrong these days; note that Craigslist&#8217;s advice to use MyISAM &#8220;because it works&#8221; is no longer relevant.  I&#8217;ve found InnoDB to be more predictable and faster in my real world testing and [Baron agrees][1] (pdf)&#8230;

[Web 2.0 and Databases Part 1: Second Life &#8211; O&#8217;Reilly Radar][2]

 [1]: http://www.percona.com/files/presentations/Percona_OfferPal_Outrun_TheLions.pdf
 [2]: http://radar.oreilly.com/2006/04/web-20-and-databases-part-1-se.html
---
title: Upgrading tracknowledge.org
author: Mike Perham
layout: post
permalink: /2008/09/07/upgrading-tracknowledgeorg/
categories:
  - Personal
  - Rails
---
I&#8217;m upgrading my Rails testbed, <http://www.tracknowledge.org>, with the latest and greatest.  The Rails world moves VERY quickly and staying on top of it can be challenging.  When I built it initially in April 2008, nginx + mongrel was the typical deployment model.  I stuck with Apache though since it was already installed on the machine; installing and configuring nginx is a known PITA.  Now I&#8217;m going to install Phusion&#8217;s [Passenger][1] and [Ruby Enterprise Edition][2].  Passenger and REE have some big advantages over the typical mongrel model, mostly around memory consumption &#8211; always a good thing on a limited VPS slice like I have.  The plan:

1.  &#8220;yum update&#8221; to get the latest security and OS updates
2.  Install REE.
3.  Install Passenger.
4.  Configure apache to use REE and Passenger.
5.  Deploy my latest [tracknowledge][3] source running on Edge Rails (i.e. 2.2 alpha).

You might wonder why I&#8217;m running Edge Rails.  Well, I wanted to get the multithreading and connection pooling features in ASAP so I can test them.  [DataFabric][4] does rely on some of the innards of ActiveRecord&#8217;s ConnectionAdapter class so I&#8217;ll probably need to make changes to get it working on ActiveRecord 2.2.

<an hour passes>

And it&#8217;s done!  Wow, that was pretty easy.  The hardest part by far was simply updating my app to list its gem dependencies and install those gems in the new gem repo for REE.  Kudos to the Phusion guys for making Rails deployment MUCH MUCH simpler!

 [1]: http://www.modrails.com/
 [2]: http://www.rubyenterpriseedition.com/
 [3]: http://github.com/mperham/tracknowledge
 [4]: http://github.com/fiveruns/data_fabric
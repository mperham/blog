---
title: "Sidekiq Pro Gem Server Outage"
author: Mike Perham
layout: post
permalink: /2015/06/01/sidekiq-pro-gem-server-outage
published: true
---

On Friday 6:30 PM PST, the Sidekiq Pro gem server became unavailable due to a [Linode data center outage][0]
in Fremont, CA.  Connectivity was restored after 15 hours at Saturday 9:30 AM PST.  I'm terribly sorry not only
for the outage but the extended length of time.

### The Past

I knew that the gem server was a single point of failure and had plans to build a redundant server later this summer.
I had spent some time in Oct 2014 building a new, simpler gem server but hadn't automated the process - the gem server
was still a "unique snowflake" and had a number of files which couldn't easily be recovered to bring up a replacement server.

### The Present

While I was waiting for the server to become available, I started the process of automating the gem server build.
Once connectivity was restored, I immediately copied the irreplacable files off-site.  Today I have a new DigitalOcean
droplet which was built with a simple shell script and a repository of those critical files necessary (TLS cert, .gem
binary files, etc).

### The Future

The plan going forward is to have two servers available, one in LA and one in NY.  I'll rebuild one every six
months so the servers will never be older than one year.  This redundant setup should be active and working by the end of June.

[0]: http://status.linode.com/incidents/2rm9ty3q8h3x

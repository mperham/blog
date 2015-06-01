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

While I was waiting for the server to become available, I started the process of automating the gem server build Saturday morning.
Once connectivity was restored, I immediately copied the irreplacable files off-site.  As of today (Monday) I was able to build
a new DigitalOcean droplet with a simple shell script and a repository of those critical files necessary
(TLS cert, .gem binary files, etc).  Within 10 minutes of creation it was successfully serving Sidekiq Pro's gems to my test app.

### The Future

By the end of the month I will have two servers available, one in SF and one in NY.  Each server will be rebuilt annually to ensure
the build process is tested every 6 months and remains usable.  I hope this will get us closer to the goal of 100% uptime.

### Postscript

If you are interested in app deploys that don't depend on any gem servers, take a look at the [`bundle package`][1] command.

[0]: http://status.linode.com/incidents/2rm9ty3q8h3x
[1]: http://bundler.io/v1.9/bundle_package.html

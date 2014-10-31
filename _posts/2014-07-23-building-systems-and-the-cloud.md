---
title: Building Systems and The Cloud
author: Mike Perham
layout: post
permalink: /2014/07/23/building-systems-and-the-cloud/
categories:
  - Software
---
If you are building a system to run in the cloud, be prepared to spend much of your time building a resilient system.

Not a fast system. Not a very efficient system. Not a system full of fun, quirky features that users love. A resilient system because you will see performance and network issues at every connection point in your system. I hope that&#8217;s what you want.  
<!--more-->

Cheap cloud machines are SLOW. Your software will be running on a virtual machine, sharing physical hardware with N other virtual machines. The local hard disk is a shared resource that everyone uses. If one machine hits it hard, the other VMs will see poor disk I/O performance during that time. The local network can be over-provisioned and show poor throughput or latency. This is known as the noisy neighbor problem and it&#8217;s endemic to cloud providers: EC2, Heroku, Digital Ocean, etc.

I see the same problem again and again with Sidekiq users: occasional but regular network timeouts talking to Redis on our Heroku or EC2 instances. There are several options:

1.  Raise the Redis client&#8217;s network timeout from the default of 1 sec to N seconds. I&#8217;ve seen latencies over 5 seconds. This won&#8217;t fix the problem but your system will raise fewer errors.
2.  Use [Sidekiq Pro][1]&#8216;s reliable client feature. It will catch the timeout error and retry the operation regularly until it succeeds.
3.  Move onto dedicated hardware where you know the network is high-quality and the machine isn&#8217;t overloaded.

Note the real solutions, 2 & 3, cost money. When you choose to use a cloud provider, often times you are looking to save a buck. I&#8217;m here to tell you that you&#8217;ll pay that money somewhere: late nights debugging, unhappy customers or a credit card bill. You can save a few bucks by running a small Heroku dyno but I bet you&#8217;ll find yourself spending days optimizing your system to run in 512MB.

Here&#8217;s my perfect architecture for building a new business: one dedicated machine, 12 cores, 48GB of memory, 200GB SSD RAID 1. I just priced one at $749/mo at a reasonably priced hosting service and it will scale to tens of millions of hits per day if you know what you are doing. You have no worries about neighbors, you manage one machine and not coordinate 20 different instances. The hosting service should monitor all hardware and provide a 1 hour SLA to replace any dying hardware. One part your accountant will love: well defined operational costs. You know exactly how much you are going to pay each month and I guarantee it will be much cheaper than the equivalent cloud resources.

Once your business starts to take off, you can tackle the work necessary to add resiliency and distribute load across a cluster of servers but you might be surprised: often a single machine will be more reliable than a cluster of machines. Brand name &#8220;enterprise&#8221; hardware is generally very reliable (e.g. Intel SSDs) and adding more moving parts (i.e. the software and configuration necessary to scale to N machines) rarely makes a system more stable.

There are reasons for using cloud providers but I don&#8217;t find them compelling for startups. Building a house on top of a foundation made from quicksand seems like poor judgment. Renting reliable hardware from a dedicated hosting service gives you known operational costs while also wasting far less of your time shoring up that quicksand, allowing you to focus on building your product and getting customers.

**Side Note**

For the record, the cloud is a good idea in a corporate environment where getting a server from IT can take weeks (!) to go through the proper channels. Use the cloud to prototype the service while doing the paperwork to eventually bring the service in-house on an IT-supported server.

 [1]: http://sidekiq.org/pro
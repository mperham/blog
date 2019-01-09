---
author: Mike Perham
categories:
- Software
date: 2010-08-05T00:00:00Z
title: Securing Network Services
url: /2010/08/05/securing-network-services/
---

The recent [memcached security exposé][1] highlighted the fact that simple vulnerabilities require constant vigilance and education for new developers.

Rule #1 of Network Security: **Don't expose services which are not designed to be exposed.**

Web and app servers will usually have 2-3 ports open to the public: ssh, http and https. All others should be vetted to determine if they should be public or not. Here's the current state of mikeperham.com:

`<br />
mike@perham:~$ netstat -a | grep LIST<br />
tcp        0      0 localhost:mysql         *:*                     LISTEN<br />
tcp        0      0 *:www                   *:*                     LISTEN<br />
tcp        0      0 *:ssh                   *:*                     LISTEN<br />
tcp        0      0 localhost:smtp          *:*                     LISTEN<br />
`

There's two types of ports in this list. 'localhost' means that my database is just listening locally:

**localhost:mysql**

whereas the star indicates my web server is listening on all network interfaces, including the public:

***:www**

In the case of memcached, you want to configure it to listen locally only if you just have a single memcached instance. In Ubuntu/Debian, you would edit `/etc/memcached.conf` and ensure that:  
`<br />
-l 127.0.0.1<br />
`

is in the file. Otherwise memcached will by default listen on all interfaces and be exposed publicly.

Firewall configuration brings another dimension of variability into the mix but I prefer to configure my services to listen correctly first and then determine any additional firewall rules necessary based on the network topology. Using Memcached servers on multiple machine might require some fancy firewall rules to ensure that they can talk to each other while not being exposed publicly. One nice thing about Amazon's EC2 service is that it forces you to explicitly open ports to the public via firewall rules, everything else is internal by default.

In summary, I always perform a quick port audit of all machines after I'm done configuring them to ensure that they are as secure as possible before putting them in production. A quick `netstat` command can go a long way to ensure a sound night's sleep.

 [1]: http://www.slideshare.net/sensepost/cache-on-delivery

---
author: Mike Perham
categories:
- Ruby
date: 2010-02-10T00:00:00Z
tags:
- eventmachine
title: Asynchronous DNS Resolution
url: /2010/02/10/asynchronous-dns-resolution/
---

Ruby has a serious scalability problem most Rubyists are unaware of. When you lookup the IP address for a hostname, the entire Ruby process blocks by default. If you have a slow DNS server, your process can grind to a halt waiting for hostname resolution. Ruby comes standard with a fix, resolv-replace, which provides a DNS resolver that does not block the entire process. It does however block the Thread, like any other instance of blocking I/O.

So I wrote an EventMachine-aware DNS resolver that ensures that your asynchronous operations don't block while performing DNS resolution. Take a look at [em-resolv-replace][1] and give it a whirl.

 [1]: http://github.com/mperham/em-resolv-replace

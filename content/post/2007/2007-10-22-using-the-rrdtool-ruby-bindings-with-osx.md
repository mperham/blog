---
author: Mike Perham
categories:
- Ruby
date: 2007-10-22T00:00:00Z
keywords:
- rrdtool, ruby, bindings, osx
title: Using the RRDTool Ruby bindings with OSX
url: /2007/10/22/using-the-rrdtool-ruby-bindings-with-osx/
---

RRDTool is a nice metric storage and graphing library. We're using its Ruby binding internally to integrate RRDTool into our product but I was having problems getting it running:

> .....................dyld: NSLinkModule() error  
> dyld: Symbol not found: \_rrd\_graph  
> Referenced from: /usr/local/lib/ruby/site_ruby/1.8/universal-darwin8.0/RRD.bundle  
> Expected in: flat namespace

This error is due to the Ruby binding not being able to find the native RRD library, librrd. When you install rrdtool via Mac Ports, it installs everything in /opt/local, not /usr/local. What you need to do is update `extconf.rb` in `rrdtool-1.2.x/bindings/ruby` and change the following line so that the binding will look in the proper location for the Mac Ports install:

> dir_config("rrd","../../src","/opt/local/lib")

Now run `ruby extconf.rb ; make ; sudo make install` to install the modified Ruby binding.

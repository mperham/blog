---
title: Using the RRDTool Ruby bindings with OSX
author: Mike Perham
layout: post
permalink: /2007/10/22/using-the-rrdtool-ruby-bindings-with-osx/
keywords:
  - rrdtool, ruby, bindings, osx
categories:
  - Ruby
---
RRDTool is a nice metric storage and graphing library. We&#8217;re using its Ruby binding internally to integrate RRDTool into our product but I was having problems getting it running:

> &#8230;&#8230;&#8230;&#8230;&#8230;&#8230;&#8230;dyld: NSLinkModule() error  
> dyld: Symbol not found: \_rrd\_graph  
> Referenced from: /usr/local/lib/ruby/site_ruby/1.8/universal-darwin8.0/RRD.bundle  
> Expected in: flat namespace

This error is due to the Ruby binding not being able to find the native RRD library, librrd. When you install rrdtool via Mac Ports, it installs everything in /opt/local, not /usr/local. What you need to do is update `extconf.rb` in `rrdtool-1.2.x/bindings/ruby` and change the following line so that the binding will look in the proper location for the Mac Ports install:

> dir_config(&#8220;rrd&#8221;,&#8221;../../src&#8221;,&#8221;/opt/local/lib&#8221;)

Now run `ruby extconf.rb ; make ; sudo make install` to install the modified Ruby binding.
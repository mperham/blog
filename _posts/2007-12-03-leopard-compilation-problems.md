---
title: Leopard Compilation Problems
author: Mike Perham
layout: post
permalink: /2007/12/03/leopard-compilation-problems/
categories:
  - Ruby
---
If you are running into &#8220;undefined symbol&#8221; errors when compiling Ruby extensions, make sure you override the ARCHFLAGS so you aren&#8217;t cross-compiling to PPC.  Put this in your ~/.bash_profile and a lot of mysterious compilation problems should go away.

export ARCHFLAGS=&#8221;-arch i386&#8243;
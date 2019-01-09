---
author: Mike Perham
categories:
- Ruby
date: 2007-12-03T00:00:00Z
title: Leopard Compilation Problems
url: /2007/12/03/leopard-compilation-problems/
---

If you are running into "undefined symbol" errors when compiling Ruby extensions, make sure you override the ARCHFLAGS so you aren't cross-compiling to PPC.  Put this in your ~/.bash_profile and a lot of mysterious compilation problems should go away.

export ARCHFLAGS="-arch i386"

---
title: data_fabric 1.1.0 released
author: Mike Perham
layout: post
permalink: /2008/11/22/data_fabric-110-released/
categories:
  - Rails
---
Justin Balthrop at Geni was nice enough to donate a few fixes to [data_fabric][1]. The major issue was that when the connection changed, the plugin established a brand new connection. With his changes, data_fabric will now cache the connection and reuse it. This can lead to a noticeable performance increase if your code was switching connections frequently.

The logging code was also refactored to simplify it and fix a nil pointer I frequently ran into.

The changes pass all the existing tests but they are significant. Please test on your own and let me know if you have any issues.

`sudo gem install data_fabric`

**Note:** this release is **not** compatible with Rails 2.2. The next one will be.

 [1]: http://github.com/fiveruns/data_fabric
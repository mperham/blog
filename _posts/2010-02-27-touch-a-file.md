---
title: Touch a File
author: Mike Perham
layout: post
permalink: /2010/02/27/touch-a-file/
categories:
  - Ruby
---
Here&#8217;s how to touch a file using Ruby, easy as 1-2-3:

<pre lang="ruby">File.utime(access_time, mod_time, filename)
</pre>
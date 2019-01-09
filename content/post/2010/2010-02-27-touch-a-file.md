---
author: Mike Perham
categories:
- Ruby
date: 2010-02-27T00:00:00Z
title: Touch a File
url: /2010/02/27/touch-a-file/
---

Here's how to touch a file using Ruby, easy as 1-2-3:

<pre lang="ruby">File.utime(access_time, mod_time, filename)
</pre>

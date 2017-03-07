---
author: Mike Perham
categories:
- Ruby
- Software
date: 2008-05-22T00:00:00Z
tags:
- begin
- rescue
- Ruby
title: Ruby Scoping Oddity
url: /2008/05/22/ruby-scoping-oddity/
---

This prints out "1":

`</p>
<pre>
  begin
    a = 1
    raise RuntimeError, "foo"
  rescue => e
    puts a
  end
</pre>
<p>`

I would think that *a* would be out of scope inside the rescue section but I guess Ruby considers the rescue section part of the begin/end block?

---
title: Ruby Scoping Oddity
author: Mike Perham
layout: post
permalink: /2008/05/22/ruby-scoping-oddity/
categories:
  - Ruby
  - Software
tags:
  - begin
  - rescue
  - Ruby
---
This prints out &#8220;1&#8221;:

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
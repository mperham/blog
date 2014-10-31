---
title: Ruby Open Files
author: Mike Perham
layout: post
permalink: /2010/03/19/ruby-open-files/
categories:
  - Ruby
---
Get the number of open files for each of your Ruby processes:

<pre lang="bash">sudo lsof | grep ruby | ruby -e 'h=Hash.new(0);$&lt;.each_line {|line| h[line.split[1]] += 1};p h'
</pre>

Example output:  
`<br />
{"3268"=>808, "4513"=>399, "4795"=>237, "5067"=>178, "5083"=>16, "23751"=>108}<br />
`
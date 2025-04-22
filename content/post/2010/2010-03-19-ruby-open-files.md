---
author: Mike Perham
categories:
- Ruby
date: 2010-03-19T00:00:00Z
title: Ruby Open Files
url: /2010/03/19/ruby-open-files/
---

Get the number of open files for each of your Ruby processes:

```
sudo lsof | grep ruby | ruby -e 'h=Hash.new(0);$<.each_line {|line| h[line.split[1]] += 1};p h'
```

Example output:  
```
{"3268"=>808, "4513"=>399, "4795"=>237, "5067"=>178, "5083"=>16, "23751"=>108}<br />
```

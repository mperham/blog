---
title: Contributing to Ruby
author: Mike Perham
layout: post
permalink: /2010/12/08/contributing-to-ruby/
categories:
  - Ruby
---
I had a very pleasant experience recently in contributing [some net/http documentation][1] improvements to Ruby. Ruby Core has made contributing very easy these days, it&#8217;s really as simple as:

*   Fork http://github.com/ruby/ruby
*   Make and commit your changes in your repo
*   Send a pull request

In other words, contributing to Ruby is now just as easy to contribute to as any other Github project! This is a huge deal. Obviously there are caveats: if you are making significant changes to runtime code, you should probably enter an issue in [Redmine][2] and/or send an email to the ruby-dev mailing list. But for small cleanups and RDoc improvements that have been sorely missing for years, there&#8217;s no longer any excuse!

 [1]: https://github.com/ruby/ruby/commit/baf7a09d3509f7d858fc7a705e14feaaf5ad56b6
 [2]: http://redmine.ruby-lang.org/
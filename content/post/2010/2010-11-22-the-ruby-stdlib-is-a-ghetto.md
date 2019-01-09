---
author: Mike Perham
categories:
- Ruby
date: 2010-11-22T00:00:00Z
title: The Ruby Stdlib is a Ghetto
url: /2010/11/22/the-ruby-stdlib-is-a-ghetto/
---

Much of Ruby's standard library (the set of classes shipped with the Ruby VM itself) is old and crufty. For laughs, go look at the code for some of the classes that you've never used. Chances are it's from 2000-2003 and doesn't even look like idiomatic Ruby. I'm wondering what classes should be removed from the standard library or deprecated so that higher quality replacements can take their place.

The canonical example is Ruby's net/http library. Its performance and API are just terrible. (Side note: how do you know if an API is terrible? If you have to consult the docs even after having used the API for the past 5 years.) But because it's in the standard library, most people use it as the base for higher-level API abstractions (e.g. httparty, rest-client).

So looking at [Ruby's core RDoc][1], my suggested list for removal (where removal means move to a rubygem):

*   Net::*
*   DRb
*   REXML
*   RSS
*   Rinda
*   WEBrick
*   XML

Any others I missed? Will Ruby 1.9.3 or 2.0 get a good spring cleaning or will we have to live with these classes forever?

 [1]: http://ruby-doc.org/ruby-1.9/index.html

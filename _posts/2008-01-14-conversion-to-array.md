---
title: Conversion to Array
author: Mike Perham
layout: post
permalink: /2008/01/14/conversion-to-array/
categories:
  - Ruby
---
If you want to autobox an object into an Array, Ruby provides a deprecated method, Object#to_a, to do this.  The better, non-deprecated way is to use Array conversion:

<pre>irb(main):001:0&gt; foo = Object.new</pre>

<pre>=&gt; #&lt;Object:0x15234&gt;</pre>

<pre>irb(main):002:0&gt; foo.to_a</pre>

<pre>(irb):2: warning: default `to_a' will be obsolete</pre>

<pre>=&gt; [#&lt;Object:0x15234&gt;]</pre>

<pre>irb(main):003:0&gt; Array(foo)</pre>

<pre>=&gt; [#&lt;Object:0x15234&gt;]</pre>

<pre>irb(main):004:0&gt;  a = Array.new</pre>

<pre>=&gt; []</pre>

<pre>irb(main):005:0&gt; Array(a)</pre>

<pre>=&gt; []</pre>
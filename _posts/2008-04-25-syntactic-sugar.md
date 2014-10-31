---
title: Syntactic Sugar
author: Mike Perham
layout: post
permalink: /2008/04/25/syntactic-sugar/
categories:
  - Java
  - Ruby
---
There&#8217;s only one thing I miss in Java that Ruby doesn&#8217;t have:

<pre>String[] list = {
"Foo",
"Bar",
"Blaz",
}
</pre>

Note the last trailing comma. This is a syntax error in Ruby but legal in Java. If you add another element later, you don&#8217;t need to remember to add a comma to the previous entry. Minor, sure, but useful, especially with interpreted languages where syntax errors are not found until runtime.
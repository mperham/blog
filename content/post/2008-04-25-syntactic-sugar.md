---
author: Mike Perham
categories:
- Java
- Ruby
date: 2008-04-25T00:00:00Z
title: Syntactic Sugar
url: /2008/04/25/syntactic-sugar/
---

There's only one thing I miss in Java that Ruby doesn't have:

<pre>String[] list = {
"Foo",
"Bar",
"Blaz",
}
</pre>

Note the last trailing comma. This is a syntax error in Ruby but legal in Java. If you add another element later, you don't need to remember to add a comma to the previous entry. Minor, sure, but useful, especially with interpreted languages where syntax errors are not found until runtime.

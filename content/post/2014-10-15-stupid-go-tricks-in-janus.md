---
author: Mike Perham
categories:
- Software
date: 2014-10-15T00:00:00Z
title: Stupid Go tricks in Janus
url: /2014/10/15/stupid-go-tricks-in-janus/
---

I've used [Janus][1] as my main text editor for the last few years; it's a good solution for people like myself that want to quickly install not just MacVim but also a curated set of plugins necessary to have a productive IDE for Ruby/JS development.

Side note: **learn vim if you're a developer and don't know it already**. Every Unix environment in the world has vim installed. Learning vim is an excellent investment of your time and ensures you can be productive everywhere, not just your own machine.

The Janus developers recently added a better Go plugin and I wanted to call out a few features that are really cool. Put these lines in your ~/.vimrc.after:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">au FileType go nmap &lt;leader&gt;c &lt;Plug&gt;(go-coverage)
au FileType go nmap gd &lt;Plug&gt;(go-def)
au FileType go nmap &lt;Leader&gt;r &lt;Plug&gt;(go-rename)
</pre>

1.  Typing "\c" will open an HTML code coverage report in your browser for the current package showing test coverage.
2.  Typing "gd" will "goto definition" of the word under the cursor, allowing you to jump to methods or types.
3.  Typing "\r" will rename the thing under the cursor. Real, type-safe renaming in vim, awesome!

Go's static type system can be cumbersome at times but does allow automatic refactoring within editors. I'm happy to see these theoretical benefits finally trickle down to improve my daily work.

 [1]: https://github.com/carlhuda/janus/

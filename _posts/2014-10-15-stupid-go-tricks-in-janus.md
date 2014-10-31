---
title: Stupid Go tricks in Janus
author: Mike Perham
layout: post
permalink: /2014/10/15/stupid-go-tricks-in-janus/
categories:
  - Software
---
I&#8217;ve used [Janus][1] as my main text editor for the last few years; it&#8217;s a good solution for people like myself that want to quickly install not just MacVim but also a curated set of plugins necessary to have a productive IDE for Ruby/JS development.

Side note: **learn vim if you&#8217;re a developer and don&#8217;t know it already**. Every Unix environment in the world has vim installed. Learning vim is an excellent investment of your time and ensures you can be productive everywhere, not just your own machine.

The Janus developers recently added a better Go plugin and I wanted to call out a few features that are really cool. Put these lines in your ~/.vimrc.after:

<pre class="brush: plain; gutter: false; title: ; notranslate" title="">au FileType go nmap &lt;leader&gt;c &lt;Plug&gt;(go-coverage)
au FileType go nmap gd &lt;Plug&gt;(go-def)
au FileType go nmap &lt;Leader&gt;r &lt;Plug&gt;(go-rename)
</pre>

1.  Typing &#8220;\c&#8221; will open an HTML code coverage report in your browser for the current package showing test coverage.
2.  Typing &#8220;gd&#8221; will &#8220;goto definition&#8221; of the word under the cursor, allowing you to jump to methods or types.
3.  Typing &#8220;\r&#8221; will rename the thing under the cursor. Real, type-safe renaming in vim, awesome!

Go&#8217;s static type system can be cumbersome at times but does allow automatic refactoring within editors. I&#8217;m happy to see these theoretical benefits finally trickle down to improve my daily work.

 [1]: https://github.com/carlhuda/janus/
---
title: Ruby, Rails and XFDL
author: Mike Perham
layout: post
permalink: /2008/03/05/ruby-rails-and-xfdl/
categories:
  - Ruby
---
Brian writes:

> My open-source web application will need to submit information to a URL in IBM xfdl format.  Is this possible with currently available tools?

In a word, absolutely.  There&#8217;s no XFDL &#8220;native&#8221; support that I know of but I&#8217;m guessing that [XFDL][1] is just another XML standard.  In this case, Ruby can create arbitrary XML with the **builder** library.  You should be able to build your XML document with builder and submit it to the website with Ruby&#8217;s standard support for HTTP.  Here&#8217;s a good introduction: <http://www.xml.com/pub/a/2006/01/04/creating-xml-with-ruby-and-builder.html>

Good luck!

 [1]: http://en.wikipedia.org/wiki/Extensible_Forms_Description_Language
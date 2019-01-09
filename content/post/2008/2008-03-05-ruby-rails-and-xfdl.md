---
author: Mike Perham
categories:
- Ruby
date: 2008-03-05T00:00:00Z
title: Ruby, Rails and XFDL
url: /2008/03/05/ruby-rails-and-xfdl/
---

Brian writes:

> My open-source web application will need to submit information to a URL in IBM xfdl format.  Is this possible with currently available tools?

In a word, absolutely.  There's no XFDL "native" support that I know of but I'm guessing that [XFDL][1] is just another XML standard.  In this case, Ruby can create arbitrary XML with the **builder** library.  You should be able to build your XML document with builder and submit it to the website with Ruby's standard support for HTTP.  Here's a good introduction: <http://www.xml.com/pub/a/2006/01/04/creating-xml-with-ruby-and-builder.html>

Good luck!

 [1]: http://en.wikipedia.org/wiki/Extensible_Forms_Description_Language

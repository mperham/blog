---
title: DSLs and XML
author: Mike Perham
layout: post
permalink: /2008/02/09/dsls-and-xml/
keywords:
  - ruby, dsl, xml
categories:
  - Ruby
---
I realize now why XML has become so wildly popular in programming.  If you look in J2EE or .Net, XML files are used everywhere to drive configuration and glue pieces together.  Why?

It&#8217;s because XML is a syntactically acceptable way to create a DSL without having to derive a grammar!

You can&#8217;t use Java to do configuration &#8211; the syntax is just too heavyweight.  But XML is just tags and the languages have built-in support for parsing the XML via SAX or DOM.  You can create a grammar via XSD or XML Schema but it&#8217;s not required.  XML really offers the lowest barrier to entry for most languages when creating your own DSL.

This is why Ruby rarely, if ever, uses XML.  There&#8217;s no point as the language can create syntactically clean DSLs without requiring a separate grammar.
---
author: Mike Perham
categories:
- Ruby
date: 2008-02-09T00:00:00Z
keywords:
- ruby, dsl, xml
title: DSLs and XML
url: /2008/02/09/dsls-and-xml/
---

I realize now why XML has become so wildly popular in programming.  If you look in J2EE or .Net, XML files are used everywhere to drive configuration and glue pieces together.  Why?

It's because XML is a syntactically acceptable way to create a DSL without having to derive a grammar!

You can't use Java to do configuration -- the syntax is just too heavyweight.  But XML is just tags and the languages have built-in support for parsing the XML via SAX or DOM.  You can create a grammar via XSD or XML Schema but it's not required.  XML really offers the lowest barrier to entry for most languages when creating your own DSL.

This is why Ruby rarely, if ever, uses XML.  There's no point as the language can create syntactically clean DSLs without requiring a separate grammar.

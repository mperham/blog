---
author: Mike Perham
categories:
- Ruby
date: 2007-12-09T00:00:00Z
title: Using Berkeley DB with Ruby
url: /2007/12/09/using-berkeley-db-with-ruby/
---

I've been going very deep into BDB recently.  There's a couple things I've learned:

1.  The Ruby binding effectively only allows you to store strings, not native types.  So that 4 byte integer will instead take anywhere from 1-10 bytes, depending on the value.
2.  The Ruby binding does support sorting via a Ruby proc but it's extremely slow.  Where possible, try to structure your data such that the default lexical sorting can be used.  Fortunately the limitation in (1) works in your favor here since integers don't sort correctly when using lexical sorting on LSB architectures like the i386.
3.  Being able to tune the data structures and transaction semantics based on your particular needs can lead to some enormous performance benefits.  Enabling the DB\_TXN\_NOSYNC flag means you lose the D property in ACID but you get an order of magnitude performance boost from it.  In our case it's not vital and therefore immediately boosts BDB well past RDBMSes in write performance.

I did find one or two bugs in the Ruby binding which should be fixed in the next release.  Guy  has provided quick and knowledgable support for the binding, so despite the lack of community resources for it, I'm confident we can make it work for us.

Any other tips or tricks from others?

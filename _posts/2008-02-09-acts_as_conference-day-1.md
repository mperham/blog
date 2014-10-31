---
title: acts_as_conference Day 1
author: Mike Perham
layout: post
permalink: /2008/02/09/acts_as_conference-day-1/
keywords:
  - ruby, acts_as_conference
categories:
  - Ruby
---
Got here right in time, checked in at 12:30pm, conference started at 1pm.  The conference kicked off in a great way with a good talk from Neal Ford from ThoughtWorks on DSLs.  Do you know the difference between an internal vs external DSL?  I didn&#8217;t.  Internal DSLs are implemented in another existing language and that&#8217;s most of what you see in the Ruby world since Ruby makes it quite easy to build a clean DSL using the raw Ruby language.  External DSLs are parsed using a grammar into an intermediate format to be executed by another language.  Antlr or JavaCC would be used to create external DSLs.

Drank some beer and met some folks in the evening.  I talked with Bradley Taylor from RailsMachine about our service deployment and got some good advice on how to scale our database (he&#8217;s a big proponent of application-level sharding and it&#8217;s looking more and more like we might use this pattern to scale to thousands of customers).
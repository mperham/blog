---
author: Mike Perham
categories:
- Software
date: 2010-02-18T00:00:00Z
title: Changelog vs Commitlog
url: /2010/02/18/changelog-vs-commitlog/
---

One of the things I really like about some software projects is when they provide an actual changelog or release notes. RabbitMQ released 1.7.2 the other day and I asked the developers if they could link to a changelog. They pointed me to [this page][1]. Unfortunately this is not exactly what I had in mind. To me, a changelog is a brief overview of the changes in a version *that is digestible by the end user*. The key factor is that a changelog is not machine-generated but written by a project developer for the project's users. The RabbitMQ changelog is far too verbose (one entry per commit, along with merge noise).

Here's a few examples of good changelogs: [memcache-client][2], [Java][3], [Nokogiri][4], [Resque][5], [Redis][6].

Personally I consider a changelog one of the best indicators of a well run OSS project. If you run an OSS project, please consider supplying release notes or a changelog so that other developers can follow your project with ease!

Update: looks like I just missed the changelog for RabbitMQ. Alexis was kind enough to point me to the release notes in the comments.

 [1]: http://hg.rabbitmq.com/rabbitmq-server/log
 [2]: http://github.com/mperham/memcache-client/blob/master/History.rdoc
 [3]: http://java.sun.com/javase/6/webnotes/6u18.html
 [4]: http://github.com/tenderlove/nokogiri/blob/master/CHANGELOG.rdoc
 [5]: http://github.com/defunkt/resque/blob/master/HISTORY.md
 [6]: http://code.google.com/p/redis/wiki/Redis_1_2_0_Changelog

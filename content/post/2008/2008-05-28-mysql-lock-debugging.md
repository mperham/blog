---
author: Mike Perham
categories:
- Rails
date: 2008-05-28T00:00:00Z
title: MySQL lock debugging
url: /2008/05/28/mysql-lock-debugging/
---

I submitted my first Rails patch this weekend. We've been seeing occasional lock contention, timeout and deadlock in our mysql database but without SHOW INNODB STATUS at the time of the error, it's difficult to track down the cause of the contention. So I added lock error logging to ActiveRecord's MysqlAdapter class. It was also good to learn the patch submission process as I'm sure this will be just one of many.

<http://rails.lighthouseapp.com/projects/8994/tickets/250-mysql-deadlock-debugging>

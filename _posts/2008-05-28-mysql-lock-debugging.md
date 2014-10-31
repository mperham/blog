---
title: MySQL lock debugging
author: Mike Perham
layout: post
permalink: /2008/05/28/mysql-lock-debugging/
categories:
  - Rails
---
I submitted my first Rails patch this weekend. We&#8217;ve been seeing occasional lock contention, timeout and deadlock in our mysql database but without SHOW INNODB STATUS at the time of the error, it&#8217;s difficult to track down the cause of the contention. So I added lock error logging to ActiveRecord&#8217;s MysqlAdapter class. It was also good to learn the patch submission process as I&#8217;m sure this will be just one of many.

<http://rails.lighthouseapp.com/projects/8994/tickets/250-mysql-deadlock-debugging>
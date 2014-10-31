---
title: Bulk Import
author: Mike Perham
layout: post
permalink: /2008/09/11/bulk-import/
categories:
  - Rails
---
Some quick performance numbers around bulk insert of data into MySQL.  This test inserts 1000 rows into a table.  Rails 2.1.0, ar-extensions 0.8.0 and MySQL 5.0.45 on a MacBook Pro running Leopard.  I tested a number of configurations but the interesting ones are plain old iteration calling save, using ar-extensions&#8217; import method and bare metal execute.

*   @objects.each { |obj| obj.save! } **3.417227 sec**
*   Metric.import(@objects) **1.374610 sec**
*   Metric.import(@objects, :validate => false)** 0.488830 sec**
*   Metric.connection.execute(stmt)** 0.033689 sec**

So the DB driver only takes 3/100s of a second to do the actual insert and return.  Generating a multi-insert statement properly takes almost a half-second.  Proper validation adds almost another second of overhead.  Dumb iteration is slowest of all, due to the repeated round trips to the database.

As a side note, 50% of the overhead in generating the multi-insert statement comes from the DB adapter&#8217;s quote method.  It&#8217;s too bad Rails can&#8217;t enforce a convention of &#8220;all identifiers must be database-safe&#8221; so quoting isn&#8217;t so heavyweight.
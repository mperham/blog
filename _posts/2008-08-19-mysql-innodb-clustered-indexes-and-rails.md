---
title: MySQL InnoDB Clustered Indexes and Rails
author: Mike Perham
layout: post
permalink: /2008/08/19/mysql-innodb-clustered-indexes-and-rails/
categories:
  - Software
---
Joe has written an excellent post about one of the more arcane scalability changes you can make to your ActiveRecord schema.  In essence, the performance problem is this: mysql tries to write rows in order of the primary key index and ActiveRecord creates an artificial PK called ID.  So if I write rows #19 and #20, they will be right next to each other on disk, which is fine if 19 and 20 are related.  If they have no relation, their proximity is useless.

In practice, this is not a big problem for most tables.  Where it becomes an issue is with tables having millions of rows where looking for 5000 rows might mean 5000 seeks of a disk head, or 10 seconds of wall clock time.  These seeks are necessary because we aren&#8217;t looking for rows based on ID but rather based on some other application criteria.

Instead what we need to do is make sure MySQL uses a composite key which is related to the WHERE clause we will use to query the rows.  In the case of FiveRuns, we collect metric data from many different clients and write those values to a table.  Since the clients report constantly, row #100 might be for client #1 and row #101 might be for client #2.  But realize that when we fetch the data, we always add &#8220;WHERE client_id = 2&#8243; to our metric data query.  So what we need to do is create a [composite primary key][1] based the constraints we use frequently: (client\_id, metric\_id, collected_at).  Now MySQL will use a clustered index for those columns so that *the rows for each client and metric will be clustered together on disk*.  What was potentially 5000 disk seeks before might now be 5 disk seeks.

As I said before, this is an advanced tweak &#8211; ActiveRecord does not like not having an ID column &#8211; and really only justified if you have millions and millions of rows and a predictable set of constraints.  But if you do, reworking your table&#8217;s primary key to be application-specific and not artifical can provide tremendous performance benefits.

[Joe Hruska.com » MySQL InnoDB Clustered Indexes and Rails][2]

 [1]: http://compositekeys.rubyforge.org/
 [2]: http://www.joehruska.com/?p=6
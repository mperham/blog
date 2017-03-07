---
author: Mike Perham
categories:
- Software
date: 2012-03-02T00:00:00Z
title: Deleting Duplicate Rows in MySQL
url: /2012/03/02/deleting-duplicate-rows-in-mysql/
---

You have a table with duplicate rows -- somehow a unique index didn't get created and a bug has added duplicate records to your table. A pox upon that bug!

Here's two easy ways to clean out that table quickly.

1) Use ALTER IGNORE on MySQL 5.1+

MySQL will allow you to create a unique index on a table with duplicate records with its IGNORE SQL extension:

<pre lang="sql">
ALTER IGNORE TABLE 'SHIPMENTS' ADD UNIQUE INDEX (CART_ID, TRACKING_NUMBER)
</pre>

Duplicates will be deleted. ALTER IGNORE does not normally work in Percona because of their InnoDB fast index creation feature but if you "set session old\_alter\_table=1" beforehand, Percona will use the old alter table behavior.

2) Recreate the table with GROUP BY

<pre lang="ruby">
execute 'CREATE TABLE shipments_deduped like shipments;'
execute 'INSERT shipments_deduped SELECT * FROM shipments GROUP BY cart_id, tracking_number;'
execute 'RENAME TABLE shipments TO shipments_with_dupes;'
execute 'RENAME TABLE shipments_deduped TO shipments;'
add_index :shipments, [:cart_id, :tracking_number], :unique => true
execute 'DROP TABLE shipments_with_dupes;'
</pre>

Recreating the table is much, much faster than trying to delete the records in the existing table and doesn't lock the existing table, making your application downtime minimal. This method will not work if MySQL's sql\_mode includes ONLY\_FULL\_GROUP\_BY.

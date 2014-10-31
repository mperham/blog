---
title: Setting MySQL DATETIME column defaults in Rails
author: Mike Perham
layout: post
permalink: /2014/05/17/setting-mysql-datetime-column-defaults-in-rails/
categories:
  - Rails
---
[Starting in MySQL 5.6.5][1], datetime columns can have an actual useful default of CURRENT\_TIMESTAMP and MySQL will auto-populate the columns as necessary. This is incredibly handy if you ever do bulk updates in SQL, now you don&#8217;t need to remember to set updated\_at! Inserting records manually will auto-populate those columns too. Let&#8217;s try it:

<pre class="brush: ruby; gutter: false; title: ; notranslate" title="">def up
  create_table :rows do |t|
    t.integer :value
    t.datetime :created_at, null: false, default: "CURRENT_TIMESTAMP"
    t.datetime :updated_at, null: false, default: "CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"
  end
end
</pre>

Run that and we&#8217;ll see this:

<pre class="brush: plain; title: ; notranslate" title="">ActiveRecord::StatementInvalid: Mysql2::Error: Invalid default value for &#039;created_at&#039;: CREATE TABLE `rows` (`id` int(11) DEFAULT NULL auto_increment PRIMARY KEY, `value` int(11) NULL, `created_at` datetime DEFAULT &#039;CURRENT_TIMESTAMP&#039; NOT NULL, `updated_at` datetime DEFAULT &#039;CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP&#039; NOT NULL) ENGINE=InnoDB
</pre>

Notice that Rails quotes the default value, making it invalid. We can bypass this by using a custom type to define all the special logic we need and use the generic `column` definition method:

<pre class="brush: ruby; gutter: false; title: ; notranslate" title="">CREATE_TIMESTAMP = 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP'
UPDATE_TIMESTAMP = 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'

def up
  create_table :rows do |t|
    t.integer :value
    t.column :created_at, CREATE_TIMESTAMP
    t.column :updated_at, UPDATE_TIMESTAMP
   end
end
</pre>

**Big Caveat**: you must make sure your database&#8217;s timezone is set correctly. MySQL defaults to the system&#8217;s timezone and we set our system timezone to Pacific so everything should work fine for us.

<pre class="brush: sql; title: ; notranslate" title="">$ mysql
mysql&gt; select @@time_zone;
+-------------+
| @@time_zone |
+-------------+
| SYSTEM      |
+-------------+
</pre>

Defined like that, those columns will be populated and updated any time rows are touched, not just when Rails does it.

 [1]: https://dev.mysql.com/doc/refman/5.6/en/timestamp-initialization.html
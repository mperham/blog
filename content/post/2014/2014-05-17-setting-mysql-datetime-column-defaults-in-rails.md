---
author: Mike Perham
categories:
- Rails
date: 2014-05-17T00:00:00Z
title: Setting MySQL DATETIME column defaults in Rails
url: /2014/05/17/setting-mysql-datetime-column-defaults-in-rails/
---

[Starting in MySQL 5.6.5][1], datetime columns can have an actual useful default of CURRENT\_TIMESTAMP and MySQL will auto-populate the columns as necessary. This is incredibly handy if you ever do bulk updates in SQL, now you don't need to remember to set updated\_at! Inserting records manually will auto-populate those columns too. Let's try it:

```ruby
def up
  create_table :rows do |t|
    t.integer :value
    t.datetime :created_at, null: false, default: "CURRENT_TIMESTAMP"
    t.datetime :updated_at, null: false, default: "CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"
  end
end
```

Run that and we'll see this:

```
ActiveRecord::StatementInvalid: Mysql2::Error: Invalid default value for 'created_at': CREATE TABLE `rows` (`id` int(11) DEFAULT NULL auto_increment PRIMARY KEY, `value` int(11) NULL, `created_at` datetime DEFAULT 'CURRENT_TIMESTAMP' NOT NULL, `updated_at` datetime DEFAULT 'CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP' NOT NULL) ENGINE=InnoDB
```

Notice that Rails quotes the default value, making it invalid. We can bypass this by using a custom type to define all the special logic we need and use the generic `column` definition method:

```
CREATE_TIMESTAMP = 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP'
UPDATE_TIMESTAMP = 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'

def up
  create_table :rows do |t|
    t.integer :value
    t.column :created_at, CREATE_TIMESTAMP
    t.column :updated_at, UPDATE_TIMESTAMP
   end
end
```

**Big Caveat**: you must make sure your database's timezone is set correctly. MySQL defaults to the system's timezone and we set our system timezone to Pacific so everything should work fine for us.

```
$ mysql
mysql> select @@time_zone;
+-------------+
| @@time_zone |
+-------------+
| SYSTEM      |
+-------------+
```

Defined like that, those columns will be populated and updated any time rows are touched, not just when Rails does it.

 [1]: https://dev.mysql.com/doc/refman/5.6/en/timestamp-initialization.html

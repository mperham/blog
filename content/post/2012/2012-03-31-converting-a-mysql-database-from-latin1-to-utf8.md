---
author: Mike Perham
categories:
- Rails
date: 2012-03-31T00:00:00Z
title: Converting a MySQL database from Latin1 to UTF8
url: /2012/03/31/converting-a-mysql-database-from-latin1-to-utf8/
---

We had a problem at [TheClymb][1]: our database and tables were created with the default Latin1 encoding. Now all of the data in those tables is actually UTF8 because it was all imported via the web browser (which defaults to UTF8) and MySQL doesn't actually validate or convert data encoding when inserting.

A suggestion was to just set this in an initializer:

{{< highlight ruby >}}
Mysql2::Client::CHARSET_MAP['latin1'] = Encoding::UTF_8
{{< / highlight >}}

This will solve your problems in Ruby but will not solve your problems in the database: MySQL will still sort and compare strings thinking they are latin1 and thus do so incorrectly. Here's an example:

{{< highlight sql >}}
create table names_latin1 (name varchar(32) character set latin1);
insert into names_latin1 values ('Martin Strauße');
insert into names_latin1 values ('Martin Straure');
insert into names_latin1 values ('Martin Strausse');
insert into names_latin1 values ('Martin Straute');

create table names_utf8 (name varchar(32) character set utf8);
insert into names_utf8 values ('Martin Strauße');
insert into names_utf8 values ('Martin Straure');
insert into names_utf8 values ('Martin Strausse');
insert into names_utf8 values ('Martin Straute');
{{< / highlight >}}

I'm not a linguist but to the best of my knowledge the German ß is essentially "ss". When we ask MySQL to sort our names, you can see that the UTF-8 results put the ß character between "r" and "ss" but the Latin1 results don't. If a German were to see this, they would be enraged due to your culturally insensitive code!

<pre>
> select * from names_latin1 order by name;
+-----------------+
| name            |
+-----------------+
| Martin Straure  |
| Martin Strausse |
| Martin Straute  |
| Martin Strauße  |
+-----------------+
</pre>

<pre>
> select * from names_utf8 order by name;
+-----------------+
| name            |
+-----------------+
| Martin Straure  |
| Martin Strauße  |
| Martin Strausse |
| Martin Straute  |
+-----------------+
</pre>

We need to update the CHARACTER SET without doing any conversion of the data. This is simple to do: you convert the columns to a blob format and then convert them back to a string format with the proper encoding declared; MySQL will not do any conversion of raw binary data. For example:

{{< highlight sql >}}
ALTER TABLE categories CHARACTER SET utf8 COLLATE utf8_unicode_ci, CHANGE title title VARBINARY(255)
ALTER TABLE categories CHANGE title title VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci
{{< / highlight >}}

With this in mind, I wrote a rake task to convert our application's database. Here's the full script in a [Github Gist][2]. You'll need to run it with a `DOIT` parameter to actually make the changes otherwise it will just print the SQL it will run to the terminal. The script will take a long time for large databases since it has to ALTER TABLE, which means MySQL will write out the table to disk in full; the script does minimize the number of ALTER TABLEs it runs to two per table.
`rake convert_to_utf8 DOIT=1`

So please think of the Germans and the rest of our international friends: converting the character set of your database to the proper value is important to get correct sorting of results.

 [1]: http://www.theclymb.com/invite-from/mperham
 [2]: https://gist.github.com/2045565

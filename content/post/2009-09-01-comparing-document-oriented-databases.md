---
author: Mike Perham
categories:
- Software
date: 2009-09-01T00:00:00Z
title: Comparing Document-oriented Databases
url: /2009/09/01/comparing-document-oriented-databases/
---

[MongoDB][1] is a relatively new "schema-free, document-oriented database." The closest competitor to MongoDB is probably [CouchDB][2] or [Tokyo Cabinet's Table database][3] but all three differ in significant ways:

*   CouchDB guarantees the ACID properties when saving documents through an MVCC mechanism like postgresql. Tokyo Cabinet provides ACID support via locking, like mysql.  Mongo updates documents in place with no real support for concurrency (e.g. optimistic or pessimistic locking). This means Mongo will be much faster for writing and scale horizontally very easily at the expense of guaranteed data consistency. This is a very common tradeoff.
*   Couch and Mongo support datatypes for the values in documents but Mongo uses a binary JSON representation and protocol which makes it faster over the wire. Tokyo Cabinet does not support datatypes, except for string and number types in indexes. It does not have native boolean and date types which means you can't efficiently do queries like "created_at < 1 week ago" although you could store dates and booleans as numbers to work around this limitation.
*   Couch and Mongo support more complex structures (arrays, hashes) as values.  Tokyo only supports basic datatypes.
*   Couch requires you to instantiate views for the queries required by your application. Couch will then auto-index the data required to fetch the view. Tokyo Cabinet and Mongo have a more traditional RDBMS notion of indexes, which are maintained separately from the table.
*   CouchDB is written in Erlang while MongoDB is written in C++ and Tokyo Cabinet in C. I'm inclined to trust Erlang more for distributed infrastructure, given its long history in telecom. That said, I have no evidence that the other two are anything but rock solid.

All projects are interesting takes on the traditional RDBMS datastore.  CouchDB would be useful where you absolutely must keep ACID and transactions to ensure data integrity but want to avoid the hard-coded schema that a traditional database requires.  Semantic web applications come to mind where your objects are just a bag of attributes.

MongoDB would seem to be more designed for applications which need dynamic query functionality with high performance and can sacrifice data integrity to get it -- metrics and operational data come to mind.  As the MongoDB website says: "High volume, low value data".

Tokyo Cabinet feels a little more traditional and lower-level, like a layer on top of BerkeleyDB.  It's similar in design in that they are both C libraries and not designed to run as standalone daemons themselves.  It would be great for embedded applications.

In my next post, I'll try out each with their latest Ruby driver and see how they perform in basic usecases.  Did I get anything wrong?  Leave a comment and let me know!

Update: Tokyo Tyrant does not appear to support transactions and so Tokyo Cabinet cannot guarantee ACID when used as a service.

 [1]: http://www.mongodb.org/display/DOCS/Home
 [2]: http://couchdb.apache.org/
 [3]: http://tokyocabinet.sourceforge.net/spex-en.html#features

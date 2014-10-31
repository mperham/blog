---
title: 'Document-oriented Database Shootout Part 2: Performance'
author: Mike Perham
layout: post
permalink: /2009/10/16/document-oriented-database-shootout-part-2-performance/
categories:
  - Software
---
After talking about document-oriented databases in general in [Part 1][1], for Part 2 I&#8217;ve written some code comparing MongDB 1.1.1, CouchDBX 0.9.1 and Tokyo Tyrant 1.4.32 in an apples to apples test.

[<img src="http://www.mikeperham.com/wp-content/uploads/2009/10/mongodb.png" alt="mongodb" title="mongodb" width="200" height="61" class="" />][2]&nbsp;[<img src="http://www.mikeperham.com/wp-content/uploads/2009/10/couchdb-logo2.png" alt="couchdb-logo" title="couchdb-logo" width="200" height="64" class="" />][3]

The [shootout code is on Github][4]. I welcome patches and improvements as long as they don&#8217;t bias the tests in favor of any one system.

**Results**  
`<br />
========== Running Tokyo Tyrant tests<br />
Using rufus-tokyo 1.0.0<br />
                user     system      total        real<br />
init        0.000000   0.000000   0.000000 (  0.013781)<br />
create     19.770000   4.260000  24.030000 ( 39.982273)<br />
query       0.160000   0.030000   0.190000 (  0.318070)<br />
delete      0.000000   0.000000   0.000000 (  0.421201)</p>
<p>========== Running MongoDB tests<br />
Using mongo + mongo_ext 0.15.1<br />
                user     system      total        real<br />
init        0.000000   0.000000   0.000000 (  0.005074)<br />
create     54.710000   1.750000  56.460000 ( 57.358498)<br />
query       0.120000   0.010000   0.130000 (  0.155486)<br />
delete      0.000000   0.000000   0.000000 (  0.957453)</p>
<p>========== Running CouchDB tests<br />
Using jchris-couchrest 0.23<br />
                user     system      total        real<br />
init        0.000000   0.000000   0.000000 (  0.000007)<br />
create      9.290000   0.560000   9.850000 ( 51.177824)<br />
`

**init** is the time required to initialize the database and create any necessary indices. In practice, this number isn&#8217;t terribly relevant as this is usually an infrequent operation.

The **create** operation shows how long it takes for the system to bulk load 200,000 documents. You can see that Tokyo is quite fast while the Mongo client hits the CPU pretty hard. The couchrest client seems more efficient than the other two but the task still takes longer than Tokyo.

The **query** operation shows how long it takes to perform a non-trivial query against those 200k documents. Both Mongo and Tokyo perform about the same speed although Mongo lazy fetches the results in order to minimize network traffic when used with pagination. Tokyo returns the entire result at once AFAIK. I was not able to complete this test in a weekend using CouchDB because its view layer is so alien to me. I&#8217;d welcome help with this task.

The **delete** operation tests the time required to delete a subset of documents within our set of 200,000. Again, Tokyo comes out on top. Since I couldn&#8217;t perform the query in CouchDB I couldn&#8217;t delete anything either.

Conclusions? Tokyo has a reputation for being very fast and it appears to be well-founded. Couch is fast for what I could get working &#8211; I would be much more concerned about developer training and learning curve with Couch. Mongo is by no means slow but someone has to finish last. I like Mongo as an interesting mix of RDBMS and document technologies &#8211; it&#8217;s not quite as conventional as Tokyo but not as unconventional as CouchDB with its unique view layer and Erlang underpinnings. What do you think? Leave a comment and let me know!

 [1]: http://www.mikeperham.com/2009/09/01/comparing-document-oriented-databases/
 [2]: http://www.mongodb.org
 [3]: http://couchdb.apache.org
 [4]: http://github.com/mperham/docdb_shootout
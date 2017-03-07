---
author: Mike Perham
categories:
- Ruby
date: 2007-12-19T00:00:00Z
title: 'BDB: The Conclusion'
url: /2007/12/19/bdb-the-conclusion/
---

We gave up on using Berkeley DB for our metric store. There were just too few advantages over a higher-level solution like MySQL. BDB doesn't have:

*   A notion of schema or data types
*   A query language
*   Slick integration into Ruby

In the end it would have taken a LOT of manpower to wrap and tune BDB to work more efficiently than MySQL and we would have had a very complex proprietary system to maintain. MySQL simply provides a more standard system which more people understand.

It's definitely a winner for embedded solutions with simple schema requirements but the implementation complexity grows as O(n^2) with the size of the schema in my estimation.

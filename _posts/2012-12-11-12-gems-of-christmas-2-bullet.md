---
title: '12 Gems of Christmas #2 &#8211; bullet'
author: Mike Perham
layout: post
permalink: /2012/12/11/12-gems-of-christmas-2-bullet/
categories:
  - Rails
---
ActiveRecord has been a huge boon for web development in promoting conventions in databases. Every new company I joined we had to determine how to name tables, primary keys and indexes. Standardizing id, automatic timestamps, pluralizing nouns, all of it makes development easier and more friendly to developers who just want to build stuff, not worry about every mundane detail.

All is not wine and roses though, ActiveRecord suffers from a common ORM performance issue: the N+1 query problem. Find all shopping carts created in the last month and print out the number of items in those carts. This is what you might see in your terminal:

<pre lang="sql">select * from shopping_carts where created_at > 1.month.ago
select count(*) from shopping_cart_items where shopping_cart_id = 111
select count(*) from shopping_cart_items where shopping_cart_id = 222
select count(*) from shopping_cart_items where shopping_cart_id = 333
select count(*) from shopping_cart_items where shopping_cart_id = 444
select count(*) from shopping_cart_items where shopping_cart_id = 555
...
</pre>

This is because the initial query loads the data associated with the shopping_carts but does not load the associated items. As you iterate through each cart, Rails lazy loads the item count; unfortunately it does it one cart at a time.

Enter [bullet][1] which aims to help you find and fix any N+1 query issues in your ActiveRecord code. Add it to your Gemfile and activate it in your Rails configuration, soon you&#8217;ll see warnings like this:

<pre>Unused Eager Loading detected
  Brand => [:products]
  Remove from your finder: :include => [:products]
</pre>

As we learned when we were younger, knowing is half the problem. These performance problems should be easy to track down and tune now that you know about the problem; you&#8217;ll find your page rendering times plummet since the number of database queries performed will drop dramatically.

Tomorrow we&#8217;ll discuss my favorite subject, concurrency, and unveil the #1 gem!

 [1]: https://github.com/flyerhzm/bullet
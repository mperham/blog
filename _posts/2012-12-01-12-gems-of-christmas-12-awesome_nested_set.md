---
title: '12 Gems of Christmas #12 &#8211; awesome_nested_set'
author: Mike Perham
layout: post
permalink: /2012/12/01/12-gems-of-christmas-12-awesome_nested_set/
categories:
  - Ruby
---
Category trees are standard e-commerce functionality, allowing the user to filter their results when searching for products. Here&#8217;s a category tree from Amazon.com:

[<img src="http://www.mikeperham.com/wp-content/uploads/2012/11/Screen-Shot-2012-11-19-at-7.59.46-PM.png" alt="" title="Screen Shot 2012-11-19 at 7.59.46 PM" width="197" height="208" class="alignleft size-full wp-image-941" />][1]

So if you have a table which holds those categories, how do you write a SQL query which loads a given category PLUS all child categories below it? The answer is that it&#8217;s extremely difficult/impossible with standard SQL. Oracle can do it with their SQL &#8220;connect by&#8221; extension or you can change your tree structure into a [nested set][2].

The [awesome\_nested\_set][3] gem adds really useful tree functionality to your category table. Need to query for all products in a given category or below in the category tree?

<pre lang="ruby">class Category &lt; ActiveRecord::Base
  acts_as_nested_set
  has_many :products
  belongs_to :parent, :class_name => 'Category'
  attr_accessible :name, :parent_id, :parent
end

class Product &lt; ActiveRecord::Base
  belongs_to :category
  attr_accessible :category_id, :name, :category
end

cat = Category.find_by_name("Electronics")
# look up all children in one query
subcats = cat.self_and_descendants

# Find all products within Electronics subtree with one query.
# A bit messy.
products = Product.active.joins(:category).where('categories.lft > ? and categories.lft &lt;= ?', cat.lft, cat.rgt)
</pre>

awesome\_nested\_set is missing some critical documentation, the README explains how to set it up but doesn't cover queries and scopes at all. I couldn't find a way to do something cleaner like so without rolling my own scope:

<pre lang="ruby">cat = Category.find_by_name("Electronics")
products = Product.active.within_category(cat)
</pre>

Is this possible? Could the category association provide some built-in nested set scopes? Nevertheless, adding a few custom scopes is a small price to pay: nested sets turn a very hard SQL problem into something easily solved.

UPDATE: I learned of two nice alternatives to awesome\_nested\_set: [ancestry][4] and [closure_tree][5].

Tomorrow I'll show you a great little gem for adding metrics to your Ruby code.

 [1]: http://www.mikeperham.com/wp-content/uploads/2012/11/Screen-Shot-2012-11-19-at-7.59.46-PM.png
 [2]: https://en.wikipedia.org/wiki/Nested_set_model "nested set"
 [3]: https://github.com/collectiveidea/awesome_nested_set "awesome_nested_set"
 [4]: https://github.com/stefankroes/ancestry
 [5]: https://github.com/mceachen/closure_tree
---
title: '12 Gems of Christmas #10 &#8211; konacha'
author: Mike Perham
layout: post
permalink: /2012/12/03/12-gems-of-christmas-10-konacha/
categories:
  - Rails
---
It&#8217;s got a crazy name but solves a serious problem that continues to vex the Rails community: javascript testing. There are a number of libraries out there that try to solve the problem but [konacha][1] is the first I&#8217;m aware of that integrates tightly with Rails 3 and Sprockets to make JavaScript testing as easy as possible within your Rails app. For instance, you might have `spec/javascripts/array_sum_spec.js`:

<pre lang="javascript">//= require array_sum

describe("Array#sum", function() {
  it("returns 0 when the Array is empty", function() {
    [].sum().should.equal(0);
  });

  it("returns the sum of numeric elements", function() {
    [1,2,3].sum().should.equal(6);
  });
});
</pre>

You can load HTML template fixtures via Sprocket&#8217;s JS template support. For example, in `spec/javascripts/templates/hello.jst.ejs`:

<pre lang="html"><h1>
  Hello Konacha!
</h1>
</pre>

And your spec:

<pre lang="javascript">//= require_tree ./templates

describe("templating", function() {
  it("is built in to Sprockets", function() {
    $('body').html(JST['templates/hello']());
    $('body h1').text().should.equal('Hello Konacha!');
  });
});
</pre>

I&#8217;m really impressed by the quality of code and documentation here. Kudos to John Firebaugh and his contributors! Next time you write some JavaScript, take a look at Konacha and see if it can help you test that code automatically.

Tomorrow we&#8217;ll take a look at a brand new gem with a fresh take on authorization.

 [1]: https://github.com/jfirebaugh/konacha
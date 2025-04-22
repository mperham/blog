---
author: Mike Perham
categories:
- Rails
date: 2012-12-03T00:00:00Z
title: '12 Gems of Christmas #10 -- konacha'
url: /2012/12/03/12-gems-of-christmas-10-konacha/
---

It's got a crazy name but solves a serious problem that continues to vex the Rails community: javascript testing. There are a number of libraries out there that try to solve the problem but [konacha][1] is the first I'm aware of that integrates tightly with Rails 3 and Sprockets to make JavaScript testing as easy as possible within your Rails app. For instance, you might have `spec/javascripts/array_sum_spec.js`:

```
//= require array_sum

describe("Array#sum", function() {
  it("returns 0 when the Array is empty", function() {
    [].sum().should.equal(0);
  });

  it("returns the sum of numeric elements", function() {
    [1,2,3].sum().should.equal(6);
  });
});
```

You can load HTML template fixtures via Sprocket's JS template support. For example, in `spec/javascripts/templates/hello.jst.ejs`:

```
<h1>
  Hello Konacha!
</h1>
```

And your spec:

```
//= require_tree ./templates

describe("templating", function() {
  it("is built in to Sprockets", function() {
    $('body').html(JST['templates/hello']());
    $('body h1').text().should.equal('Hello Konacha!');
  });
});
```

I'm really impressed by the quality of code and documentation here. Kudos to John Firebaugh and his contributors! Next time you write some JavaScript, take a look at Konacha and see if it can help you test that code automatically.

Tomorrow we'll take a look at a brand new gem with a fresh take on authorization.

 [1]: https://github.com/jfirebaugh/konacha

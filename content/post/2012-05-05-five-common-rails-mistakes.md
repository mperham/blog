---
author: Mike Perham
categories:
- Rails
- Ruby
date: 2012-05-05T00:00:00Z
title: Five Common Rails Mistakes
url: /2012/05/05/five-common-rails-mistakes/
---

I've worked with Rails for quite a while now and in that time I've seen a lot of Rails applications and both read and written a lot of bad Ruby code. Here's five common mistakes that I see in almost every Rails codebase.  
<!--more-->

**1. Migrations with no schema specifics**

Your data model is the core of your application. Without schema constraints, your data will slowly corrode due to bugs in your codebase until you can't depend on any fields being populated. Here's a Contact schema:

{{< highlight ruby >}}
create_table "contacts" do |t|
  t.integer  "user_id"
  t.string   "name"
  t.string   "phone"
  t.string   "email"
end
{{< / highlight >}}

What is required? Presumably a Contact must belong_to a User and have a name &mdash; use database constraints to guarantee this. By adding `:null => false`, we ensure that the model is always consistent even if we have bugs in our validation because the database will not allow a model to be saved if it fails those constraints.

{{< highlight ruby >}}
create_table "contacts" do |t|
  t.integer  "user_id", :null => false
  t.string   "name", :null => false
  t.string   "phone"
  t.string   "email"
end
{{< / highlight >}}

**Bonus points**: use `:limit => N` to size your string columns appropriately. Strings default to 255 characters and phone probably doesn't need to be that big, does it?

**2. Object-Oriented Programming**

Most Rails developers do not write object-oriented Ruby code. They write MVC-oriented Ruby code by putting models and controllers in the expected locations. Most will add utility modules with class-methods in lib/, but that's it. It takes 2-3 years before developers realize: "Rails is just Ruby. I can create simple objects and compose them in ways that Rails does not explicitly endorse!"

**Bonus points**: introduce facades for any 3rd-party services you call. Provide a mock facade for use in your tests so that you don't actually call the 3rd party service in your test suite.

**3. Concatenating HTML in helpers**

If you are creating helper methods, kudos, at least you trying to keep your view layer clean. But developers often don't know the basics of creating tags within helpers, leading to messy string concatenation or interpolation:

{{< highlight ruby >}}
str = "<li class='vehicle_list'>"
str += link_to("#{vehicle.title.upcase} Sale", show_all_styles_path(vehicle.id, vehicle.url_title))
str += "</li>"
str.html_safe
{{< / highlight >}}

Yikes, it's ugly and can easily lead to XSS security holes! `content_tag` is your friend.

{{< highlight ruby >}}
content_tag :li, :class => 'vehicle_list' do
  link_to("#{vehicle.title.upcase} Sale", show_all_styles_path(vehicle.id, vehicle.url_title))
end
{{< / highlight >}}

**Bonus points**: start introducing helper methods that take blocks. Nested blocks are a natural fit when generating nested HTML.

**4. Giant queries loading everything into memory**

You need to fix some data so you'll just iterate through it all and fix it, right?

{{< highlight ruby >}}
User.has_purchased(true).each do |customer|
  customer.grant_role(:customer)
end
{{< / highlight >}}

You have an ecommerce site with a million customers. Let's say each User object takes 500 bytes. This code will take 500MB of memory at runtime! Better:

{{< highlight ruby >}}
User.has_purchased(true).find_each do |customer|
  customer.grant_role(:customer)
end
{{< / highlight >}}

`find_each` uses `find_in_batches` to pull in 1000 records at a time, dramatically lowering the runtime memory requirements.

**Bonus points**: use `update_all` or raw SQL to perform the mass update. SQL takes time to learn well but the benefits are even more tremendous: you'll see a 100x improvement in the performance.

**5. Code review!**

I'm guessing you are using GitHub and I'm also guessing you aren't using pull requests. If you spend a day or two building a feature, do it on a branch and send a pull request. Your team will be able to review your code, offer suggestions for improvement and possible edge cases that you didn't consider. I guarantee your code will be higher quality for it. We've switched to using pull requests for 90% of our changes at [TheClymb][1] and it's been a 100% positive experience.

**Bonus points**: Don't merge pull requests without tests for at least the happy path. Testing is invaluable to keep your application stable and your sleep peaceful.

Did I miss any common issues? Leave a comment and let me know!

Update: use `find_each` rather than `find_in_batches`, thanks readers!

 [1]: http://www.theclymb.com/invite-from/mperham

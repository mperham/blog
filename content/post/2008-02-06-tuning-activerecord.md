---
author: Mike Perham
categories:
- Rails
date: 2008-02-06T00:00:00Z
keywords:
- activerecord, performance
title: Tuning ActiveRecord
url: /2008/02/06/tuning-activerecord/
---

We're in the process of building a very database-heavy system to store lots of metric data for our FiveRuns RM-Manage product. We looked at using tools like RRDTool and Berkeley DB but eventually came to the conclusion that a well-tuned mysql instance will work better for the flexibility and ease of maintenance we would like.

So we are using ActiveRecord as our database layer and it does not have a reputation as the speediest of ORM layers but usually that doesn't matter too much. However in this case our system is so heavyweight that tuning ActiveRecord is vital.

After a quick profile with ruby-prof, it looks like we spend a fair amount of time cloning attributes.  Speak of the devil, apparently [this issue has been fixed in Rails Edge][1] so hopefully Rails 2.0.3 will feature this fix.  In the meantime, I rolled my own insert/update statement creation and found that it improved performance by 40-50%!  I could do this because we are inserting large amounts of records and immediately throwing the records away so there is no need to update the model instances in memory.

Still approximately 1/3 of the time is spent just doing string manipulation to create the database statements.  I might try using mysql's multiple insert feature next and see what it can do for me.

 [1]: http://blog.pluron.com/2008/01/ruby-on-rails-i.html

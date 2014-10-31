---
title: Using Fixtures without Rails
author: Mike Perham
layout: post
permalink: /2007/10/30/using-fixtures-without-rails/
keywords:
  - rails, fixtures, ruby
categories:
  - Rails
  - Ruby
---
We&#8217;ve got several applications internal to FiveRuns which are Ruby but not Rails. They use ActiveRecord for database access but not the rest of the Rails stack. We still wanted to use fixtures to provide a foundation of data for our testing though so I spent a few hours figuring out how to get fixtures working in a non-Rails world. In essence you need to add this to your test_helper.rb:  
`<br />
ENV["RAILS_ENV"] = "test"<br />
RAILS_ENV = "test"<br />
require 'rubygems'<br />
require 'test/unit'<br />
require 'active_record'<br />
require 'active_record/fixtures'<br />
filename = File.join(File.dirname(__FILE__), "../config/database.yml")<br />
ActiveRecord::Base.configurations = YAML::load(ERB.new(IO.read(filename)).result)<br />
ActiveRecord::Base.establish_connection<br />
Test::Unit::TestCase.use_instantiated_fixtures = false<br />
Test::Unit::TestCase.use_transactional_fixtures = true<br />
Test::Unit::TestCase.fixture_path = File.join(File.dirname(__FILE__), 'fixtures')<br />
`  
The only Rails-ism you need to copy is the config/database.yml file. The setup above expects your fixtures to live in a &#8220;fixtures&#8221; directory below the test_helper.rb, which is how Rails does it also. The first two lines are hacks so that ActiveRecord will know the current environment without having to pull in the config/environment.rb stuff that Rails uses.

Now in your tests, you can access your fixtures via the standard mechanism:  
`<br />
assert_not_nil accounts(:fiveruns)<br />
`  
Once you have fixtures working, try the [Rathole][1] plugin which makes fixtures even better!

PS Apologies for the miserable formatting.  WordPress really tries too hard to be smart and , as a result, just makes everyone look dumb.

 [1]: http://svn.geeksomnia.com/rathole/trunk/README
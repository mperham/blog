---
author: Mike Perham
categories:
- Rails
date: 2009-03-03T00:00:00Z
title: Using memcache-client 1.6.x in Rails &lt; 2.3
url: /2009/03/03/using-memcache-client-16x-in-rails-23/
---

Jemery Kemper [recently upgraded][1] Rails 2.3's vendored copy of memcache-client to the 1.6.4 release. But what do you do if you are running Rails 2.1/2.2 and want to take advantage of the massive speedup in 1.6.x? You write some really ugly code that performs brain surgery on the Ruby environment to override ActiveSupport. Create `config/initializers/memcache-client-upgrade.rb` with this code:

```ruby
require 'rubygems'

# Brain surgery to use our own version of memcache-client without
# having to modify activesupport directly.
# Unload any previous instance of the class
if Object.const_defined? :MemCache
  Object.instance_eval { remove_const :MemCache }
end
# Pull in the exact version we want
gem 'memcache-client', '1.6.5'
# Ensure that the memcache-client path is at the front of the loadpath
$LOAD_PATH.each do |path|
  if path =~ /memcache-client/
    $LOAD_PATH.delete(path)
    $LOAD_PATH.unshift(path)
  end
end
# If Ruby thinks it's already loaded memcache.rb, force
# a reload otherwise just require.
if $".find { |file| file =~ /Amemcache.rbZ/ }
  load 'memcache.rb'
else
  require 'memcache'
end
```

If someone knows of a cleaner way to do this, please let me know.

 [1]: http://github.com/rails/rails/commit/e56b3e4c0b60b2b86f5ca9c5e5a0b22fa34d37ab

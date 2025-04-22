---
author: Mike Perham
categories:
- Rails
date: 2009-06-13T00:00:00Z
title: Adding multi-get support to Rails
url: /2009/06/13/adding-multi-get-support-to-rails/
---

Memcache-client has the ability to fetch multiple keys in one request but Rails does not expose this functionality. It's really easy to add it yourself though:

**config/initializers/rails_patches.rb**
```ruby
Rails.cache.instance_eval &lt;&lt;-EOM
  def read_multi(*keys)
    @data.get_multi(*keys)
  end
EOM
```

Rails uses read/write for its API naming so we name the method `read_multi` rather than `get_multi`. Here's a sample usage in script/console:

```ruby
>> Rails.cache.write('a', 1)
>> Rails.cache.write('b', 2)
>> Rails.cache.write('c', 3)
>> Rails.cache.read_multi('a', 'b', 'c')
=> {"a"=>1, "b"=>2, "c"=>3}
```

Enjoy!

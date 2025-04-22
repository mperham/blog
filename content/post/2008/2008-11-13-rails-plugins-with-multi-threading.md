---
author: Mike Perham
categories:
- Rails
date: 2008-11-13T00:00:00Z
title: Rails Plugins with Multi-Threading
url: /2008/11/13/rails-plugins-with-multi-threading/
---

I tested [tracknowledge][1] with Rails 2.2 yesterday. The main problem was with plugins: two out of the six I use failed with the same issue when used with threadsafe!

The issue is that ActiveSupport's autoloading is turned off once threadsafe! is executed because autoloading is inherently thread-unsafe. These plugins were not explicitly requiring their classes in init.rb but instead relying on autoloading like so:

**config/environment.rb**:

```ruby
Rails::Initializer.run do |config|
  config.threadsafe!
end
ExceptionNotifier.exception_recipients = %w(mikeATtracknowledge.org)
```

Yes, ExceptionNotifier was one of the broken plugins along with the GeoKit plugin. The fix is simple:

```diff
diff --git a/vendor/plugins/exception_notification/init.rb b/vendor/plugins/exception_notification/init.rb
index b39bd95..b1dd2d9 100644
--- a/vendor/plugins/exception_notification/init.rb
+++ b/vendor/plugins/exception_notification/init.rb
@@ -1 +1,4 @@
 require "action_mailer"
+require 'exception_notifier'
+require 'exception_notifiable'
+require 'exception_notifier_helper'
```

If you maintain a Rails plugin, make sure you verify that all classes are loaded in init.rb or you could very well have problems too.

 [1]: http://www.tracknowledge.org

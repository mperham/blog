---
author: Mike Perham
categories:
- Ruby
date: 2008-01-14T00:00:00Z
title: Conversion to Array
url: /2008/01/14/conversion-to-array/
---

If you want to autobox an object into an Array, Ruby provides a deprecated method, Object#to_a, to do this.  The better, non-deprecated way is to use Array conversion:

```ruby
irb(main):001:0> foo = Object.new
=> #<Object:0x15234>
irb(main):002:0> foo.to_a
(irb):2: warning: default 'to_a' will be obsolete
=> [#<Object:0x15234>]
irb(main):003:0> Array(foo)
=> [#<Object:0x15234>]
irb(main):004:0>  a = Array.new
=> []
irb(main):005:0> Array(a)
=> []
```

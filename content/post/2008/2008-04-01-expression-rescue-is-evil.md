---
author: Mike Perham
categories:
- Ruby
date: 2008-04-01T00:00:00Z
keywords:
- ruby, rescue, expression
title: Expression Rescue is Evil
url: /2008/04/01/expression-rescue-is-evil/
---

One of the cleaner syntax options Ruby gives you is what I call expression rescues.  Take this:  
`<br />
<%= @item.parent.name rescue 'None' %><br />
`  
This code is an example of a pretty standard requirement: printing out the name of the parent of an item. If the item does not have a parent, it will print 'None'. Under the covers, the following is happening:

1.  Ruby calls the parent method on @item
2.  Ruby calls the name method on the result
3.  Since the parent is nil, an 'undefined method \`name' for nil' error will be raised
4.  This error is caught by the rescue clause and the rescue expression evaluated
5.  The result of the rescue expression is returned as the result of the overall expression

So what's the problem? There's several in my experience:

**You often can't tell why the rescue is needed.** In the case above, the usage is straightforward. In other cases, it's much less obvious. Take this code:  
``

<pre>(@client.plugin_configurations.detector.configuration['paths'].inject('') {|output, path| output &lt;&lt; "#{h(path)}rn"} rescue '')</pre>

Why is this rescue needed? There's no way to know and the complexity of the expression implies exasperation: "I give up trying to handle all these edge cases cleanly. Let's just throw in a rescue." So edge cases and bugs are swept under the proverbial rug.

**They are a performance hit.** Rescues are activated by raising errors. This involves creating a backtrace and this is one of the slowest operations you can perform. One raise is not going to kill you but if you are printing out 100 items, the costs will add up quickly. Here's some benchmark code:  
``

<pre>require 'benchmark'

puts Benchmark.measure {
  100000.times {
    item = nil
    item.name rescue 'None' # Use rescue
  }
}
puts Benchmark.measure {
  100000.times {
    item = nil
    item ? item.name : 'None' # Use tertiary logic
  }
}</pre>

And the results:

<pre>1.120000   0.110000   1.230000 (  1.225845)
  0.030000   0.000000   0.030000 (  0.034895)</pre>

Rescuing is 30x slower than the equivalent ternary logic expression on Leopard's ruby 1.8.6.

Conclusion? While performance is important, I'd argue that code readability is more important. When you perform a ternary check, as in the benchmark above, it tells the code reader that this item could be nil. Using the equivalent rescue just tells them this expression could fail for some reason. Nuance, edge cases, newly created bugs... All are swept under the rug by the evil rescue.

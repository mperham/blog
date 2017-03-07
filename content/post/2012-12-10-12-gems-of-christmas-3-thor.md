---
author: Mike Perham
categories:
- Ruby
date: 2012-12-10T00:00:00Z
title: '12 Gems of Christmas #3 -- thor'
url: /2012/12/10/12-gems-of-christmas-3-thor/
---

Ever try to write a rake task that took one or more arguments? How about calling a rake task from another task? Rake makes basic invocation simple but everything else obtuse. Enter [thor][1], courtesy of the unstoppable Yehuda Katz. Thor aims to make command line script development simpler by making your scripts standard Ruby objects and providing [good documentation in its wiki][2] for many common use cases. Consider a simple example, create a task to process a CSV file:

<pre lang="ruby"># inventory.thor
class Inventory &lt; Thor
  include Thor::Actions

  desc "process_csv FILE", "process the nightly inventory update"
  method_option :delete, :aliases => "-d", :desc => "Delete the file after parsing it"
  def process_csv(file)
    # do something, maybe like:
    #require 'inventory_file'
    #InventoryFile.new(file).process!
    remove_file(file) if options[:delete]
  end
end
</pre>

You invoke the task via `thor inventory:process_csv some_file.csv`. Tasks are just public methods within a subclass of Thor. The `desc` and `method_option` methods describe those tasks and any expected options on the command line. `Thor::Actions` gives us some filesystem helper methods, like `remove_file`. The wiki goes into further detail on things like inter-task dependencies, task grouping, namespaces, etc. Next time you need to write a command line script, give Thor a try and see if it doesn't make your life easier.

Tomorrow, I'll show you a tool for detecting and fixing a common Rails performance problem.

 [1]: http://github.com/wycats/thor
 [2]: http://github.com/wycats/thor/wiki

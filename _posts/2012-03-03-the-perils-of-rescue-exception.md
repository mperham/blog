---
title: 'The Perils of &quot;rescue Exception&quot;'
author: Mike Perham
layout: post
permalink: /2012/03/03/the-perils-of-rescue-exception/
categories:
  - Ruby
---
Ruby&#8217;s standard exception handling looks like this.

{% highlight ruby %}
begin
  do_something
rescue => ex
  # do something with the error
end
{% endhighlight %}

This will catch all StandardErrors and its subclasses. A frequent issue I see in Ruby code is this:

{% highlight ruby %}
begin
  do_something
rescue Exception => ex
  # Apparently I REALLY want to know if this
  # block of code fails for any reason.
end
{% endhighlight %}

This is a BAD, BAD idea, dear reader, and here&#8217;s why. Ruby uses Exceptions for other things than your application code errors. One example is the Interrupt class which is a SignalException. Ruby sends this Exception to all threads so that when the process gets an INT/Ctrl-C signal, all the threads will unwind and the process will shutdown. If you rescue Exception, you will potentially catch this exception and ignore it, making your thread and process an unkillable computing zombie. Your only choice will be to pull out your kill -9 shotgun and aim for the head.

Here&#8217;s an example of a Ruby script you cannot shutdown gracefully. Run it and you&#8217;ll see exactly the behavior I&#8217;ve described.

{% highlight ruby %}
while true
  begin
    sleep 5
    puts 'ping'
  rescue Exception => ex
    puts "Mmmmm, brains"
  end
end
{% endhighlight %}

So remember, your application errors should be subclasses of StandardError and if you want to catch everything, just stick will plain old &#8220;rescue => ex&#8221;. Your application will behave better for it.

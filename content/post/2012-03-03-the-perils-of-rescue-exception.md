---
author: Mike Perham
categories:
- Ruby
date: 2012-03-03T00:00:00Z
title: The Perils of "rescue Exception"
url: /2012/03/03/the-perils-of-rescue-exception/
---

Ruby's standard exception handling looks like this.

{{< highlight ruby >}}
begin
  do_something
rescue => ex
  # do something with the error
end
{{< / highlight >}}

This will catch all StandardErrors and its subclasses. A frequent issue I see in Ruby code is this:

{{< highlight ruby >}}
begin
  do_something
rescue Exception => ex
  # Apparently I REALLY want to know if this
  # block of code fails for any reason.
end
{{< / highlight >}}

This is a BAD, BAD idea, dear reader, and here's why. Ruby uses Exceptions for other things than your application code errors. One example is the Interrupt class which is a SignalException. Ruby sends this Exception to all threads so that when the process gets an INT/Ctrl-C signal, all the threads will unwind and the process will shutdown. If you rescue Exception, you will potentially catch this exception and ignore it, making your thread and process an unkillable computing zombie. Your only choice will be to pull out your kill -9 shotgun and aim for the head.

Here's an example of a Ruby script you cannot shutdown gracefully. Run it and you'll see exactly the behavior I've described.

{{< highlight ruby >}}
while true
  begin
    sleep 5
    puts 'ping'
  rescue Exception => ex
    puts "Mmmmm, brains"
  end
end
{{< / highlight >}}

So remember, your application errors should be subclasses of StandardError and if you want to catch everything, just stick will plain old "rescue => ex". Your application will behave better for it.

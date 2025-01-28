---
author: Mike Perham
date: 2016-06-24T00:00:00Z
title: Profiling Crystal on OSX
url: /2016/06/24/profiling-crystal-on-osx/
---

How do I profile my program to determine where it is slow?

This is one of the first questions any developer asks after building a
non-toy program.  Crystal has a reputation for being quite fast but
every language has [tricks and optimizations][1] we miss.

Since Crystal uses the LLVM compiler suite, we can reuse a lot of the
infrastructure which knows about LLVM-compiled binaries. **Net result:
the OSX Developer Tools include a beautiful profiler that works with
Crystal binaries out of the box - so awesome!**  If you have XCode
installed (and if you are reading this blog, it's very likely you do),
you can profile a Crystal binary right now, here's how.

## Instruments

Instruments.app is the OSX profiling tool.  We're going to instrument a
command line run and then view the results in its GUI.  I assume you
have Crystal installed; if not, run this:

```
brew update
brew install crystal-lang
```

Now we need an app to profile.  Let's make a toy app that doesn't
do much of anything; put this code in `app.cr`:

```ruby
def foo(i)
  "mike" + i.to_s
end

10_000_000.times do |x|
  foo(x)
end
```

Compile and run in the profiler:

```
$ crystal compile app.cr
$ instruments -t "Time Profiler" ./app
Instruments Trace Complete (Duration : 4.458741s; Output : /Users/mike/instrumentscli0.trace)
$ open instrumentscli0.trace/
```

You should now see a lovely UI with a totally rad tree view where you
can drill down into the trace to see where your code spent its time.
Looks like 80% of my app's time was spent in Int32#to\_s and
String#+, not exactly shocking but this is a toy example.

![crystal profiler](https://dl.dropboxusercontent.com/u/3425424/Blog/crystal_profiler.png)

Note that I didn't use `--release` flag with the compiler.  This was a
choice I made for this blog post; the traces are a LOT easier to
understand without release optimizations because LLVM doesn't inline
method calls so it's easier to drill into the code execution.  You should
profile with the --release flag when profiling your own non-trivial code
so you are profiling the same binary as you run in production.

Also note that Instruments supports a lot more modes that just the Time
Profiler - it can track memory allocations, syscalls, and many other aspects.
Play with it and see what modes are useful to you.

In conclusion, profiling Crystal code is super easy due to Crystal leveraging the LLVM compiler.
We can use LLVM-standard tools rather than needing custom profiling APIs and runtime support.

[1]: http://crystal-lang.org/docs/guides/performance.html

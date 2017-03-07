---
author: Mike Perham
categories:
- Ruby
date: 2013-02-23T00:00:00Z
title: Signal Handling with Ruby 2.0
url: /2013/02/23/signal-handling-with-ruby/
---

A user recently ran Sidekiq with Ruby 2.0 and found that the signal handling did not work well at all. Ctrl-C and other signals resulted in some ominous stack traces.

It turns out that Ruby 2.0 locks down what you can do in a signal handler in order to prevent unsafe or possibly non-deterministic behavior. You can't take a Mutex within a signal handler anymore as this could result in a thread context switch or even deadlock. In fact [you can't even write to a Logger][1] because it tries to use a Mutex internally.

I [rewrote the signal handling][2] to conform with the new restrictions: all handlers now just push the name of the signal onto a global array and the main thread polls once per second for unhandled signals. This isn't perfect, polling is something to be avoided where possible, but I don't know of a better solution and it's a lot better than the previous "fat" handlers that did a lot of work.

 [1]: https://bugs.ruby-lang.org/issues/7917
 [2]: https://github.com/mperham/sidekiq/commit/fb2c286506107dc0d5d3f297c19df8170b32ef54#L1R3

---
author: Mike Perham
categories:
- Ruby
- Software
date: 2008-12-13T00:00:00Z
title: Clojure vs Ruby, Part I
url: /2008/12/13/clojure-vs-ruby/
---

I'm a performance guy, I'll admit it. I love performance tuning and comparing code to see why one thing is slower than another. I've recently taken a shine to the Clojure programming language as it seems to combine two good things: an incredibly fast and reliable VM and a functional language designed for concurrency. Here's my first performance test: the ever-reliable fibonacci method. Please remember this is just a microbenchmark, take it with a grain of salt.

In Clojure:

```clj
(defn fib [n]
  (if (<= n 1)
    1
    (+ (fib (- n 1)) (fib (- n 2)))
  )
)
```

In Ruby:

```ruby
def fib(n)
  return 1 if n <= 1
  fib(n-1) + fib(n-2)
end
```

The JVM is Server 1.6.0_07 64-bit. Let's see how long each takes to calculate the 40th Fibonacci number:

```
C (gcc 4.0.1)         2.6 sec
Java                  1.2 sec
Clojure 20080916     11.3 sec
Ruby 1.9pr1          44.3 sec
JRuby 1.1.5         118.1 sec
Ruby 1.8.6          195.6 sec
```

Clojure's performance is really spectacular in this one microbenchmark compared to Ruby. There's some language overhead but the native speed is so fast that performance is still better than the fastest Ruby VMs. Rich Hickey has done a great job with Clojure but make no mistake, this is still mostly a hobbyist language done by one person - he can't afford to spend years building his own VM. Running native on the JVM has huge benefits in terms of performance.

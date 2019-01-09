---
author: Mike Perham
date: 2016-05-25T00:00:00Z
published: true
title: Sidekiq for Crystal
url: /2016/05/25/sidekiq-for-crystal/
---

[Sidekiq](http://sidekiq.org) is a popular job framework for Ruby.  Now we're bringing it to <a href="http://crystal-lang.org">Crystal</a>!

<figure style="float: right;">
  <a href="http://crystal-lang.org"><img style="border: solid white 0px;" src="http://crystal-lang.org/images/icon.png" width="200px" /></a>
</figure>
<figure style="float: right;">
  <a href="http://sidekiq.org"><img style="border: solid white 0px;" src="http://sidekiq.org/assets/kicker.svg" width="200px" /></a>
</figure>


## Why Crystal?

I wanted to use a language that was a good complement to Ruby.  Its
syntax is similar enough to Ruby that I can reuse a lot of code but it
adds a huge leap in performance.  In summary:

* very similiar syntax to Ruby
* at least 3-5x faster than Ruby 2.3 on most code
* at least 3x smaller in memory footprint
* statically typed
* compiles to a single, 1MB binary! Deployment is easy.
* comes with a large, useful standard library

In other words, Ruby is friendly, flexible and works for most usecases while Crystal is fast and
efficient for those usecases where performance is paramount.  Use each where appropriate.

How productive is it?  I started this project **from scratch** not knowing
the language at all a week ago and had the core job processor running in 3 days.

## Gimme!

The project resides at [mperham/sidekiq.cr](https://github.com/mperham/sidekiq.cr).  To get
started:

```
brew update
brew install crystal-lang
# brew install redis
git clone git://github.com/mperham/sidekiq.cr.git
cd sidekiq.cr
crystal deps
make
```

If you have Redis and the `sidekiq` gem installed, you can run the benchmarks:

```
brew install redis
gem install sidekiq
make bench
```

This is the result for me: **with zero optimization on my part, Crystal is 3.6x faster and 3x smaller**.
To process 100,000 noop jobs:

Runtime | RSS | Time | Throughput
--------|-----|------|-------------
MRI 2.3.0 | 50MB | 21.3 | 4,600 jobs/sec
MRI/hiredis | 55MB | 19.2 | 5,200 jobs/sec
Crystal 0.17 | 18MB | 5.9 | **16,900 jobs/sec**

## The codebase is a trainwreck though, right?

The code is shockingly similar to Ruby in many cases.  Take a gander at this testcase:

```ruby
require "./spec_helper"

class MyWorker
  include Sidekiq::Worker

  def perform(a : Int64, b : Int64, c : String)
    #puts "hello world!"
  end
end

describe Sidekiq::Worker do
  describe "client-side" do
    it "can create a basic job" do
      jid = MyWorker.async.perform(1_i64, 2_i64, "3")
      jid.should match /[a-f0-9]{24}/
      pool = Sidekiq::Pool.new
      pool.redis { |c| c.lpop("queue:default") }
    end

    it "can schedule a basic job" do
      jid = MyWorker.async.perform_in(60.seconds, 1_i64, 2_i64, "3")
      jid.should match /[a-f0-9]{24}/
    end
```

With the exception of a few type hints, that's identical to Ruby.


## Cool, just gonna push this to production...

Whoa, this project is **alpha**.  Hold off porting your nuclear reactor controller code
for another week or two, ok?  Major functionality is missing,
(notably the data API and Web UI), the test suite is still baking, etc.  Take it for a test drive and [let me
know](https://github.com/mperham/sidekiq.cr/issues) how it goes for you.

Looking for other libraries written in Crystal?  Check out the
[CrystalShards](http://crystalshards.xyz/?sort=stars&filter=)
listing.
[AwesomeCrystal](https://github.com/veelenga/awesome-crystal#awesome-crystal--)
is another curated list of resources.
You can find database drivers, web frameworks, etc.


## What about Sidekiq Enterprise?

Based on demand, I will port the Sidekiq Pro and Enterprise functionality to
Crystal.  If you are interested, [email me](mailto:mike@contribsys.com).

## Conclusion

Let's make [Sidekiq.cr](https://github.com/mperham/sidekiq.cr) amazing, try it out and help us improve it!

+++
date = "2018-02-28T07:00:00-08:00"
title = "Ruby Optimization with One Magic Comment"
+++

Software performance optimization is simple: find a way to do less. Ruby has a reputation for being slow and, while that impression is a decade out of date, one of the leading offenders has been the garbage collector.

This leads to the question: can we speed up Ruby by creating less garbage? Absolutely!

## A String Primer

Ruby has an unfortunate default semantic that all Strings are mutable:

```ruby
string = ""
string << "mike"
```

This allocates two Strings, "" and "mike". The first, empty String is then mutated to contain "mike". However String mutation is quite rare, more common is something like this:

```ruby
HASH = {
  "mike": 123
}

def getmike
  HASH["mike"] # unnecessary garbage here!
end
```

Every invocation of getmike will allocate a new copy of "mike", which is then immediately thrown away as garbage, but is required because Ruby just treats the String as a method argument which might be mutated inside `Hash#[]`. So wasteful!

## Freeze!

Ruby introduced the freeze concept many years ago to minimize allocation. Calling freeze on an object tells Ruby to treat it as immutable. Now Ruby knows that it can treat "mike" as a constant:

```ruby
def getmike
  HASH["mike".freeze]
end
```

The problem? It makes the code uglier and needs to be called everywhere you declare a String.

## Magic Comments!

Ruby 2.3 introduced a very nice option: each Ruby file can opt into Strings as immutable, meaning all Strings within that file will automatically freeze, with a simple magic comment at the top of the file. This will not allocate an extra String for "mike".

```ruby
# frozen_string_literal: true

HASH = {
  "mike": 123
}

def getmike
  HASH["mike"]
end
```

## The Real World

Years ago I added a lot of freeze calls to Sidekiq to minimize its impact on the garbage collector and maximize performance.
Last week [I removed all those calls](https://github.com/mperham/sidekiq/pull/3759/files) and added a `frozen_string_literal` comment to all Ruby files.

To see the effect, I ran an experiment with `frozen_string_literal` using Sidekiq's benchmark script by adding `GC.disable` and watching the RSS grow. Note how Ruby allows you to enable or disable the feature with a flag:

### Disabled

```
$ RUBYOPT=--disable=frozen-string-literal bundle exec bin/sidekiqload
Created 30000 jobs
RSS: 105852 Pending: 25749
RSS: 178880 Pending: 21514
RSS: 252804 Pending: 17306
RSS: 326824 Pending: 12987
RSS: 399268 Pending: 8810
RSS: 472620 Pending: 4618
RSS: 547968 Pending: 319
RSS: 553568 Pending: 0
Done
```

### Enabled

```
$ RUBYOPT=--enable=frozen-string-literal bundle exec bin/sidekiqload
Created 30000 jobs
RSS: 105824 Pending: 25687
RSS: 174948 Pending: 21700
RSS: 245448 Pending: 17669
RSS: 316848 Pending: 13559
RSS: 388544 Pending: 9447
RSS: 456704 Pending: 5288
RSS: 450552 Pending: 1160
RSS: 457536 Pending: 0
Done
```

**`frozen_string_literal` reduces the generated garbage by ~100MB or ~20%!** Free performance by adding a one line comment.

## Conclusion

**Gem authors: add `# frozen_string_literal: true` to the top of all Ruby files in a gem.**
It gives a free performance improvement to all your users as long as you don't use String mutation.

### Notes

1. If you do mutate, use `String.new` to allocate a mutable String instead of "".
2. The magic comment will only work on Ruby 2.3+ but since Ruby 2.2 is EOL in one month, I think it's fair to stop performance tuning for it.

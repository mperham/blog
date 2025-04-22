---
author: Mike Perham
categories:
- Ruby
date: 2012-09-25T00:00:00Z
title: MiniTest -- Ruby 1.9's test framework
url: /2012/09/25/minitest-ruby-1-9s-test-framework/
---

(this is a classic post I wrote two years ago for another site which is shutting down, saving here since it's still very useful)

Aaron Patterson gave a talk at GoGaRuCo 2010 about the latest changes in Ruby 1.9.2's standard library and one of the topics he spoke on was MiniTest. The Ruby community has been particularly innovative in the world of testing and Ruby 1.8's Test::Unit library is circa 2003, providing nothing but the most basic testing API. Every Ruby project I've ever worked on has skipped Test::Unit and pulled in many different test gems (e.g. rspec, shoulda, mocha, flexmock) to provide a modern test infrastructure.

## Test::Unit Refresher

With Test::Unit, you just subclass Test::Unit::TestCase, name your methods starting with 'test' and include one or more assertions to verify:

```ruby
class TestSomething &lt; Test::Unit::TestCase
  def test_foo
    foo = Foo.new
    assert foo
    bar = nil
    assert_nil bar
  end
end
```

Believe it or not, Test::Unit is actually rather slow and bloated. It includes a number of GUIs (GTk v1, GTk v2, FxRuby) that are rarely if ever used. A revamp was needed...

## Enter MiniTest

Ruby 1.9 includes an updated version of the venerable Test::Unit which removes a lot of the more esoteric features, called [MiniTest][1]. You don't need to do anything to use MiniTest in 1.9, it replaces Test::Unit and provides a backwards compatible API that provides the 90% of Test::Unit that people were using often. You can even use minitest on Ruby 1.8 by installing the \`minitest\` gem. Aside from the Test::Unit API, several improvements over Test::Unit are included:

**Randomization**

When you run your test suite, you might notice this at the bottom:

```
Test run options: --seed 1261
```

This is because MiniTest by default runs your tests in random order. This is a good thing because it prevents your tests from accidentally becoming order-dependent due to "state leakage". If you find that your tests are breaking randomly, it is most likely due to this state leakage. You can run your tests with the same seed to reproduce the problem:

```
rake TESTOPTS="--seed=1261"
```

**Skip Tests**

MiniTest allows you to easily skip tests that are not working with the \`skip\` method:

```ruby
def test_foo
  skip("Need to debug this...")
  assert_equal false, true
end
```

which results in this:

```
83 tests, 106 assertions, 0 failures, 0 errors, 1 skips
```

**Verbosity**

MiniTest also has a '-v' flag which will print out the time each test takes - excellent for determining those tests which are slowing down your test suite:

```
rake TESTOPTS="-v"
```

which emits a line for each test. It's too bad it doesn't have an option for sorting or a minimum time (like 0.1 sec); this would be useful for suites which have thousands of tests.

```
TestMemCache#test_check_size_off: 0.02 s: .
TestMemCache#test_check_size_on: 0.01 s: .
TestMemCache#test_consistent_hashing: 0.11 s: .
TestMemCache#test_crazy_multithreaded_access: 0.00 s: S
TestMemCache#test_custom_encoding: 0.00 s: .
TestMemCache#test_decr: 0.00 s: .
```

**BDD DSL**

MiniTest also includes a basic BDD DSL like RSpec:

```ruby
require 'minitest/spec'

describe Meme do
  before do
    @meme = Meme.new
  end

  describe "when asked about cheeseburgers" do
    it "should respond positively" do
      @meme.i_can_has_cheezburger?.must_equal "OHAI!"
    end
  end

  describe "when asked about blending possibilities" do
    it "won't say no" do
      @meme.does_it_blend?.wont_match /^no/i
    end
  end
end
```

It even includes a basic mocking API which you can read about in the [MiniTest documentation][1]. These changes are a great step forward for Ruby's standard test library. Personally I'm going to use MiniTest on my next project and see if I can slim down my test dependencies. Happy coding!

 [1]: http://bfts.rubyforge.org/minitest/

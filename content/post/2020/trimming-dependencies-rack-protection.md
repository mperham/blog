---
title: "Trimming Dependencies: rack-protection"
date: 2020-06-03T19:57:44-07:00
publishdate: 2020-06-03
lastmod: 2020-06-03
tags: []
---

[Recently I discussed](/2020/06/02/trimming-dependencies-concurrent-ruby/index.html) how I was evaluating all of Sidekiq's current dependencies to see if any could be removed or vendored to reduce upstream churn, security issues, and other maintenance chores.
I was able to remove `concurrent-ruby` from Sidekiq Pro and Sidekiq Enterprise, which is a major win considering the size of that gem.
A simple benchmark showed removing that gem shrunk a basic
Sidekiq Pro process from 60MB to 50MB, a 16% improvement!

Today I want to discuss another gem dependency used by Sidekiq: `rack-protection`.
We use its Rack middleware to defend against CSRF attacks in the Web
UI, but in the last five years we haven't used any other features. Can we copy the functionality into Sidekiq without too much trouble?

Our initial research looked promising. The code had not changed in four
years, meaning it was very stable already and shouldn't need upkeep. Sidekiq
committer [@seuros](https://github.com/seuros) took the [first steps](https://github.com/mperham/sidekiq/pull/4588) to
copy the CSRF protection code from rack-protection into Sidekiq
(which is possible because its MIT license allows copy with
attribution).

I wasn't really happy with the result though: 250 lines of code
seemed like a lot for the feature, I didn't really understand the code well and, perhaps most importantly, I didn't know how to test it. If I'm going to own the functionality, I want to know that CI is exercising it regularly.

I spent about six hours today refactoring the code.
I find the rack codebase to be a bit abstract for my own tastes, with lots of options, abstract classes/modules and one line methods which make the code harder to follow and navigate.
To that end, I removed a lot of options and features Sidekiq doesn't use, inlined or removed some methods and shrank the code from 230 to 130 lines.
The public API is now this:

```ruby
class Sidekiq::Web::CsrfProtection
  def initialize(app, options = nil)
    @app = app
  end

  def call(env)
    accept?(env) ? admit(env) : deny(env)
  end
```

Once I had a very limited, focused API I started writing tests in test_csrf.rb.
I wanted four tests:

* a simple GET which does not require CSRF protection
* a POST with no token
* a POST with a known bad token
* a POST with a good token

All I had to do was provide those `app` and `env` parameters, easy right??? Actually Rack's `call` interface made it rather elegant: you can call a block with `.call` so my "test app" is just a block! I explicitly chose not to use Rack's test helper DSL in order to better understand how Rack works under the covers. Here's the simple GET test:

```ruby
def call(env, &block)
  Sidekiq::Web::CsrfProtection.new(block).call(env)
end

def test_get
  ok = [200, {}, ["OK"]]
  result = call(env) do |envy|
    refute_nil envy[:csrf_token]
    assert_equal 88, envy[:csrf_token].size
    ok
  end
  assert_equal ok, result
end
```

In a real world app that block would render an HTML template,
injecting the `:csrf_token` into a hidden form input.

The trickiest part was constructing Rack's `env` which is a magical Hash full of pain and wonder:

```ruby
def session
  @session ||= {}
end

def env(method=:get, form_hash={})
  imp = StringIO.new("")
  {
    "REQUEST_METHOD" => method.to_s.upcase,
    "rack.session" => session,
    "rack.logger" => ::Logger.new(@logio ||= StringIO.new("")),
    "rack.input" => imp,
    "rack.request.form_input" => imp,
    "rack.request.form_hash" => form_hash,
  }
end
```

Don't ask; it works. A POST looks like this:

```ruby
result = call(env(:post, { "authenticity_token"=>goodtoken })) do
  [200, {}, ["OK"]]
end
refute_nil result
assert_equal 200, result[0]
assert_equal ["OK"], result[2]
```

Not super elegant but I like explicit code; by their nature, DSLs hide underlying complexity, meaning you never get a good mental model of how something works (**critical for debugging**).

After today's work, here's the result:

1. `rack-protection` code vendored
2. code heavily refactored to simplify
3. one less gem dependency
4. four explicit tests written to cover typical uses
5. much better understanding of the CSRF protection internals and Rack testing

Sidekiq now depends only on `redis`, `rack`, `connection_pool`. One
bummer: memory usage didn't significantly change. Was this a win
overall? Arguable but the sunk cost fallacy tells me it was. 🤣 C'est la vie.

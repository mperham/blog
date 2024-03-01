---
title: "Serializing Ruby datatypes in JSON"
date: 2024-03-01T09:42:08-08:00
publishdate: 2024-03-01
lastmod: 2024-03-01
tags: []
---

Ruby's JSON library allows you to convert Ruby datatypes into a JSON document, as long as those types are native to JSON: String, bool, int, float, nil, Hash and Array.
Everything else converts to a String by default; if you use any other core datatypes, they will not survive a `JSON.generate/JSON.parse` round trip. Here I pass a Range, Symbol and Time; notice how the end result is three Strings instead of the actual types:

```ruby
> require "json"
> JSON.generate([0..5, :foo, Time.now])
=> "[\"0..5\",\"foo\",\"2024-03-01 09:48:06 -0800\"]"
> JSON.parse(_)
=> ["0..5", "foo", "2024-03-01 09:48:06 -0800"]
```

I recently discovered a feature of JSON where you can opt-into a set of extensions which can serialize most core datatypes. I get back exactly the same objects I serialized:

```ruby
> require "json/add/core"
> JSON.generate([0..5, :foo, Time.now])
=> "[{\"json_class\":\"Range\",\"a\":[0,5,false]},{\"json_class\":\"Symbol\",\"s\":\"foo\"},{\"json_class\":\"Time\",\"s\":1709315467,\"n\":612985000}]"
> s = _
> JSON.parse(s)
=> 
[{"json_class"=>"Range", "a"=>[0, 5, false]},
 {"json_class"=>"Symbol", "s"=>"foo"},
 {"json_class"=>"Time", "s"=>1709315467, "n"=>612985000}]
> JSON.parse(s, create_additions: true)
=> [0..5, :foo, 2024-03-01 09:51:07.612985 -0800]
```

You need to require `json/add/core` and use the `create_additions` keyword to signal to `JSON.parse` that the document may contain those optional "additions".

It appears to work well and a benchmark shows that it adds little to no overhead.

There is one major caveat: **Symbol hash keys still don't work**.
Unfortunately this is the number one complaint with Sidekiq's argument processing and these additions do not solve that issue.
Let me explain why.

## The Trouble with Symbol Keys

The JSON standard says "JSON keys are strings, always on the left of the colon, and must be wrapped in double quotes".

```json
{
  "mike": 123,
  "bob": "brother"
}
```

With Ruby, it is idiomatic to use Symbols rather than Strings for Hash keys and sometimes for values too:

```ruby
{
  :mike => 123,
  :bob => :brother
}
```

The trouble is how the JSON additions serial the non-JSON-native types: by converting them into a JSON object which holds the relevant state for the object:

```ruby
> JSON.generate([:foo])
=> "[{\"json_class\"=>\"Symbol\", \"s\"=>\"foo\"}]"
```

The problem is that an Object cannot be a Hash key in JSON; this is not legal:

```json
{
  {"json_class":"Symbol","s":"mike"}: 123,
  {"json_class":"Symbol","s":"bob"}: {"json_class":"Symbol","s":"brother"}
}
```

So Hash keys must be converted to raw Strings. One possible way to implement this would be to smuggle the type within the String itself:

```ruby
> JSON.generate({ :mike => 123, :bob => :brother })
=> "{\"_s:mike\":123,\"_s:bob\":{\"json_class\":\"Symbol\",\"s\":\"brother\"}}"
```

And so I have proposed just that to the JSON gem in [issue #570](https://github.com/flori/json/issues/570). If we can get Symbol smuggling support, Sidekiq should be able to support Symbols in job arguments, a huge quality of life improvement for my users. ActiveJob may be able to greatly simply its own marshalling by leveraging this functionality too. Everyone downstream would benefit. If you want to see this supported, please go to that issue and put in a reaction to show your interest.
---
title: "Sidekiq and Request-Specific Context"
date: 2022-07-29T19:43:06-07:00
publishdate: 2022-07-29
lastmod: 2022-07-29
draft: false
tags: []
---

At some point in growing a large-scale software system, you'll require "out of band" context: data which is not explicitly passed as an argument to a function but rather implicitly attached to the request, job or event being processed.
Usually context is implemented as thread-local variables; your code first sets up the necessary context and then processes the request.
A common example is multi-tenancy: you might want to limit any data queried by a given request to a database schema specific to a given tenant.
When a request first comes into your system, your code would determine the associated `tenant_id` and set that context:

```ruby
class Context
  def self.tenant_id
    Thread.current[:tenant_id]
  end
  def self.tenant_id=(tid)
    Thread.current[:tenant_id] = tid
  end
end
```

```ruby
class ApplicationController < ActionController::Base
  before_action :set_tenant

  def set_tenant
    Context.tenant_id = user.organization_id
  end
end
```

Usually you'll use a gem like `apartment` to help implement multi-tenancy. The code above is not production-ready; keep reading.

## The Rails Solution

Of course Rails already offers an API to implement request-specific context: here's the [`CurrentAttributes` API](https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html) and a [blog post](https://fullstackheroes.com/tutorials/rails/current-attributes/) showing how to use it. Let's define our attributes object:

```ruby
class Myapp::Current < ActiveSupport::CurrentAttributes
  attribute :tenant_id
end
```

Now we have a thing which holds our request-specific context. We'll set our tenant before processing any request:

```ruby
class ApplicationController < ActionController::Base
  before_action :set_tenant

  def set_tenant
    Myapp::Current.tenant_id = 123
  end
end
```

But wait, we have a problem: your app will often spin off background jobs for a request **and those jobs will need that context too**!

## Sidekiq to the Resque

That's why Sidekiq 6.3 added support for ActiveSupport::CurrentAttributes!
You just need to put this in your initializer:

```ruby
require "sidekiq/middleware/current_attributes"
Sidekiq::CurrentAttributes.persist(Myapp::Current) # Your AS::CurrentAttributes singleton
```

Now when you set `tenant_id` in your request and then create a background job, `SomeJob.perform_async("mike")`, you'll get a job payload in Redis that looks like this:

```ruby
irb(main):001:0> Myapp::Current.tenant_id = 123
irb(main):002:0> SomeJob.perform_async("mike")
irb(main):003:0> Sidekiq::Queue.new.first
  {"retry"=>true,
   "queue"=>"default",
   "backtrace"=>5,
   "args"=>["mike"],
   "class"=>"SomeJob",
   "jid"=>"cd041555bda96d781cbc8539",
   "created_at"=>1659150392.662438,
   "cattr"=>{"tenant_id"=>123},
   "enqueued_at"=>1659150392.663126}
```

Note that `cattr` hash is the data within `Myapp::Current` serialized at the time when the job was created.
Sidekiq will automatically restore that data every time the job executes.
[Here's the code](https://github.com/mperham/sidekiq/blob/main/lib/sidekiq/middleware/current_attributes.rb) for you to read if you want to see how it's done.

Request-specific context is a bit magical and functional purists will argue they act like global variables.
That is true but I take a more pragmatic stance: they solve a real world problem.
Go chose the opposite approach with their [`context`](https://pkg.go.dev/context) package and requires all Go code to pass a `context.Context` argument to every function.
I've worked with both approaches and I still prefer Ruby's thread-local variables which are far easier to integrate into an existing system as it grows.
The ability to add a significant new feature (e.g. multi-tenancy) without refactoring your entire app is a massive win.
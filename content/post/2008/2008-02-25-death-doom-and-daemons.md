---
author: Mike Perham
categories:
- Ruby
date: 2008-02-25T00:00:00Z
keywords:
- actionmailer, daemon
title: Death, Doom and Daemons!
url: /2008/02/25/death-doom-and-daemons/
---

We're actually starting to run the new FiveRuns service daemons internally and found that they were dying due to various issues so I integrated a little bit of ActionMailer code to email the dev team when a daemon dies with the relevant details.  Below is what I did -- do you have any tips for monitoring Ruby daemon processes?

<!--more-->

First we need to create an ActionMailer which will send email:

```ruby
class DemiseMailer < ActionMailer::Base
  def condolences(name, err)
    require 'socket'

    recipients  Array('Development <nosuchemail@example.com>')
    from        'DemiseMailer <nosuchemail@example.com>'
    subject     "#{name} died on #{Socket.gethostname}"
    body({ :name => name, :error => err })
  end
end
```

and call the mailer when the daemon dies:

```ruby
begin
  loader = Loader::Engine.new
  loader.load(true)
rescue => e
  DemiseMailer.deliver_condolences('loader', e) if RAILS_ENV == 'production'
  raise e
end
```

Now we put the email template in *demise_mailer/condolences.erb*:

```
I regret to inform you that your daemon, <%= @name %>, passed away at <%= Time.now %>
while running on <%= Socket.gethostname %>.

Its last words were:

<%= @error.to_s %>
<%= @error.backtrace.join("nt") %>

My condolences on your loss.

Sincerely,
DemiseMailer
```

and finally configure ActionMailer to send SMTP email:

```ruby
ActionMailer::Base.template_root = File.expand_path(File.dirname(__FILE__))
ActionMailer::Base.smtp_settings = {
  :address => 'email.example.com',
  :domain  => 'example.com',
  :port => 587
}
ActionMailer::Base.raise_delivery_errors = true
```

Seems to work pretty well so far.  Drop me a comment if you use it or have suggestions to improve it!

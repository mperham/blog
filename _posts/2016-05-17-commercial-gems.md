---
title: "Serving your own Commercial Rubygems"
author: Mike Perham
layout: post
permalink: /2016/05/17/commercial-gems/
published: true
---

It's not well known but with Rubygems and Bundler, you can distribute access-controlled commercial Rubygems.  My gems, [Sidekiq Pro and Sidekiq Enterprise](http://sidekiq.org), are the most well known example but I'm not a wizard: anyone can distribute gems to a limited set of customers.  Here's how I do it.

- A $5/mo DigitalOcean instance running Apache.  No database, no app server.  I have a set of bash scripts which can build a server in 5 minutes.
- To serve gems, you need to have Apache serve a directory of static files.  You'll need a VirtualHost entry with something like this:

```
  <VirtualHost *:443>
    ServerName my-server.com
    DocumentRoot /var/www/gems

    SSLEngine on

    <Location />
      AuthType basic
      AuthName "private area"
      AuthBasicProvider file
      AuthUserFile /var/www/gems-passwd
      Require valid-user
    </Location>
```

- To control access to those gems, you need a `/var/www/gems-passwd` file which contains your user / password pairs.  The username / passwords are a hash based on the customer's email address.  The contents look like this:

```
1a7fe3bd:$apr1$0RtyG.1v$D/o5n25i2YmPiTOGAPPI21
d41be46c:$apr1$.dFnnB5F$Ne2YtTP12q9iM9/ZQvoL01
09120f77:$apr1$ERLqbLvS$El2Llj6MJlWDWQnJKcrR80
```

The command to generate an entry is `htpasswd -nb user pwd`.

I have a `/var/www/gems` directory which looks like this:

```
$ pwd
/var/www/gems
$ ls -l
total 36
drwxrwxr-x 2 mike adm  4096 Apr  5 16:25 gems
-rw-rw-r-- 1 mike mike   65 Apr  5 16:25 latest_specs.4.8
-rw-rw-r-- 1 mike mike   82 Apr  5 16:25 latest_specs.4.8.gz
-rw-rw-r-- 1 mike mike   98 Apr  5 16:25 prerelease_specs.4.8
-rw-rw-r-- 1 mike mike  100 Apr  5 16:25 prerelease_specs.4.8.gz
drwxrwxr-x 3 mike adm  4096 Apr  5 16:25 quick
-rw-rw-r-- 1 mike mike 1307 Apr  5 16:25 specs.4.8
-rw-rw-r-- 1 mike mike  251 Apr  5 16:25 specs.4.8.gz
```

- When you buy Sidekiq Pro, Stripe sends my server a webhook.  I have a rake task which looks up the new customer's email address, adds a new user/pwd to the end of the gems-passwd file and then sends them an email with directions to access the Sidekiq Pro gem:

```
Put this in your Gemfile:

    source "https://my-server.com" do
      gem "sidekiq-pro"
    end

Run this bundle command:

    bundle config my-server.com username:password

Run `bundle install` and you're done!
```

- In addition to the passwd file, the server has a CSV file with `email,username,password` so I can look up the Apache username for a customer's email and regenerate the passwd file from scratch if necessary.
- If a subscription runs out, Stripe sends the opposite webhook; the server removes them from the CSV and passwd so they can no longer access the gem server.
- I have rake tasks which can push a new gem version, add/remove a customer, send email, etc.
- Pushing a new gem version looks like this, note the `generate_index` call:

```ruby
task :push => :release do
  require 'net/ssh'
  require 'net/scp'
  require 'sidekiq/pro/version'

  ver = ENV["VERSION"] || Sidekiq::Pro::VERSION

  Net::SCP.start("my-server.com", "user") do |scp|
    scp.upload!("pkg/sidekiq-pro-#{ver}.gem", "/var/www/gems/gems")
  end

  Net::SSH.start("my-server.com", 'user') do |ssh|
    puts ssh.exec!("gem generate_index --directory /var/www/gems")
  end
  puts "Released Sidekiq Pro #{ver}"
end
```

- The Stripe webhook integration is really nice as it automates 90% of my business BUT don't bother until you have sufficient sales to make it worth your while.  For the first two years, I added customers manually when I got the "You just got a sale!" email.  The hard part is dealing with churn - Stripe doesn't email when a subscription ends so you'll need to automate that or at least send yourself email upon that webhook.
- For redundancy, I run two servers at a time so a replica is always available.  I switch out servers every six months so software versions on the server stay reasonably current: create new replica, old replica is promoted to primary, old primary is killed.  The servers are sync'd with BitTorrent Sync, which is the only "shiny" tech I use but I've found nothing better to keep a directory in sync between two servers in near real-time.

### End Result

When I get a sale, my "Sidekiqbot" script sends me an email that the customer was set up.  It feels pretty awesome to know the onboarding is completely automated.

![sale](/images/sale.png)

That's it: Apache, CSV and some basic Linux/Ruby scripting.  It took me weeks to develop all of this but there's nothing super difficult about it.  I try to keep the server as simple as possible so I can focus on Sidekiq development and support, not operations.  After all, you're buying what's **in** the gems, not what serves them.  This simplicity has real benefits: it's cheap ($10/mo for two servers), easy to maintain and reliable.  If you are thinking about following in my footsteps, I hope this blog post helps light the way.

### Postscript

I became a member of [Ruby Together](https://rubytogether.org) because I rely on Bundler and the Rubygems infrastructure.
The fact that we can do this at all is the beauty of Bundler and Rubygems: they are easily federated using HTTP and static files only.  As an alternative, consider npm; it requires CouchDB, a full copy of the npm dataset to serve and only supports a single package server.  This design is much more complex, requiring a much heavier server, and makes it effectively impossible for an individual to run an npm server due to the operational costs and maintenance required.


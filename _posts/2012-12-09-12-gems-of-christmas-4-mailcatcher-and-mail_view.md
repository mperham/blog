---
title: '12 Gems of Christmas #4 &#8211; mailcatcher and mail_view'
author: Mike Perham
layout: post
permalink: /2012/12/09/12-gems-of-christmas-4-mailcatcher-and-mail_view/
categories:
  - Software
---
Surprise, today&#8217;s blog posting is a double header!

Testing email can be painful, verifying delivery and look and feel quickly becomes tedious. [mailcatcher][1] and [mail_view][2] are my go-to tools for dealing with email.

**mailcatcher**

With mailcatcher, you install the gem and then run the `mailcatcher` binary to start the mailcatcher daemon in the background. Now you have an SMTP server running on port 1025 and an inbox available at http://localhost:1080. I configured [The Clymb][3] Rails app to automatically use mailcatcher if it&#8217;s running:

<pre lang="ruby"># config/initializers/email.rb
begin
  sock = TCPSocket.new("localhost", 1025)
  sock.close
  catcher = true
rescue
  catcher = false
end

ActionMailer::Base.smtp_settings = if Rails.env.development? &#038;&#038; catcher
  { :host => "localhost", :port => '1025', }
else
  { } # normal SMTP config
end
</pre>

Now you can test email via http://localhost:1080 and not have to use gmail, hotmail, etc.

**mail_view**

[mail_view][2] is awesome for rapidly testing UI changes in email. The trick is to render the email as a webpage directly in your Rails app so you can see changes immediately with Cmd+R just like any normal webpage. You just need to set up the email to be rendered with some data; in our case we just pull random data from the database since we all work with production database snapshots.

<pre lang="ruby">class Preview &lt; MailView
  def order_receipt
    cart = Cart.where(:state => 'pushed').order(:id).last
    Emails.order_receipt(cart.id)
  end
end
</pre>

Of course, we need to mount the mail_view engine itself:

<pre lang="ruby"># config/routes.rb
mount MailPreview => 'mail_view' if Rails.env.development?
</pre>

Now we can go to http://localhost:3000/mail\_view/order\_receipt and immediately see what our order_receipt email looks like, no email required!

With mailcatcher and mail_view at your side, email development and testing goes from tedious to stupendous! Tomorrow we&#8217;ll cover a gem designed to build better command line scripts in Ruby&#8230;

 [1]: http://mailcatcher.me
 [2]: https://github.com/37signals/mail_view
 [3]: http://theclymb.com/invite-from/mperham
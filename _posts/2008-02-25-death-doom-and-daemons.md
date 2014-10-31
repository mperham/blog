---
title: Death, Doom and Daemons!
author: Mike Perham
layout: post
permalink: /2008/02/25/death-doom-and-daemons/
keywords:
  - actionmailer, daemon
categories:
  - Ruby
---
We&#8217;re actually starting to run the new FiveRuns service daemons internally and found that they were dying due to various issues so I integrated a little bit of ActionMailer code to email the dev team when a daemon dies with the relevant details.  Below is what I did &#8211; do you have any tips for monitoring Ruby daemon processes?

<!--more-->

First we need to create an ActionMailer which will send email:

<pre>class DemiseMailer &lt; ActionMailer::Base
  def condolences(name, err)
    require 'socket'

    recipients  Array('Development &lt;nosuchemail@example.com&gt;')
    from        'DemiseMailer &lt;nosuchemail@example.com&gt;'
    subject     "#{name} died on #{Socket.gethostname}"
    body({ :name =&gt; name, :error =&gt; err })
  end
end</pre>

and call the mailer when the daemon dies:

<pre>begin
  loader = Loader::Engine.new
  loader.load(true)
rescue =&gt; e
  DemiseMailer.deliver_condolences('loader', e) if RAILS_ENV == 'production'
  raise e
end</pre>

Now we put the email template in *demise_mailer/condolences.erb*:

<pre>I regret to inform you that your daemon, &lt;%= @name %&gt;, passed away at &lt;%= Time.now %&gt;
while running on &lt;%= Socket.gethostname %&gt;.

Its last words were:

&lt;%= @error.to_s %&gt;
&lt;%= @error.backtrace.join("nt") %&gt;

My condolences on your loss.

Sincerely,
DemiseMailer</pre>

and finally configure ActionMailer to send SMTP email:

<pre>ActionMailer::Base.template_root = File.expand_path(File.dirname(__FILE__))
ActionMailer::Base.smtp_settings = {
  :address =&gt; 'email.example.com',
  :domain  =&gt; 'example.com',
  :port =&gt; 587
}
ActionMailer::Base.raise_delivery_errors = true</pre>

Seems to work pretty well so far.  Drop me a comment if you use it or have suggestions to improve it!
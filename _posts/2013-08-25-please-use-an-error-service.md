---
title: Please Use an Error Service!
author: Mike Perham
layout: post
permalink: /2013/08/25/please-use-an-error-service/
categories:
  - Rails
  - Ruby
---
In [The Perils of &#8220;rescue Exception&#8221;][1] I explained one major error handling issue I see in almost all Ruby code. The second mistake I see is using logging rather than an error service.  
<!--more-->

  
An error service is SaaS that provides error handling for your application. Your code throws an error, the service&#8217;s client library catches the error and uploads the error message, backtrace and context to the service. You and the rest of the development team get an email when an error occurs.

**Pain is to your body what errors are to your application.** You want to know about errors as soon as possible so you can triage and understand the current health of your application.

Here&#8217;s what your code might look like if you use logging:

<pre lang="ruby">begin
  call_foo
rescue => ex
  Rails.logger.error("Unable to call foo: #{ex.message}")
end
</pre>

Insanity! Are you going to scan your logs constantly for errors? Do you look at your body constantly for wounds? Here&#8217;s what it looks like when you use an error service:

<pre lang="ruby">call_foo
</pre>

The error service generally integrates into Rails (and Sidekiq, too!) so that your code need do nothing. If call_foo raises an error, you&#8217;ll get an email seconds later with a backtrace and all the context available (controller parameters, http headers, etc) which often means you can diagnose the problem in seconds.

Errors should cause pain but don&#8217;t let them make your code filthy with logging! Remove all that error logging and just use an error service – it&#8217;s the sane and healthy thing to do. And once your inbox calms down, you have a pretty reasonable indicator that your app is healthy.

Postscript:

Since I&#8217;m sure people will ask for error service recommendations, I do want to make clear that I&#8217;m not endorsing any one service but here&#8217;s a list of error services off the top of my head:

*   [Honeybadger][2]
*   [Raygun][3]
*   [Sentry][4]
*   [Bugsnag][5]

Generally they all have cheap starter plans at $20/month or less and real production-worthy plans for less than $50/month. It&#8217;s money well spent.

 [1]: http://www.mikeperham.com/2012/03/03/the-perils-of-rescue-exception/
 [2]: http://honeybadger.io
 [3]: http://raygun.io
 [4]: http://getsentry.com
 [5]: http://bugsnag.com
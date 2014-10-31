---
title: Introspecting RESTful APIs
author: Mike Perham
layout: post
permalink: /2008/04/15/introspecting-restful-apis/
keywords:
  - youtube, rails
categories:
  - Ruby
---
I integrated the Youtube REST API into my pet project in about thirty minutes tonight.  It&#8217;s amazing how far the Internet has come in providing solid, useful services.  The QuartzRuby guys have published [active_youtube][1], a simple ActiveResource wrapper to make integration with your Rails application easy.  The problem is really one of documentation: aside from the simple examples, there&#8217;s none.  And there was my problem: now that I had a Youtube::Video object, what can I do with it?  This is not a trivial problem &#8211; ActiveResource just acts as a wrapper around the XML data that Youtube sends me which means the object is just a glorified tree of data and can change based on the XML that is sent.

irb to the rescue!  Ruby&#8217;s dynamic nature is the perfect complement to this conundrum.  Playing with the objects in the console answered all my questions in 5 minutes.  
``

<pre>&gt; script/console

&gt;&gt; search = Youtube::Video.find(:first, :params =&gt; {:vq =&gt; 'ruby', :"max-results" =&gt; '5'})

[a lot of junk]

&gt;&gt; video = search.entry.first

[slightly less junk]

&gt;&gt; video.attributes.keys

=&gt; ["rating", "category", "comments", "title", "published", "statistics", "author", "id", "content", "link", "group", "updated"]

&gt;&gt; video.group.attributes.keys

=&gt; ["thumbnail", "category", "player", "title", "description", "content", "duration", "keywords"]</pre>

As you can see, ActiveResource creates accessor methods for the attributes automatically. You can traverse the XML tree easily with this method and determine the exact data required for your site.

 [1]: http://www.quarkruby.com/2008/2/12/active-youtube
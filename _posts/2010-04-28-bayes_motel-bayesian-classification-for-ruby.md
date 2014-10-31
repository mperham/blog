---
title: 'bayes_motel &#8211; Bayesian classification for Ruby'
author: Mike Perham
layout: post
permalink: /2010/04/28/bayes_motel-bayesian-classification-for-ruby/
categories:
  - Ruby
---
[Bayesian classification][1] is an algorithm which allows us to categorize documents probabilistically. I recently started playing with Twitter data and realized there was no Ruby gem which would allow me to build a spam detector for tweets. The `classifier` gem just works on a set of text by figuring out which words appear in a category but a tweet is much more complicated than that. A tweet looks like this:

<pre lang="ruby">{:text=>"Firesale prices, too! RT @nirajc: Time to change your Facebook password. Hacker selling 1.5m accounts. http://bit.ly/dryY7",
:truncated=>false, :created_at=>"Fri Apr 23 18:26:51 +0000 2010", :coordinates=>nil, :geo=>nil, :favorited=>false,
:source=>"<a href="http://www.tweetdeck.com" rel="nofollow">TweetDeck</a>",  :place=>nil, :contributors=>nil,
:user=>{:verified=>false, :profile_text_color=>"666666", :friends_count=>226, :created_at=>"Wed Oct 08 07:15:23 +0000 2008",
:profile_link_color=>"2FC2EF", :favourites_count=>12, :description=>"All the news that's fit to tweet (and most that isn't)",
:lang=>"en", :profile_sidebar_fill_color=>"252429", :location=>"Brooklyn, NY", :following=>nil, :notifications=>nil,
:time_zone=>"Eastern Time (US &#038; Canada)", :statuses_count=>981, :profile_sidebar_border_color=>"181A1E",
:profile_image_url=>"http://a1.twimg.com/profile_images/834612904/Photo_on_2010-04-16_at_00.38__3_normal.jpg",
:profile_background_image_url=>"http://s.twimg.com/a/1271725794/images/themes/theme9/bg.gif", :protected=>false,
:contributors_enabled=>false, :url=>"http://www.aolnews.com", :screen_name=>"carlfranzen", :name=>"Carl Franzen",
:profile_background_tile=>false, :profile_background_color=>"1A1B1F", :id=>16645918, :geo_enabled=>false,
:utc_offset=>-18000, :followers_count=>174}, :id=>12717456105}
</pre>

As you can see, a tweet is just a hash of variables. So which variables are a better indicator of spam? I don&#8217;t know and chances are you don&#8217;t either. But if we create a corpus of ham tweets and a corpus of spam tweets, we can train a Bayesian classifier with the two datasets and it will figure out which variable values are seen often in spam and which in ham.

Some variables don&#8217;t work, statistically speaking:

*   **:id, :created_at** &#8211; these variables are unique for each tweet which means they are useless for classification. BayesMotel will trim any variable values that don&#8217;t appear in more than 3% of the corpus.
*   **:followers_count** &#8211; this is probably a pretty good spam/ham indicator in general, but not as a simple number. There are millions of possible values (@aplusk has 4.5 million followers) but we are only training on hundreds or thousands of tweets. What would be better is the binary logarithm of the followers_count to create discrete buckets: 32-64 followers = 5, 1024-2048 = 10 and so on. I&#8217;d bet any tweet with a value greater than 12 or so (i.e. 4096+ followers) is very likely to be ham. 

There are additional things we could do to improve our spam detector:

*   We aren&#8217;t deep inspecting the value of the tweet text. It might be useful to have variables like &#8220;text\_link\_count&#8221; or &#8220;text\_hashtag\_count&#8221; to provide basic metrics for the tweet text content.
*   We aren&#8217;t performing any timeline checks or storing previous tweet state &#8211; spammers tend to tweet the same text over and over and their tweets all contain links. This is beyond the scope of a generic Bayesian system.

I wrote [bayes_motel][2] based on my research this last weekend. Give it a try and send a pull request if you make changes you&#8217;d like to see. The test suite gives more detail about the API and has a few thousand tweets to use as sample data. Happy coding!

 [1]: http://en.wikipedia.org/wiki/Naive_Bayes_classifier
 [2]: http://github.com/mperham/bayes_motel
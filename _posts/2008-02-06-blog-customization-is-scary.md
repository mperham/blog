---
title: Blog Customization is Scary
author: Mike Perham
layout: post
permalink: /2008/02/06/blog-customization-is-scary/
keywords:
  - php, code, quality
categories:
  - Software
---
I recently wanted to customize my new Cutline theme to display a random header image with every page load. I noticed that the image was static based on the template. I went into the code and what did I see?  
`<br />
if page == type1<br />
    render image 1<br />
if page == type2<br />
    render image 2<br />
`

That&#8217;s paraphrased but the gist of it, not great but pretty average PHP in my experience. So I googled to see how to load randomly instead and I found blog postings by people that have created CSS hacks, use a remote call to a random number generator, and other insane ideas. It&#8217;s amazing the lengths people go to when they don&#8217;t actually understand the capabilities offered by a system. See [The Daily WTF][1] for daily examples of such insanity.

Here&#8217;s what I came up with:

<img src=&#8221;/images/header_<?php echo rand(1, 5); ?>.jpg&#8221;/>

Crazy, I know.

 [1]: http://www.thedailywtf.com
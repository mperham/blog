---
title: Library Versioning
author: Mike Perham
layout: post
permalink: /2014/09/01/library-versioning/
categories:
  - Software
---
It's time for our annual Semantic Versioning argument/gripefest! This time it was kicked off by Jeremy Ashkenas's post [why he believes Semantic Versioning is wishful thinking][1]. Olivier Lacan [chipped in further thoughts on the importance of a changelog.][2]

Yes, Semantic Versioning is wishful thinking. Change cannot be compressed into three version numbers to guarantee safe upgrades. Developers get things wrong and forget changes such that versioning often isn't correct, even if they wanted to follow SemVer exactly<sup id="fnref-1785-1"><a href="#fn-1785-1" rel="footnote">1</a></sup>. I thought I would write down my own versioning policies as another example for people to consider.

<!--more-->

**It's all about Change**

If you aren't keeping a well-curated project changelog, users will hate you. This is non-negotiable <sup id="fnref-1785-2"><a href="#fn-1785-2" rel="footnote">2</a></sup>.

Any non-trivial change should have a note in the changelog explaining it. I mentally categorize these changes into three buckets:

1.  Major &#8211; *API contracts change and user code will break!* Major changes should planned out carefully and upgrade notes documented well<sup id="fnref-1785-3"><a href="#fn-1785-3" rel="footnote">3</a></sup>. I try to accumulate many breaking changes over the course of a year; major bumps must be a rare occurrence because they require active participation from your users. Make this as painless as possible or you quickly lose your user's trust.
2.  Minor &#8211; *cool new features are rolled out or existing features are refactored enough that code relying on implementation details could break.* For instance, if I change how Sidekiq loads Rails code, I automatically consider that a minor bump because auto-loading and eager-loading is a hairy beast. Stuff probably won't break but just in case&#8230;
3.  Patch &#8211; *bug fixes, minor new APIs.* Miscellaneous improvements, unlikely you'll need to know about these changes but they are still documented.

My versioning policy encapsulates those buckets and the changes within a given release. Depending on your own bravery, you can lock to a precise version number or allow patch or minor upgrades. This versioning combined with a reliable, curated changelog allows the user to make their own decisions about upgrading versions and easily investigate any breakage or unexpected behavior after an upgrade.

<strong>Footnotes</strong>

<ul>
<li id="fn-1785-1">
  One example of my own versioning screw-up: Sidekiq 3.2.2 no longer worked on Ruby 1.9. Even though Ruby 1.9 hasn't been supported in Sidekiq 3 for months, several users were using it and complained. This change should have been rolled out as a 3.3.0 minor bump, not a patch release.&#160;<a href="#fnref-1785-1" rev="footnote">&#8617;</a>
</li>
<li id="fn-1785-2">
  Here's <a href="https://github.com/mperham/sidekiq/blob/master/Changes.md">Sidekiq's changelog</a>.&#160;<a href="#fnref-1785-2" rev="footnote">&#8617;</a>
</li>
<li id="fn-1785-3">
  Here's <a href="https://github.com/mperham/sidekiq/blob/master/3.0-Upgrade.md">Sidekiq 3.0's Upgrade Notes</a>.&#160;<a href="#fnref-1785-3" rev="footnote">&#8617;</a>
</li>
</ul>

 [1]: https://gist.github.com/jashkenas/cbd2b088e20279ae2c8e
 [2]: http://olivierlacan.com/posts/the-semantics-of-software/

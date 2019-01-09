---
author: Mike Perham
categories:
- Ruby
date: 2010-11-25T00:00:00Z
title: Ruby Stdlib is a Ghetto, Pt. 2
url: /2010/11/25/ruby-stdlib-is-a-ghetto-pt-2/
---

[Eric Hodel][1] disagreed with my recent point. I didn't present much of an argument because I didn't think there was much disagreement with my point. Let me elaborate.

**1) It's full of unnecessary libraries that should be separately distributed**

The Ruby community, at least in the US, has proven to be very open to change, see Rails 1, 2 and 3 for example. Sometimes you have to break compatibility to advance the state of the art. Continuing to bundle inferior implementations means that we have this compatibility albatross around our neck while stronger third-party libraries don't pop to the top of the ecosystem. [Some random dude][2] said it better than me. [Some other dude agreed][3], REXML in this case should be unbundled.

I was proposing unbundling DRb and Tk not because their codebase sucks but simply because they aren't used by the vast majority of the Ruby community. treetop and shoes are very useful libraries also but they don't belong in stdlib either.

I'm not proposing we do this in the next 1.9.2 patch, but for 2.0, sure. Now that rubygems is in core (thanks Eric!), I think we should be aggressive in unbundling everything that can be unbundled.

**2) It's (still) too hard to contribute**

The Net::HTTP docs haven't been touched AFAICT in 5 years. They're full of broken English and rudimentary examples. I hear people complain about it all the time, why hasn't anyone fixed it? Maybe everyone is lazy or maybe the contribution process remains too steep for most.

Net::HTTP had performance issues in the 1.8.6 era, sounds they have been fixed. The API is still poor and poorly documented IMO. Just about every HTTP library has a better API IMO, e.g. Typhoeus, httparty and rest-client. As someone else pointed out, Ruby really does need an http API in core though, if not just for Rubygems to use.

I would love to see ruby-core treat git as a first class citizen and allow pull requests and git email patches against <http://github.com/ruby/ruby>. If this is the case today, please let me know. I will be the first to submit a pull request for better net/http docs.

 [1]: http://blog.segment7.net
 [2]: http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-core/32078
 [3]: http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-core/32012

---
author: Mike Perham
categories:
- Software
date: 2014-03-08T00:00:00Z
title: Dipping a Toe into Open Source
url: /2014/03/08/dipping-a-toe-into-open-source/
---

This is an excerpt from the foreword I wrote for Brandon Hilkert's new e-book, [Build a Ruby Gem][1].

I was a junior in college when I published my first open source program. It was Fall 1995 and Windows NT 3.5 had this fat and slow interface for launching applications. Windows 95 had an awesome new Start bar and so the answer was obvious: I decided I wanted to learn how to program the new Win32 API and solve my own problem at the same time. I set to write a lighter-weight, fast application launcher in the vein of the Start bar called [AppBar][2].

<!--more-->

I spent weeks poring over what little information I could find &mdash; mostly MSDN API documentation &mdash; and with a lot of experimentation got something that worked. After a month or two, I released my first version to the public with the full source code to download. Given that few others did it, why did I include the source code and why does anyone choose to publish open source?

Ultimately I believe open source depends on [enlightened self-interest][3]. By each developer giving a little, we collectively gain a lot. In my case, I enjoyed the process of building AppBar but hated the near-vertical learning curve. Without non-trivial code samples it was easy to grow frustrated. By giving a non-trivial code sample to the world, I did two things:

1.  Provided an example for other developers to follow; and
2.  Flattened the learning curve slightly for other developers.

Today's world has improved radically since then: open source has become mainstream and services like GitHub, Google and Stack Overflow have improved the lives of millions of developers by hosting orders of magnitude more code and documentation than available to me in 1995. The role of a programmer has gone from one of experimentation and discovery due to lack of information to one of search and filtering due to an abundance of information. In my experience this is a huge improvement: when everything is open, quality improves dramatically.

Since 2007 I've worked primarily with Ruby and published a dozen or so Rubygems. All of those gems started for the same reason: I had a problem I wanted to solve. Of course self-interest is still at work: if people use my code to solve their own problems, my reputation grows within the community and a higher salary and increased job security should follow. Everybody wins.

Open source has another benefit: that same self-interest brings together developers interested in solving a common problem. I've never met the author of this e-book, Brandon Hilkert, in person but he's a committer on my Sidekiq project because he built Sidekiq's beautiful real-time Dashboard. In return for improving my project, he learned a lot, solved a problem he had and improved his own reputation. We both won.

The Ruby community is quite possibly the most open source friendly of all programming language communities, the Rubygems service makes it simple to distribute your gems to the world and GitHub provides an amazing hosting and collaboration platform for open source projects. The time has never been better to jump in, get your hands dirty solving a problem and give back your own solution to the community. Everybody wins.

 [1]: http://brandonhilkert.com/books/build-a-ruby-gem/
 [2]: http://perham.net/mike/cornell/appbar/
 [3]: https://en.wikipedia.org/wiki/Enlightened_self-interest

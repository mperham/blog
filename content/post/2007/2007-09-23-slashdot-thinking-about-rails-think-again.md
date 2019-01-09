---
author: Mike Perham
categories:
- Rails
date: 2007-09-23T00:00:00Z
keywords:
- rails scalability ruby performance
title: Slashdot -- Thinking about Rails? Think Again
url: /2007/09/23/slashdot-thinking-about-rails-think-again/
---

Interesting article on a high profile failure for Rails. There are two things that strike me here:

1) The idea of a single technology being a silver bullet. Thousands of projects have failed in the IT world when someone decided they wanted a clean slate with the latest technology (e.g [Netscape][1]). There's mounds of data suggesting that refactoring is almost always a better solution.

2) Rails and Ruby have a reputation as slow. And it's true. There's performance gold to be mined in those hills. *But so did Java when it came out.* Java was slow as a dog but it was such a better language for writing applications that it quickly flourished and the speed improved dramatically. The Ruby world desperately needs a company which can put a team in place dedicated to speeding up the Ruby VM. There are efforts underway (e.g. [Rubinius][2], [YARV][3]) but they are one man efforts (!) taking years to achieve. The one thing the open source world is bad at is solving problems which take man-years. But if the value is there, the problems will be solved.

[Thinking about Rails? Think Again ][4] ([Discussion][5])

 [1]: http://www.jwz.org/gruntle/nomo.html
 [2]: http://rubini.us/
 [3]: http://www.atdot.net/yarv/
 [4]: http://www.oreillynet.com/ruby/blog/2007/09/7_reasons_i_switched_back_to_p_1.html
 [5]: http://developers.slashdot.org/article.pl?sid=07/09/23/1249235

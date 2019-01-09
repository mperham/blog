---
author: Mike Perham
categories:
- Ruby
date: 2011-06-01T00:00:00Z
title: Optimizing Heroku
url: /2011/06/01/optimizing-heroku/
---

I spent some time recently playing with a trivial Rails 3 app using [girl_friday][1] and learned a few interesting things:

*   Michael's post on [using Unicorn with Heroku][2] is a fantastic idea and great way to improve the efficiency of your Heroku application's web dynos.
*   Heroku imposes a limit of 15 threads per Ruby process (there is an open question about this, it might just be a bug in the Heroku Cedar stack, which is still beta). If you are using thin, you get 1 process and 15 threads per dyno. If you are using Unicorn, you get 3 processes<sup>*</sup> and 45 threads. **UPDATE: I don't believe Heroku has a thread limit, just a memory limit.**
*   girl\_friday defaults to 5 threads per queue. With the thread limit on Heroku, you'll want to carefully ration the size of each queue. girl\_friday's Rack status app can tell you at runtime which queues are busy and which are quiet for tuning purposes.
*   girl_friday can, in many cases, replace or dramatically reduce your need for separate worker dynos, saving you money.

* Where 3 is based on the memory consumption of your application. YMMV.

Unicorn appears to work great with girl_friday and Heroku's free service level actually becomes useful for non-trivial applications with these optimizations. Know any other tips? Let me know!

 [1]: http://mperham.github.com/girl_friday
 [2]: http://michaelvanrooijen.com/articles/2011/06/01-more-concurrency-on-a-single-heroku-dyno-with-the-new-celadon-cedar-stack/

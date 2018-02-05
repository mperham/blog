+++
date = "2018-02-05T09:00:00-08:00"
title = "Happy 6th Birthday, Sidekiq"
+++

<div style="float: right; padding-left: 10px">
<figure><img src="//www.mikeperham.com/images/sidekiq.png" width="400"/></figure>
</div>

[Six years ago I shipped Sidekiq v0.5.0](/2012/02/07/sidekiq-simple-efficient-messaging-for-rails/) and changed my life.
I talked to some developers recently:

> "I had been working in Go for a while but I kept coming back to Ruby
> because Sidekiq makes everything so fast and easy to scale."

This is my recipe for success.
Sell a product developers want because it makes their job so much easier.
You don't need a sales force when developers evangelize your product to every new company they join.

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">My favorite quote from this AMA (with which I wholeheartedly agree) is in regards to Sidekiq: “... rarely does infrastructure so keenly understand what developers, infrastructure engineers, and operators will want out of it.” <a href="https://twitter.com/mperham?ref_src=twsrc%5Etfw">@mperham</a> <a href="https://t.co/RCdG9gwtDV">https://t.co/RCdG9gwtDV</a></p>&mdash; John K Sawers (@johnksawers) <a href="https://twitter.com/johnksawers/status/959604621181366272?ref_src=twsrc%5Etfw">February 3, 2018</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

2017 revenue was right on target, about 40% higher YoY.
Nice, steady organic growth with little marketing on my part.
Why burn yourself out chasing arbitrary growth targets from investors?
Profitable?  Yes.  Growing?  Yes.
Irie, mon.

## Today is a BIG DAY!

I'm shipping several releases today:

* Sidekiq 5.1 now has global job death handlers and enables the ActiveRecord query cache by default.
  [Changes](https://github.com/mperham/sidekiq/blob/master/Changes.md#510)
* Sidekiq Pro 4.0 removes deprecated APIs and adds a new **experimental** feature: batch death.
  Now if a batch job dies, it marks the entire batch as dead also (since it will never succeed).
  New APIs allow you to enumerate dead Batches.
  Feedback is requested here, is it useful?
  What further refinements would you like to see?
  [Pro Changes](https://github.com/mperham/sidekiq/blob/master/Pro-Changes.md#400)
* Sidekiq Enterprise 1.7 adds support for [**long-running jobs and rolling restarts**](https://github.com/mperham/sidekiq/wiki/Ent-Rolling-Restarts).
  Signal USR2 and a Sidekiq process will gracefully exit once all jobs are complete, even if those jobs take hours to complete.
  This has been a hugely requested feature and it took me a while to figure out how to implement it.
  [Ent Changes](https://github.com/mperham/sidekiq/blob/master/Ent-Changes.md#180)

<div style="float: right; padding-left: 10px">
<div class="panel panel-danger">
  <div class="panel-heading">
    <h2 class="panel-title"><b>Gotta have it?</b></h2>
  </div>
  <div class="panel-body">
    <p>
      Purchase Sidekiq Pro or Sidekiq Enterprise at <a href="https://sidekiq.org">sidekiq.org</a>.
    </p>
  </div>
</div>
</div>

One of my goals for this year is to slow the rate of releases.
There were 12 Sidekiq releases last year but it's been 4 months since Sidekiq 5.0.5 was released.
Ideally I want quarterly maintenance releases.

Lately my biggest problem has been Gmail's Spam folder.  For the last
month or two, a very high
percentage of customer receipts and welcome emails are winding up in the
Spam folder for some reason, despite me sending a very low daily volume from
my own email account. I can't explain it or debug it and feel pretty
powerless. Any email delivery wizards have ideas? My email is in the footer.

## Faktory

I also introduced [Faktory](http://contribsys.com/faktory/) last year.
This is the first step in my long-term plan to bring Sidekiq goodness to all programming languages.
I'll be working on Faktory Enterprise over the next few months and hopefully have it for sale by the end of 2018.

## More Information

Many, many people have asked me questions about sustainable open source
and following a similar path with their project.
The [Indiehackers interview](https://www.indiehackers.com/businesses/sidekiq) I did a year ago proved extremely popular and resonanated with many people.
Want to discuss more, ask questions?
Got an open source project you want to make sustainable?
Stop by my weekly [Happy Hour](https://sidekiq.org/support.html) and let's chat.

---
title: "Five Years"
author: Mike Perham
layout: post
published: true
permalink: /2017/02/06/five-years/
---

Five years ago, I published v0.5.0 of [a little project](http://sidekiq.org) I had great hopes for.
Here we are five years later: I've gone from selling $50 licenses to negotiating five-figure enterprise
deals with the Fortune 500.  Five five five!

# Gimme Five!

![five](/images/highfive.jpg)

# By The Numbers

<style>
table {
  border-collapse: separate;
  border-spacing: 0;
  border: 1px solid #000;
}

th, td, caption {
  border: 1px solid #000;
  padding: 0.3em;
}
</style>
<table width="100%">
<tr><th>&nbsp;</th><th>1st Birthday</th><th>2nd Birthday</th><th>4th Birthday</th><th>5th Birthday</th></tr>
<tr><th>Downloads</th><td>214,300</td><td>1,192,259</td><td>5,505,145</td><td>11,260,039</td></tr>
<tr><th>Stars</th><td>2144</td><td>3535</td><td>5846</td><td>7087</td></tr>
<tr><th>Closed
Issues</th><td>663</td><td>1420</td><td>1887</td><td>2378</td></tr>
<tr><th>Forks</th><td>266</td><td>563</td><td>1003</td><td>1247</td></tr>
<tr><th>Closed PRs</th><td>228</td><td>380</td><td>836</td><td>938</td></tr>
<tr><th>Versions</th><td>44</td><td>74</td><td>110</td><td>127</td></tr>
<tr><th>Customers</th><td>25</td><td>200</td><td>675</td><td>726</td></tr>
<tr><th>Employees</th><td>0</td><td>0</td><td>1</td><td>1</td></tr>
</table>
<br/>

# 2016 Year in Review

* Sidekiq
  - Rails 5.0 support
  - Dropped Sinatra dependency
  - 16 bug fix releases
* Sidekiq Pro
  - timed\_fetch and super\_fetch algorithms
  - 17 bug fix releases
* Sidekiq Enterprise
  - Job data encryption
  - Multi-Process with memory monitoring
  - Web UI authorization

# You Want Five?

[Sidekiq 5.0 beta](https://github.com/mperham/sidekiq/issues/3301) is now
ready for testing in non-production environments.  The internals have
been redesigned to work better with Rails 5.0.  It no longer supports
older Rubies: Ruby 2.2.2+ only.  Read the [upgrade notes](https://github.com/mperham/sidekiq/blob/5-0/5.0-Upgrade.md) for more details.

    gem 'sidekiq', '5.0.0.beta1'

I still believe Ruby is the most fun, most flexible, highest level language
out there for building business applications and Sidekiq is the best
framework for processing business transactions.  The two are a potent
combination.

Here's to another great five years!

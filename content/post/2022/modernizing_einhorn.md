---
title: "Modernizing Einhorn"
date: 2022-07-14T08:41:10-07:00
publishdate: 2022-07-14
lastmod: 2022-07-14
draft: false
tags: []
---

[Einhorn](https://github.com/contribsys/einhorn) is a Ruby gem which provides the ability to manage multiple forked processes of Unix services.
Stripe originally built Einhorn to manage their internal collection of
services in production but stopped actively maintaining the gem several
years ago.
I recently asked for and was granted ownership of the gem so that I could provide maintenance going forward.
This blog post is meant to document how I took over and what I did, I hope others find this interesting and perhaps even useful.

## Why?

Sidekiq Enterprise uses Einhorn as a key component in the [Rolling Restarts](https://github.com/mperham/sidekiq/wiki/Ent-Rolling-Restarts) feature.
It is a business risk for my commercial software to depend on an unmaintained component.

## An Issue Appears and A Risk Manifests

Recently a Sidekiq Enterprise user reported that [Einhorn no longer works with Ruby 3.1](https://github.com/mperham/sidekiq/issues/5400) due to
changes in the YAML library.
Since there was no maintainer, there was no way to fix this issue;
I had to appeal to a higher power: Stripe.
I contacted two Stripe developers, noted the issue and offered to take over maintenance of Einhorn.
The Stripe developer council met, berobed, in their torch-lit underground lair and decided this was acceptable to them.
Within a few days I was granted ownership of the gem at Rubygems.org and the project repo was moved to `contribsys/einhorn`.
I've got root!

## Getting Started

Taking over a new codebase is always scary.
The first step for me, before making any changes at all, is to get the test suite running successfully in your local environment.
I did not know what the "normal" output would look like but thankfully nothing looked odd or scary.
There were a bunch of warnings and one error due to a deprecated API removed in Ruby 3.0 but we'll fix that soon.

You may elect to read through the codebase now if you haven't already.
When I read a codebase, I'm not looking for anything in particular but rather noting the various classes and modules, reading any comments and hunting for any sketchy looking code.
I can't really define "sketchy looking" but I Know It When I See It™.
Obviously thread-unsafe code, extreme amounts of meta-programming, or an unreasonably large number of dependencies are all red flags for me.

## Deciding What to Support

Part of taking over maintenance is deciding what versions of dependencies you are going to support.
Thankfully at runtime Einhorn only depends on Ruby itself.
Since Einhorn is a decade old, I installed the oldest Ruby I could easily (2.6) and made sure the test suite ran.
 
Einhorn's README says it supports Ruby 2.0 and up but that line is many years old and Ruby 2.0 doesn't install on most modern machines. I decided to go with Ruby 2.5 as the minimum version as that version is also supported by Rails 6.0. I could have chosen Ruby 2.7, which is required by Rails 7.0, but that felt like it would be a pretty large jump for existing apps which want to upgrade to my version of Einhorn.

Anything older than Ruby 2.5 really becomes difficult for me to support. That version is 5+ years old and it's hard for me to remember quirks and subtleties that long ago. If you want to use a really old Ruby, you give up any hope of support. That's a constant trade-off in the software industry: keep up or be left behind.

## Project Scaffolding

Since Einhorn hadn't seen active maintenance in many years, I went through the various project files (README, Rakefile, Gemfile, gemspec, etc) and cleaned up anything weird or unconventional.
I removed any unnecessary or unused development dependencies.
I fixed the test suite error and warnings.
Running the test suite after every change gave me some confidence I wasn't breaking anything.

I started a changelog so users have a dense summary of notable changes. Always [keep a changelog](https://keepachangelog.com)!

Finally the most important thing I did was bump the version to v1.0.
When you take over maintenance and enforce new support policies, it's important to demarcate that to the user.
Users can install the existing 0.x versions but my support starts with 1.0.

## Code Changes

Since we're bumping the major version, I also want to remove anything deprecated.
Turns out there were three deprecated items noted in the codebase.
I removed them, any associated tests and verified the test suite still passed.

But, Mike, what about the YAML issue???
I spent two days trying to fix the original YAML issue which started this whole process and was stumped.
To be honest, I was shocked; I can't remember the last time a reproducible bug stumped me but the Einhorn test suite is unusually complex because it deals with low-level communication between Unix processes.
In desperation I tweeted out a bug bounty: $500 to the first person to track down the problem and get the test suite running green in all Rubies.
Within two hours I had a fix from @casperisfine!!!
The [pull request](https://github.com/contribsys/einhorn/pull/106) gives the full context but it turns out the method signature for `YAML.safe_load` has changed pretty radically since Ruby 2.5 and required some deep Ruby magic to determine how to call it correctly.

@casperisfine requested that I donate the money to charity. I sent $500 to the [Feminist Center](https://feministcenter.org/donate/), a non-profit health clinic in Atlanta, GA, location of Railsconf 2023.

## Extras

I'm adding two things which are technically optional but really mandatory in my opinion.

1. Update the codebase to `standardrb` formatting. Having a consistently formatted codebase makes for a nicer experience when reading or accepting pull requests from others.
2. Add CI. Integrate a test matrix against Ruby 2.5+ so we can be sure any future code changes will work against all supported Rubies.

These will take me a day or two to implement but they are really designed to minimize future maintenance work.
I don't envision Einhorn changing much, it does what it says in the README and nothing more.
I plan to treat it as feature frozen except to ensure it runs on future Rubies.

## Future Work

The test suite is rather slow at 28 seconds. Maybe we could speed that up?
There are unit and integration test components to the suite but I don't know a lot about the suite so there's no point in conjecture.
I'll have to profile it at some point if I really want to spend time on it.
It's not high on my priority list but others are welcome to give it a shot if the task seems interesting.

I also don't yet have a good sense for how well the test suite covers the codebase.
We could generate a code coverage report and see if we can add more tests to exercise more code.
Again, not high priority but if that sounds interesting to you, open an issue and tell us what you learn.

## Conclusion

This is not the beginning of the end but rather the end of the beginning;
maintenance is all about the long game.
The project is in good shape and [v1.0 is now available](https://github.com/contribsys/einhorn/blob/main/Changes.md#100)!

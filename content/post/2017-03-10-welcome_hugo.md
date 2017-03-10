+++
date = "2017-03-10T09:15:20-08:00"
title = "Welcome, Hugo"
+++

I'm trying out a new blogging system after using Jekyll for a few
years.

## A Little History

I've been blogging personally since 2003 or so and professionally since
2007 (when I started my Ruby career).  I started on a self-hosted
Movable Type install and migrated to self-hosted Wordpress in ~2009 but
the administrivia and complexities of those systems wore me down.  I
made the decision to wind down my own server and move to hosted
services, like GitHub Pages, after hearing about the hundredth
Wordpress security breach.  Since Ruby is my jam, I
selected Jekyll, a static site generator written in Ruby.

## Jekyll

[Jekyll](http://jekyllrb.com/) was a refreshing change because everything is flat files and
static content.  No SQL database of content, no server to administer.
For setup, you have a Gemfile with the `github-pages` gem in it and
everything is installed for you by Bundler.

All is not perfect though:

1. that one gem requires **74** dependent gems.
2. I could not figure out an easy workflow for creating a post, seeing
   it while I authored it despite reading the docs many times.
3. It took 5-6 seconds to rebuild my site everytime I wanted to preview
   a content change, incremental builds did not work for me.

## Hugo

<img class="img img-responsive pull-right" width="300" src="https://gohugo.io/img/hugo.png"/>

[Hugo](https://gohugo.io) is a static site generator written in Go which solves many of those
problems.  Things I love so far:

1. Easy install with one 17MB binary by running `brew install hugo`
2. Fast: complete site build takes 300ms by running `hugo`
3. I can preview my entire site by running `hugo server` and livereload just magically works: I can see content changes
   immediately in the browser, without even needing to hit the refresh
   button

Things I don't like or I'm worried about:

1. Lots of open issues/PRs.
2. Large Go codebase, Go is not a terse language.
3. Overly complex: archtetypes, taxonomies, tags are all things I don't need.
   Instead of choosing one config format, they support three!

We'll see how the project continues over the next few years.
I'd love to see a site generator written in Crystal, a fast, higher-level language
that has most of the advantages of Go while also being more terse.

+++
date = "2017-11-13T08:25:10-08:00"
title = "Getting Started with Faktory"
+++

When I [unveiled my new background job
system](//www.mikeperham.com/2017/10/24/introducing-faktory/) Faktory
three weeks ago, I didn't have an easy path for people to install and
try Faktory themselves.  Now there is; let's get it running!

![faktory](//www.mikeperham.com/images/faktory-logo.png)

## Homebrew

If you are running macOS, it's installable with Homebrew:

```
> brew tap contribsys/faktory
> brew install faktory
...two minutes pass...
> faktory
```

Now open your browser to <http://localhost:7420>

## Docker

If you have Docker, it's easy to pull an image:

> docker pull contribsys/faktory:latest

The command to run it is rather involved, [see the description](https://hub.docker.com/r/contribsys/faktory/).

## Workers

Faktory is only one half of the puzzle, now you need to install a worker
package which can execute jobs that are pushed to Faktory.  I launched
Faktory with Ruby and Go worker packages, now there are a half dozen
libraries for other languages:

* [faktory\_worker\_ruby](https://github.com/contribsys/faktory_worker_ruby) - Ruby
* [faktory\_worker\_go](https://github.com/contribsys/faktory_worker_go) - Go
* [faktory\_worker\_python](https://github.com/cdrx/faktory_worker_python) - Python
* [faktory\_worker\_php](https://github.com/basekit/faktory_worker_php) - PHP
* [faktory-rs](https://github.com/jonhoo/faktory-rs) - Rust
* [faktory\_worker\_ex](https://github.com/cjbottaro/faktory_worker_ex) - Elixir
* [faktory\_worker\_node](https://github.com/jbielick/faktory_worker_node) - Node
* [Razensoft.Faktory](https://github.com/Razenpok/Razensoft.Faktory) - .NET

Check out those projects and their README for more info on how to get
started with them.

## Ruby

If you want to use Faktory with Ruby jobs, I've written up a Getting
Started guide which shows you the few steps necessary to get jobs
running with `faktory_worker_ruby`.

[Getting Started with Faktory and Ruby](https://github.com/contribsys/faktory/wiki/Getting-Started-Ruby)

## Thanks

The response to Faktory from other open source developers has been
tremendous.  Lots of pull requests and issues reported, much discussion in the
issues and chatroom and lots of work still to be done.  Special thanks
to andrewstucki, cdrx, jonhoo, jweslley, and all the people who've
built their own worker packages.

## Wrapup

Let us know if you have any problems -- [pop into the Faktory chatroom](https://gitter.im/contribsys/faktory) and say hi or [open a new issue](https://github.com/contribsys/faktory/issues/new).

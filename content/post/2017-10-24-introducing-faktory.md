+++
date = "2017-10-24T07:00:00-07:00"
title = "Introducing Faktory"
+++

[Yesterday I explained](//www.mikeperham.com/2017/10/23/the-future-of-background-jobs/) how a good background job framework is critical to
scaling business applications.  Today, meet
[Faktory](https://github.com/contribsys/faktory).

I've spent the last six months building **Faktory**, a new background
job system which aims to bring the best practices developed over the
last five years in Sidekiq **to every programming language**.

<center><img src="http://www.mikeperham.com/images/faktory-ui.png" width="800" height="375"/></center>

## The Basics

Faktory is a server daemon which provides a simple API to produce and
consume background jobs.  Here's the chatter to create and execute
a background job:

```
> PUSH {"jid":"1238abc712","jobtype":"SomeJob","args":[1,2,"hello"],"queue":"default"}
< OK
> FETCH critical default low
< {"jid":"1238abc712","jobtype":"SomeJob","args":[1,2,"hello"],"queue":"default"}
[...do the work...]
> ACK {"jid":"1238abc712"}
< OK
```

Jobs are a small JSON hash with a few mandatory keys.
Producers PUSH a job to a queue. Consumers FETCH jobs from queues,
process them and then either ACK (success) or FAIL the job.  Faktory
will store and re-enqueue failed jobs over time just as Sidekiq does
(these are called "retries").  Networks fail and bugs happen, job retries
are critical to a "self-healing" production environment.

To execute jobs, you need a Faktory worker process which can run
your business logic in the language of your choice.  With the launch
today, I'm providing:

* `faktory` [link](https://github.com/contribsys/faktory) - high
  performance background job server
* `faktory_worker_ruby` [link](https://github.com/contribsys/faktory_worker_ruby) -
  a Rubygem which can execute jobs fetched from Faktory using Ruby,
similar to Sidekiq
* `faktory_worker_go` [link](https://github.com/contribsys/faktory_worker_go) -
  a library for building a Go-based worker process

## How It Works

Many existing job systems provide no persistence or a simple binlog
which can be replayed in case of crash.

Faktory goes further and provides the same job persistence, state management and
monitoring Web UI that Sidekiq does.  It uses
Facebook's high-performance [RocksDB](http://rocksdb.org) embedded
datastore internally to
persist all job data, queues, error state, etc.  It exposes a Web UI
(which is similar to Sidekiq's), allowing you to see the current
state of your queues, jobs and workers.

Faktory listens on port 7419 for commands and port 7420 for the Web UI.
7419 for the robot workers, 7420 for the human bosses.

## Get Started

The project is brand new so it will take a few weeks to polish the
development process.  If you are a Gopher, you can build the binary locally with Go 1.9.
If you have Vagrant 2.x running, you can run Faktory via
the Vagrant box in `build/ubuntu`.  See the [Development wiki page](https://github.com/contribsys/faktory/wiki/Development)
for more detail.

We'll eventually get some install options plugged into the
[Installation wiki page](https://github.com/contribsys/faktory/wiki/Installation).
Like all new things, it's rough today but it will get better over time.

# FAK

Q. Can I use it in production?</br>
A. It's a brand new project but only you can determine how risk tolerant you are.
I will release 1.0 when the APIs are solid and I feel it is stable.

Q. Does Faktory require Redis?<br/>
A. No. Faktory is a standalone 64-bit Linux binary; it needs a Faktory worker
process to consume jobs.  Redis -> Sidekiq == Faktory -> Faktory worker

Q. Are there other things like Faktory?<br/>
A. Yep, beanstalkd, starling, gearman and others.  Faktory aims to be
more feature-rich and better supported.  Many of Faktory's OSS competitors
are "dead" and no longer supported.  I am fortunate enough to have both
expertise in background jobs and a business model to support Faktory long-term.

Q. What's going to happen to Sidekiq?<br/>
A. Nothing.  It's stable, powerful and fully supported.  If you have a
Ruby/Rails app, it's a natural choice for background jobs.

Q. Will you have a commercial version, just like Sidekiq Pro and Enterprise?<br/>
A. If Faktory sees good uptake, likely yes in 2018.
Several features like periodic jobs, batches and unique jobs would fit
very well into a "Faktory Pro".

Q. Can I help?<br/>
A. Absolutely.  Faktory's GitHub repo is [contribsys/faktory](https://github.com/contribsys/faktory);
try it out and leave feedback.  Build a worker library in your language
of choice.  I'm fluent in Ruby/Go but not much beyond that.

Q. Can Faktory be provisioned and managed as a SaaS?<br/>
A. I have no plans to do so myself but I imagine this would be useful to many.
I would be happy to chat privately with people interested in offering
Faktory as a service, Heroku add-on, etc.

Q. Man, I love the q in Sidekiq.  Why no q?<br/>
A. Because "Faqtory" sounds like software for building this FAQ and
a multi-billion dollar congolmerate has the worldwide trademark
for "Worq".

Q. Where can I ask further questions?<br/>
A. Since you've read to the bottom, you get top sekret access to the
[contribsys/faktory](https://gitter.im/contribsys/faktory) Gitter chat room.
I'll hang out there when I can. Stop by and say hi!

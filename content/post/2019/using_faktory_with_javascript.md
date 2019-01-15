+++
title = "Using Faktory with JavaScript"
date = 2019-01-16T09:00:55-08:00
+++

[Faktory](https://github.com/contribsys/faktory) is my new polyglot background job system, allowing any programming
language to use background jobs.  I've documented how to
use Faktory with Ruby and Go as I'm an expert in both languages.
Today I wanted to step outside my comfort zone and try Faktory with a
language I barely know: JavaScript.  Let's see how easy it is for me, a noob,
to get JavaScript jobs running with Faktory!

We need three pieces for any background job system:

1. The client pushes jobs to the server.
2. The server (i.e. Faktory) manages the queues and jobs.
3. The worker pulls jobs from the server and executes them.

## Server Setup

Most importantly, you'll need the `faktory` server installed:

    brew tap contribsys/faktory
    brew install faktory

On macOS, easy.
See [Installation](https://github.com/contribsys/faktory/wiki/Installation) if you are on Linux.

## JavaScript Setup

First thing I did was install Node with `brew install node`, which got me Node 11.6.

    $ brew install node
    $ npm install faktory-worker
    + faktory-worker@2.2.3

We install the `faktory-worker` package, which is the JavaScript client/worker library
provided by [jbielick/faktory_worker_node](https://github.com/jbielick/faktory_worker_node).
We'll use it to push and fetch jobs.

## Client Script

We'll create a script to send a new job to Faktory every second.  Here we
create an `adder` job with two random integers for arguments:

```js
function randInt(min=0, max=1000) {
  return Math.floor(Math.random() * (max - min + 1)) + min
}

const faktory = require('faktory-worker');

async function createJob() {
  const client = await faktory.connect();
  const jid = await client.job('adder', randInt(), randInt()).push();
  await client.close();
  console.log("Job", jid)
  setTimeout(createJob, 1000)
}

setTimeout(createJob, 1000)
```

## Worker Script

The worker is the long-running process which fetches jobs from Faktory and
executes them.  We register the set of job types we know about and then
wait for jobs from Faktory.

```js
const faktory = require('faktory-worker');

faktory.register('adder', async (a, b) => {
  console.log("${a} + ${b} = ${a+b}")
});

faktory.work();
// send INT signal to shutdown gracefully
```

## The Result

Finally I created a `Procfile` which runs all three parts and used
foreman to run it:

```
$ gem install foreman
$ cat Procfile
faktory: /usr/local/bin/faktory
client: /usr/local/bin/python3.7 ./fclient.py
worker: /usr/local/bin/python3.7 ./fworker.py
$ foreman start
```

The output:

```
$ foreman start
12:37:31 faktory.1 | started with pid 40472
12:37:31 client.1  | started with pid 40473
12:37:31 worker.1  | started with pid 40474
12:37:31 faktory.1 | Faktory 0.9.4
12:37:31 faktory.1 | Copyright © 2019 Contributed Systems LLC
12:37:31 faktory.1 | Licensed under the GNU Public License 3.0
12:37:31 faktory.1 | I 2019-01-15T20:37:31.437Z Initializing redis storage at /Users/mikeperham/.faktory/db, socket /Users/mikeperham/.faktory/db/redis.sock
12:37:31 faktory.1 | I 2019-01-15T20:37:31.469Z Web server now listening at localhost:7420
12:37:31 faktory.1 | I 2019-01-15T20:37:31.469Z PID 40472 listening at localhost:7419, press Ctrl-C to stop
12:37:32 worker.1  | 754 + 43 = 797
12:37:33 worker.1  | 841 + 51 = 892
12:37:34 worker.1  | 706 + 756 = 1462
12:37:35 worker.1  | 187 + 343 = 530
12:37:36 worker.1  | 690 + 587 = 1277
12:37:37 worker.1  | 368 + 168 = 536
12:37:38 worker.1  | 152 + 900 = 1052
```

It works!
We are creating a job in our JavaScript client process, sending it to Faktory which distributes it to our Node worker process.
Our JavaScript client could be an Express web application or anything else.
In this way you can scale your job processing across many, many machines and workers.

Now while it is running, open your browser to http://localhost:7420
and check out the nice dashboard as your jobs process.
With the dashboard you can see jobs which have recently failed and are awaiting retry.
Got a bug in your code?
The worker will catch the exception and report the failure to Faktory so it can retry the job later.

If you're a JavaScript developer, I hope this piques your curiousity to try Faktory.
Remember Faktory's advantage is that you can push and pull jobs with any programming language.
Want to create jobs in Ruby or PHP and process them in JavaScript?
No problem!
Check out all the [different languages supported](https://github.com/contribsys/faktory/wiki/Related-Projects#language-bindings) today.

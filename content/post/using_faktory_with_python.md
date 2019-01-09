+++
title = "Using Faktory with Python"
date = 2019-01-08T10:03:54-08:00
draft = true
+++

[Faktory](https://github.com/contribsys/faktory) is my new polyglot background job system, allowing any programming
language to use background jobs.  I've documented how to
use Faktory with Ruby and Go as I'm an expert in both languages.
Today I wanted to step outside my comfort zone and try Faktory with a
language I don't know: Python.  Let's see how easy it is for me, a noob,
to get Python jobs running with Faktory!

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

## Python Setup

First thing I did was install a modern Python with `brew install
python`, which got me Python 3.7.2.

    $ brew install python
    $ pip install faktory
    Successfully installed faktory-0.4.0

We install the `faktory` package, which is the Python client/worker library
provided by [cdrx/faktory_worker_python](https://github.com/crdx/faktory_worker_python).
We'll use it to push and fetch jobs.

## Client Script

We'll create a very simple script to create a job every second.  Here we
create an `adder` job with two random integers for arguments:

```python
# fclient.py
import faktory
import random
import time

time.sleep(1)

with faktory.connection() as client:
    while True:
        client.queue('adder', args=(random.randint(0,1000), random.randint(0,1000)))
        time.sleep(1)
```

## Worker Script

The worker is the long-running process which fetches jobs from Faktory and
executes them.  We register the set of job types we know about and then
wait for jobs from Faktory.

```python
# fworker.py
from faktory import Worker
import time
import logging
logging.basicConfig(level=logging.INFO)

time.sleep(1)

def adder(x, y):
    logging.info("%d + %d = %d", x, y, x + y)

w = Worker(queues=['default'], concurrency=1)
w.register('adder', adder)
w.run()
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
10:37:21 faktory.1 | started with pid 7319
10:37:21 client.1  | started with pid 7320
10:37:21 worker.1  | started with pid 7321
10:37:21 faktory.1 | Faktory 0.9.3
10:37:21 faktory.1 | Copyright © 2019 Contributed Systems LLC
10:37:21 faktory.1 | Licensed under the GNU Public License 3.0
10:37:21 faktory.1 | I 2019-01-02T18:37:21.055Z Initializing redis storage at /Users/mikeperham/.faktory/db, socket /Users/mikeperham/.faktory/db/redis.sock
10:37:21 faktory.1 | I 2019-01-02T18:37:21.084Z Web server now listening at localhost:7420
10:37:21 faktory.1 | I 2019-01-02T18:37:21.084Z PID 7319 listening at localhost:7419, press Ctrl-C to stop
10:37:22 worker.1  | INFO:faktory.worker:Registered task: adder
10:37:22 worker.1  | INFO:faktory.connection:Connecting to localhost:7419
10:37:22 worker.1  | INFO:faktory.worker:Queues: default
10:37:22 worker.1  | INFO:faktory.worker:Labels: python
10:37:22 worker.1  | INFO:root:943 + 720 = 1663
10:37:23 worker.1  | INFO:root:131 + 259 = 390
10:37:24 worker.1  | INFO:root:272 + 304 = 576
10:37:25 faktory.1 | I 2019-01-02T18:37:25.090Z Retries processed 2 jobs
10:37:25 worker.1  | INFO:root:418 + 86 = 504
10:37:26 worker.1  | INFO:root:818 + 56 = 874
10:37:27 worker.1  | INFO:root:619 + 237 = 856
10:37:28 worker.1  | INFO:root:926 + 93 = 1019
10:37:29 worker.1  | INFO:root:481 + 812 = 1293
10:37:30 worker.1  | INFO:root:391 + 224 = 615
```

It works!
We are creating a job in our Python client process, sending it to Faktory which distributes it to our Python worker process.
Our Python client could be a Django application or anything else.
In this way you can scale your job processing across many, many machines and workers.

Now while it is running, open your browser to http://localhost:7420
and check out the nice dashboard as your jobs process.
With the dashboard you can see jobs which have recently failed and are awaiting retry.
Got a bug in your code?
The worker will catch the exception and report the failure to Faktory so it can retry the job later.

If you're a Python developer, I hope this piques your curiousity to try Faktory.
Remember Faktory's advantage is that you can push and pull jobs with any programming language.
Want to create jobs in PHP and process them in Python?
No problem!
Check out all the [different languages supported](https://github.com/contribsys/faktory/wiki/Related-Projects#language-bindings) today.

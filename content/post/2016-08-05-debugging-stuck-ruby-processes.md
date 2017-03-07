---
author: Mike Perham
date: 2016-08-05T00:00:00Z
published: true
title: Debugging stuck Ruby processes
url: /2016/08/05/debugging-stuck-ruby-processes/
---

My Ruby process has stopped doing any work, what's wrong?

This is an uncommon but occasional problem for many people, especially
with large applications using lots of native extensions.

## Step 1 - Thread backtraces

A Sidekiq process will print out the backtrace of every thread when
you send it the TTIN signal.

```
kill -TTIN <pid>
```

> Side note: YMMV for other types of Ruby processes: resque, unicorn, puma, passenger, etc.  Check
> the gem documentation or open an issue with the maintainers if it's not clear how to get
> backtraces from your process.

Reading these backtraces will tell you what your threads are doing at
that instant.  Here's an example:

```
2016-08-04T16:16:13.535Z 96660 TID-oxpb26trs WARN: Thread TID-oxpbpcmn0
2016-08-04T16:16:13.535Z 96660 TID-oxpb26trs WARN: /Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis/connection/ruby.rb:82:in `select'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis/connection/ruby.rb:82:in `rescue in _read_from_socket'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis/connection/ruby.rb:78:in `_read_from_socket'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis/connection/ruby.rb:70:in `gets'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis/connection/ruby.rb:362:in `read'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis/client.rb:262:in `block in read'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis/client.rb:250:in `io'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis/client.rb:261:in `read'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis/client.rb:120:in `block in call'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis/client.rb:231:in `block (2 levels) in process'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis/client.rb:367:in `ensure_connected'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis/client.rb:221:in `block in process'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis/client.rb:306:in `logging'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis/client.rb:220:in `process'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis/client.rb:120:in `call'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis/client.rb:209:in `block in call_with_timeout'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis/client.rb:280:in `with_socket_timeout'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis/client.rb:208:in `call_with_timeout'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis.rb:1137:in `block in _bpop'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis.rb:58:in `block in synchronize'
/Users/mike/.rubies/ruby-2.3.0/lib/ruby/2.3.0/monitor.rb:214:in `mon_synchronize'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis.rb:58:in `synchronize'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis.rb:1134:in `_bpop'
/Users/mike/.gem/ruby/2.3.0/gems/redis-3.3.1/lib/redis.rb:1179:in `brpop'
/Users/mike/src/sidekiq/lib/sidekiq/fetch.rb:36:in `block in retrieve_work'
/Users/mike/src/sidekiq/lib/sidekiq.rb:92:in `block in redis'
/Users/mike/.gem/ruby/2.3.0/gems/connection_pool-2.2.0/lib/connection_pool.rb:64:in `block (2 levels) in with'
/Users/mike/.gem/ruby/2.3.0/gems/connection_pool-2.2.0/lib/connection_pool.rb:63:in `handle_interrupt'
/Users/mike/.gem/ruby/2.3.0/gems/connection_pool-2.2.0/lib/connection_pool.rb:63:in `block in with'
/Users/mike/.gem/ruby/2.3.0/gems/connection_pool-2.2.0/lib/connection_pool.rb:60:in `handle_interrupt'
/Users/mike/.gem/ruby/2.3.0/gems/connection_pool-2.2.0/lib/connection_pool.rb:60:in `with'
/Users/mike/src/sidekiq/lib/sidekiq.rb:89:in `redis'
/Users/mike/src/sidekiq/lib/sidekiq/fetch.rb:36:in `retrieve_work'
/Users/mike/src/sidekiq/lib/sidekiq/processor.rb:86:in `get_one'
/Users/mike/src/sidekiq/lib/sidekiq/processor.rb:96:in `fetch'
/Users/mike/src/sidekiq/lib/sidekiq/processor.rb:79:in `process_one'
/Users/mike/src/sidekiq/lib/sidekiq/processor.rb:68:in `run'
/Users/mike/src/sidekiq/lib/sidekiq/util.rb:17:in `watchdog'
/Users/mike/src/sidekiq/lib/sidekiq/util.rb:25:in `block in safe_thread'
```

Backtraces look like a big, scary blob of text because they are!  Reading
a backtrace is hard and a learned skill: **you will get better at it over
time**.  Pop open a gem with `bundle open <gemname>` and navigate to the
line in the backtrace; getting comfortable with the code in the various
gems will help your debugging skills a lot.  The key line is here:

```
/Users/mike/src/sidekiq/lib/sidekiq/fetch.rb:36:in `block in retrieve_work'
```

This is a quiet Sidekiq thread that is waiting for a job from Redis.  It's paused,
doing nothing, but that's perfectly normal.

Most often with stuck processes you'll see threads paused in the mysql or
postgresql driver, waiting on query results or waiting for a lock.

## Step 2 - GDB

If the Sidekiq process doesn't output anything when you send it a TTIN
signal, that's a sign you've got a deeper problem.  Almost always the
cause is a native extension gem which is performing a long operation
without releasing the GVL.

This means Ruby can't help - we have to drop down into the bowels of
the process to understand what is wrong using the GDB debugger.  You can attach
GDB to a running process like so:

```
sudo gdb /path/to/ruby/binary [PID]
```

Now to get the thread backtraces dumped to a text file, run these
commands:

```
(gdb) set logging file gdb_output.txt
(gdb) set logging on
(gdb) set height 10000
(gdb) t a a bt
(gdb) quit
```

A Sidekiq Enterprise customer recently sent me a GDB dump that I will
use as an example.  Here's the first thread:

```
Thread 32 (Thread 0x3703 of process 40990):
#0  0x00007fff94b87db6 in __psynch_cvwait () from /usr/lib/system/libsystem_kernel.dylib
#1  0x00007fff98cab728 in _pthread_cond_wait () from /usr/lib/system/libsystem_pthread.dylib
#2  0x0000000102dbd5b3 in gvl_acquire_common ()
#3  0x0000000102db7471 in rb_thread_call_without_gvl ()
#4  0x00000001031feda1 in rsock_ipaddr () from /Users/user/.rbenv/versions/2.2.4/lib/ruby/2.2.0/x86_64-darwin15/socket.bundle
#5  0x00000001031f5c4a in sock_s_getaddrinfo () from /Users/user/.rbenv/versions/2.2.4/lib/ruby/2.2.0/x86_64-darwin15/socket.bundle
#6  0x0000000102dadee3 in vm_call_cfunc ()
#7  0x0000000102d927c9 in vm_exec_core ()
#8  0x0000000102da16d6 in vm_exec ()
#9  0x0000000102da6b03 in invoke_block_from_c ()
#10 0x0000000102d9da80 in rb_yield ()
#11 0x0000000102dbbf0c in rb_thread_s_handle_interrupt ()
#12 0x0000000102dadee3 in vm_call_cfunc ()
#13 0x0000000102d925f4 in vm_exec_core ()
```

Note that this is a C-level backtrace.  We're lower-level and have less
info available but experience helps fill in the gaps.  The thread is
calling `sock_s_getaddrinfo` which is a DNS lookup.  It looks like it
has finished the DNS lookup and is now calling `gvl_acquire_common` to
get the GVL in order to continue executing Ruby code.  It is normal
for some threads to block, waiting for the GVL, but it is not normal for
most threads to be waiting for the GVL. This was the case: dozens of
threads were blocked with that exact same backtrace.

When this happens, look for the odd threads.  20+ threads were blocked with the same
backtrace as above - you can ignore those.  But one or more threads will be
doing something else, and indeed there was this backtrace which was
completely different:

```
Thread 10 (Thread 0x2103 of process 40990):
#0  0x00007fff94b892a2 in poll () from /usr/lib/system/libsystem_kernel.dylib
#1  0x00000001035c892d in pqSocketCheck () from /usr/local/opt/postgresql/lib/libpq.5.dylib
#2  0x00000001035c87f9 in pqWaitTimed () from /usr/local/opt/postgresql/lib/libpq.5.dylib
#3  0x00000001035c5fd8 in PQgetResult () from /usr/local/opt/postgresql/lib/libpq.5.dylib
#4  0x00000001035c62be in PQexecFinish () from /usr/local/opt/postgresql/lib/libpq.5.dylib
#5  0x00000001035c31bc in PQsetClientEncoding () from /usr/local/opt/postgresql/lib/libpq.5.dylib
#6  0x000000010359d2a7 in pgconn_set_default_encoding () from /Users/user/.rbenv/versions/2.2.4/gemsets/xxx-v1.1/extensions/x86_64-darwin-15/2.2.0-static/pg-0.18.4/pg_ext.bundle
#7  0x00000001035990b7 in pgconn_init () from /Users/user/.rbenv/versions/2.2.4/gemsets/xxx-v1.1/extensions/x86_64-darwin-15/2.2.0-static/pg-0.18.4/pg_ext.bundle
#8  0x0000000102daa929 in vm_call0_body ()
#9  0x0000000102da9d82 in rb_call0 ()
#10 0x0000000102cbc969 in rb_class_new_instance ()
#11 0x0000000102dadee3 in vm_call_cfunc ()
```

Note the long pathnames at the end of the middle lines - they indicate
we're executing within a native extension: the `pg` gem which then calls
into `libpq`, postgresql's native C API.  The `pg` gem is calling `PQsetClientEncoding`
which looks like it is making a network call since I see terms like "Socket" and "poll".

Now we find the root issue: there's no GVL release in the backtrace.  MRI's API is
excellent in this regard: you should see `rb_thread_call_without_gvl` in
the backtrace to indicate that the thread is not holding the GVL.
Until that network call finishes, the entire process is locked up and
can't do anything.  Most of the time you won't notice because the network is
usually pretty fast but in the case where the network is stalled, work
grinds to a halt.

All of this assumes you can use GDB in your production environment.  If you're on
Heroku or a similar PaaS, try to reproduce the issue on your local machine or a
Linux VM.

## Conclusion

Performing a network operation while holding the GVL is a huge bug and should be fixed.
This is a current [pg bug in \<= 0.18.4](https://bitbucket.org/ged/ruby-pg/issues/245/pg-0184), filed and acknowledged.

Getting thread dumps from a stuck process is critical to diagnosing the root cause.
Reading and understanding those backtraces, both in Ruby and in GDB, is a useful skill to have
when debugging issues.  As you read more code, you'll get better and
faster at diagnosing problems.  It took me about 30 seconds to determine
the problem in the GDB dump above.

If you are a Sidekiq Pro or Enterprise customer and seeing stuck processes, don't be
afraid to gist me your GDB dumps - I'd be happy to help diagnose.

---
layout: post
title: "How does Sidekiq work?"
date: 2024-02-04 16:00:23 +0100
permalink: /sidekiq-internals/
---

2024-02-04

> This article was originally published on [DanSvetlov.me](https://dansvetlov.me/sidekiq-internals/) and is republished here with permission of the author. This article is relevant to Sidekiq v7.

[Sidekiq](https://github.com/sidekiq/sidekiq) is one of the most ubiquitous[^1] Ruby background job processors out there. To anybody who has worked with Ruby on and off Rails, it needs no introduction. Sidekiq has a 10+ year track record of being an efficient, battle-tested and simple-to-use solution for offloading the execution of application logic into the background.

It utilizes a threaded model for job processing, uses Redis as a backend and claims to have an 'at least once' semantic when it comes to processing jobs (with a caveat) in a free open-source version. Sidekiq also offers 2 additional paid versions - Pro and Enterprise, each of them introducing additional features and extensions. For obvious reasons, I will not go into the details of these versions.

This article will delve into the internals of Sidekiq to highlight its key aspects, as well as design and implementation decisions that I personally find interesting or peculiar, by diving directly into the source code and following a job through its full lifecycle.

I will not cover the user-facing API and general "how-to's" of Sidekiq. Its [wiki](https://github.com/sidekiq/sidekiq/wiki/Getting-Started) provides a better resource for this. Basic acquaintance with the library, as well as Ruby, is expected.

The code examined in this article was sourced from Sidekiq version 7.2 and Ruby 3.2 on [MRI/cruby](https://github.com/ruby/ruby). Even though the code discussed may become obsolete with newer Sidekiq versions, it would take a drastic philosophy change on the maintainers' part for the general principles and architecture to be become outdated. Nonetheless, the article could serve as a valuable resource for anyone looking to practice their systems programming skills by building a job processor.

It's worth noting that I'm neither a maintainer nor a contributor of Sidekiq. All of my observations and conclusions stem from reading the source code, comments, and discussions from issues and pull requests sourced via `git blame`.

## Booting up

I believe that the best way to get acquainted with code is by examining its entry points first. Sidekiq, being a _background_ job processor, must be initiated as a separate process. `bin/sidekiq` is the script that is used to initiate this process, with its primary responsibility being the instantiation of the `Sidekiq::CLI` singleton class.

The `CLI` object parses the configuration passed to the process as command line arguments via Ruby's [`OptionParser`](https://github.com/sidekiq/sidekiq/blob/4ec059d53dbf1de67e41e3bd1687c7d90c12d580/lib/sidekiq/cli.rb#L26-L32), and initialises the [global default `Sidekiq::Config`](https://github.com/sidekiq/sidekiq/blob/4ec059d53dbf1de67e41e3bd1687c7d90c12d580/lib/sidekiq/config.rb#L11-L35).

If a valid path to a YAML config is passed via `--config/-C` CLI argument, it will be used; otherwise, it will assume that this configuration can be found under the relative `./config` path. Alternatively it's also possible to supply a custom `--require/-R` argument that is supposed to point to the root directory of an application where the job classes are located. Configuration in that case would be sourced from `<path-specified-by-require>/config`.

If the configuration file exists, Sidekiq will evaluate it using `ERB`. This allows defining the config file as a template. However, one notable caveat is that this file will be evaluated before the Rails application or a file specified via `--require` is required, which makes referencing constants defined in the application code impossible.[^2]

Then, `queues` and `concurrency` configuration options are [populated](https://github.com/sidekiq/sidekiq/blob/4ec059d53dbf1de67e41e3bd1687c7d90c12d580/lib/sidekiq/cli.rb#L275-L277) if their values were not explicitly set. With default values, Sidekiq will process only the `default` queue and set its `concurrency` to the value of the `RAILS_MAX_THREADS` environment variable if Sidekiq is being used with a Rails application.

As a penultimate step in the configuration process, both the `queues` and `concurrency` options get set on every capsule. Capsules will be examined in detail in the following sections, but for now, capsules can be thought of as compartmentalised groups of configuration options. In a basic Sidekiq setup, capsules are not exposed to the user; however, a default capsule is implicitly used. It is possible to define custom capsules in the configuration YAML file and via `Sidekiq.configure_server`.

Finally, `CLI` instance validates that the `--require` argument points to an existing file, or, in case it points to a directory, that `config/application.rb` exists. It also checks that `concurrency` and `timeout` are positive integer numbers.

## Entering the main loop

After loading and validating the configuration, the `bin/sidekiq` executable calls `run` on the CLI instance. At this point, the application gets loaded.

If the path in the `require` config param is a directory, which is `.` by default unless explicitly configured, Sidekiq assumes that it's being [used in a Rails application](https://github.com/sidekiq/sidekiq/blob/4ec059d53dbf1de67e41e3bd1687c7d90c12d580/lib/sidekiq/cli.rb#L294-L308) and requires `rails` and `sidekiq/rails`, followed by a `require File.expand_path("#{@config[:require]}/config/environment.rb")`.

Otherwise, if `require` points to a file, that file gets required. This means that the `require` config param always has to be explicitly supplied and point to an entry point that loads the application code if used in a non-Rails application.

Calls to `Sidekiq.configure_server` and `Sidekiq.configure_client` also get evaluated during the application boot since they're typically part of the eagerly loadable application code. This setup most commonly occurs in a `config/initializers/sidekiq.rb` Rails initializer.

### Signal handling

Before proceeding to the next step in the `run` method, it might be worth refreshing our memory on what [signals](https://man7.org/linux/man-pages/man7/signal.7.html) are.

In essence, signals can be considered a type of inter-process communication. It's possible to define custom handlers for most signals, which will execute arbitrary logic once the process receives a corresponding one. One use case for signals is controlling long-lived daemon processes, such as Sidekiq. For example, Kubernetes sends a SIGTERM to pods so that they can shut down gracefully and perform necessary cleanup, which is relevant for a job processor like Sidekiq. Most modern orchestration tools and hosting platforms support graceful termination by sending either a SIGINT or SIGTERM to running processes.

With theory out of the way, let's see how Sidekiq interacts with signals [here](https://github.com/sidekiq/sidekiq/blob/4ec059d53dbf1de67e41e3bd1687c7d90c12d580/lib/sidekiq/cli.rb#L49-L74):

```ruby
self_read, self_write = IO.pipe
sigs = %w[INT TERM TTIN TSTP]
# ...
sigs.each do |sig|
  old_handler = Signal.trap(sig) do
    if old_handler.respond_to?(:call)
      begin
        old_handler.call
      rescue Exception => exc
        # signal handlers can't use Logger so puts only
        puts ["Error in #{sig} handler", exc].inspect
      end
    end

    self_write.puts(sig)
  end
rescue ArgumentError
  puts "Signal #{sig} not supported"
end
```

The first interesting thing to note is the creation of an unnamed pipe using the `IO.pipe` API provided by Ruby. Its [return value](https://github.com/ruby/ruby/blob/a7335e11e354d1ee2e15233f32f087230069ad5c/io.c#L408-L440) is a 2-member array of `IO` instances wrapping the file descriptors returned by the underlying system call ([`pipe2` or `pipe`](https://man7.org/linux/man-pages/man2/pipe.2.html) on most UNIX-like systems):

```c
int
rb_cloexec_pipe(int descriptors[2])
{
#ifdef HAVE_PIPE2
    int result = pipe2(descriptors, O_CLOEXEC | O_NONBLOCK);
#else
    int result = pipe(descriptors);
#endif

    if (result < 0)
        return result;

// ...
}
```

  
Unnamed pipes are extremely handy in forking environments since they can be used by the parent process to communicate with its children and vice versa without much complicated setup. However, Sidekiq does not employ a forking model (in a free OS version) and instead utilizes threads extensively, which all share the process's memory. So why use a pipe? Before we answer this question, let's examine what happens in Sidekiq's signal handlers.

As evident from the Ruby snippet above, Sidekiq sets up handlers for SIGINT, SIGTERM, SIGTTIN, and SIGTSTP. Each handler is defined sequentially using `Signal.trap`, which, on UNIX-like systems, internally constructs a handler and invokes the [`sigaction`](https://man7.org/linux/man-pages/man2/sigaction.2.html) system call:

```c
static sighandler_t
ruby_signal(int signum, sighandler_t handler)
{
    struct sigaction sigact, old;

  // Code that populates the sigact struct is omitted

  // Register the signal handler
    if (sigaction(signum, &sigact, &old) < 0) {
        return SIG_ERR;
    }

    if (old.sa_flags & SA_SIGINFO)
        handler = (sighandler_t)old.sa_sigaction;
    else
        handler = old.sa_handler;
    ASSUME(handler != SIG_ERR);

    // Return the previous handler of the same signal
    return handler;
}
```

As observed, this function returns an instance of a handler previously registered for the same signal.

Let's revisit the signal registration in `Sidekiq::CLI`:

```ruby
old_handler = Signal.trap(sig) do
  if old_handler.respond_to?(:call)
    begin
      old_handler.call
    rescue Exception => exc
      puts ["Error in #{sig} handler", exc].inspect
    end
  end
  self_write.puts(sig)
end
```

This code might appear confusing at first glance - how is `old_handler` being called from within a block when `old_handler` itself is the return value of the said block? To unravel this little Inception moment, consider the following facts:
- As we have seen, `Signal.trap` returns the handler that was previously registered for the signal, which is propagated from the `ruby_signal` C function. This can be an instance of `Proc` or a string. For possible string return values, you can refer to [this part of the `trap` function](https://github.com/ruby/ruby/blob/a7335e11e354d1ee2e15233f32f087230069ad5c/signal.c#L1310-L1323), which is responsible for returning the old handler to the Ruby land.
- The block passed to `Signal.trap` is not evaluated instantly; instead, it is called only when the corresponding signal is received by the process. The proc object is [stored in the global `vm->trap_list` struct](https://github.com/ruby/ruby/blob/a7335e11e354d1ee2e15233f32f087230069ad5c/signal.c#L1325).
- Local `old_handler` variable is available within a block due to the way bindings work in Ruby; `old_handler` is simply inherited by the inner scope of the block. This behavior is akin to how it's possible to reference local variables in a rescue block even if an exception is raised before they are defined.

So, `Signal.trap` converts the passed block into an instance of `Proc`, does not evaluate it, and registers it in the global `trap_list` instead. When a signal is received, the corresponding handler gets called. `old_handler` will evaluate to either a string signifying the handler behavior (e.g., DEFAULT or IGNORE), which will be the case if no custom signal traps were defined previously, or an old custom handler. Sidekiq politely handles previously defined trap handlers since it cannot make assumptions about the environment it is running in. It's possible that a developer or another library already declared a signal handler that is expected to be called.

However, the trap context ends with the signal name being written to the unnamed pipe created earlier. The fact that the exception is emitted directly to STDOUT in case it's raised instead of being logged using `Sidekiq.logger` could serve as a hint as to why the handler logic is not being evaluated directly. For the exact reason why this happens and for the actual behavior of SIGINT, SIGTERM, and other handlers, read on.
  
The rest of `run`'s method execution is spent on eagerly loading resources, namely the [Redis connection pool](https://github.com/sidekiq/sidekiq/blob/4ec059d53dbf1de67e41e3bd1687c7d90c12d580/lib/sidekiq/cli.rb#L73-L76) and the [server middleware chain](https://github.com/sidekiq/sidekiq/blob/4ec059d53dbf1de67e41e3bd1687c7d90c12d580/lib/sidekiq/cli.rb#L101-L102). This pattern is commonly used to avoid race conditions during the initialization of global resources in multi-threaded environments. The `run` method is the perfect opportunity to do so, since at this point there's only one main thread, making synchronization redundant for the creation of state. Alternatively, if the resource were lazily loadable, its accessor would have to be wrapped in a synchronization primitive such as a mutex, which would incur performance penalties for every happy path triggered, where the resource is already allocated and just has to be referenced.

Finally, `run` calls `launch` and passes the reader end of the pipe as an argument. `launch` is the method where the main thread will spend the rest of its time while the Sidekiq process is running:

```ruby
def launch(self_read)
  @launcher = Sidekiq::Launcher.new(@config)

  begin
    launcher.run

    while self_read.wait_readable
      signal = self_read.gets.strip
      handle_signal(signal)
    end
  rescue Interrupt
    launcher.stop

    exit(0)
  end
end
```

A `Sidekiq::Launcher` instance is created, and `run` is called on it. The block where this happens is wrapped in a `rescue Interrupt`.

By default, `Interrupt` is raised only when the process [does not have a custom `SIGINT` handler registered](https://github.com/ruby/ruby/blob/a7335e11e354d1ee2e15233f32f087230069ad5c/signal.c#L1105-L1109), which is not the case here as `Signal.trap` was already explicitly called with SIGINT. In that case, let's see where it might be getting raised from.

After the launcher gets commanded to run, the main thread enters an endless loop that calls `self_read.wait_readable`. This method, without a timeout argument, waits indefinitely until the underlying file descriptor has any data available to read. Whenever any signal that was trapped with `Signal.trap` earlier gets sent to the process, it will eventually be written to the writer end of the pipe and get read here. `handle_signal` will call a corresponding handler [defined in the `Sidekiq::CLI::SIGNAL_HANDLERS` hash](https://github.com/sidekiq/sidekiq/blob/4ec059d53dbf1de67e41e3bd1687c7d90c12d580/lib/sidekiq/cli.rb#L190-L217):

```ruby
SIGNAL_HANDLERS = {
  "INT" => ->(cli) { raise Interrupt },
  "TERM" => ->(cli) { raise Interrupt },
  "TSTP" => ->(cli) {
    cli.logger.info "Received TSTP, no longer accepting new work"
    cli.launcher.quiet
  },
  "TTIN" => ->(cli) {
    Thread.list.each do |thread|
      cli.logger.warn "Thread TID-#{(thread.object_id ^ ::Process.pid).to_s(36)} #{thread.name}"
      if thread.backtrace
        cli.logger.warn thread.backtrace.join("\n")
      else
        cli.logger.warn "<no backtrace available>"
      end
    end
  }
}
UNHANDLED_SIGNAL_HANDLER = ->(cli) { cli.logger.info "No signal handler registered, ignoring" }
SIGNAL_HANDLERS.default = UNHANDLED_SIGNAL_HANDLER

def handle_signal(sig)
  logger.debug "Got #{sig} signal"
  SIGNAL_HANDLERS[sig].call(self)
end
```

The key signal handlers to note are SIGINT, SIGTERM, and SIGTSTP.[^3] The former two handlers consist only of a `raise Interrupt`, which will be rescued in the `CLI.launch` loop we looked at previously. SIGTSTP is a bit different - it calls `quiet` on the `Sidekiq::Launcher` instance.

Before we dive deeper into the launcher, let's first answer why the signal handlers are not being executed directly from trap contexts and instead get sent to a pipe and processed in a main thread loop.

Any code invoked from a trap context must be reentrant. What this means in practice is that a handful of Ruby constructs and methods cannot be used inside `Signal.trap` blocks, most notably `Mutex`.

The reason why such operations are not permitted in the trap context is simple: custom signal handlers defined in Ruby (i.e., `Signal.trap` called with a block) can get executed at mostly any point in a Ruby program. This means that even thread-safe code, which may be considered 'correct' when executed concurrently, will encounter deadlocks if the signal trap code accesses any synchronization resources shared not only by other threads, but also by the main thread itself.[^4]
  
None of the Sidekiq signal handlers reference a mutex directly. However, almost all of them emit messages using `Sidekiq.logger`, which by default is a subclass of the plain Ruby `Logger` class. `Logger`, in turn, [uses a mutex](https://github.com/ruby/ruby/blob/a7335e11e354d1ee2e15233f32f087230069ad5c/lib/logger/log_device.rb#L33-L45) to synchronize writes internally:

```ruby
def write(message)
  begin
    # ...
    synchronize do # A convenience method that calls Monitor#synchronize
      @dev.write(message)
    end
    # ...
  rescue Exception => ignored
    warn("log writing failed. #{ignored}")
  end
end
```

This means that it's possible for the signal handler, which accesses the same logger instance, to be called while the main thread owns the mutex during logging.

Keeping the signal traps short and deferring the actual logic by notifying the main thread through a pipe allows for lifting restrictions that are usually applied to signal handlers.

### Managing the lifecycle

As covered in the previous section, the `Sidekiq::CLI` instance instantiates a `Sidekiq::Launcher` instance, calls `run` on it, and enters an infinite loop waiting for incoming signals. SIGINT and SIGTERM call `stop`, and SIGTSTP calls `quiet` on the launcher instance, and so far that's the extent of our knowledge of the launcher. Let's dissect it.

It's worth to note the creation of managers during initialization of a launcher:

```ruby
# Launcher

def initialize(config)
  # ...
  @managers = config.capsules.values.map do |cap|
    Sidekiq::Manager.new(cap)
  end
  # ...
end
```

Here's where the capsules come fully into the spotlight. Their configuration is done in the `Sidekiq::CLI` instance, and now they're being used to instantiate instances of `Sidekiq::Manager`. Capsules can be thought of as compartments inside a Sidekiq process. They are represented as Ruby objects containing individual `concurrency` and `queues` configuration parameters.

Without custom configuration, Sidekiq uses a single 'default' capsule implicitly, and it's possible to define custom capsules if the need arises.

Before we proceed to researching the launcher lifecycle methods, let's first go deeper down the stack for a moment and examine the key components relevant to the main processing loop.

Each capsule is manifested as a manager, serving as a container that oversees the lifecycle of a set of processors. The number of processors is determined by the `concurrency` setting. Managers provide control over their processors through publicly exposed methods such as `start`, `quiet`, and `stop`.

A processor serves as the unit of execution within Sidekiq, responsible for performing jobs. Its public API includes methods such as `terminate`, `kill`, and `start`, providing control over its execution lifecycle to its manager.

#### Starting up

Let's now return to the launcher. The following is its simplified [`run`](https://github.com/sidekiq/sidekiq/blob/4ec059d53dbf1de67e41e3bd1687c7d90c12d580/lib/sidekiq/launcher.rb#L38-L44) method:

```ruby
# Launcher

def run
  @thread = safe_thread("heartbeat", &method(:start_heartbeat))
  @managers.each(&:start)
end
```

It initially starts a heartbeat thread that dumps some stats into Redis every 10 seconds.

`safe_thread` is essentially a helper method provided by Sidekiq, which wraps the passed proc in a rescue block, calling the internal exception handler via `Config#handle_exception`. By default, this handler simply logs the exception without re-raising it.

Manager's `start` method looks like this:

```ruby
# Manager

def start
  @workers.each(&:start)
end
```

`@workers` contains instances of the `Processor` class.

Digging one stack frame deeper, here's the processor's `start` method:

```ruby
# Processor

def start
  @thread ||= safe_thread("#{config.name}/processor", &method(:run))
end
```

In a similar fashion to the launcher, a processor starts a thread that executes the `Processor#run` method. For now, let's consider it as a black box and just assume that it starts an endless loop that picks jobs from the queue and executes them.

At this point, the Sidekiq process actually starts performing enqueued jobs. However, this is not sufficient for stability, as shutdown is an inevitable part of every process lifecycle. Handling them gracefully in a job processor such as Sidekiq is arguably even more important than it is in web servers, and the reasons for this will be covered in the following sections.

#### Quieting down

As we have seen already, certain signals translate into calls to the launcher - namely `quiet` and `stop`. Let's start with `quiet` first as it usually should precede `stop`.

Here's a trimmed version of `Launcher#quiet`:

```ruby
# Launcher

def quiet
  return if @done

  @done = true
  @managers.each(&:quiet)
end
```

The early return is there in order to handle a case where the process receives several extra SIGTSTP signals.

`Manager#quiet` takes the same precaution:

```ruby
# Manager

def quiet
  return if @done
  @done = true

  @workers.each(&:terminate)
end
```

And this is how processors handle `terminate`:

```ruby
# Processor

def terminate
  @done = true
end
```

That's it. Despite its name, the method doesn't perform anything more drastic than setting an instance variable. This is where we pull the curtain on the `Processor#run` method:

```ruby
# Processor

def run
  process_one until @done
  @callback.call(self)
rescue Sidekiq::Shutdown
  @callback.call(self)
rescue Exception => ex
  @callback.call(self, ex)
end
```

This aligns with our previous assumption: the `run` method is executed within a thread spawned by the processor in its `start` method, and it enters a loop where the break condition is the `@done` instance variable being false.

It's important to realize that invoking terminate does not immediately stop the processor from processing the current job. Instead, it will continue processing the current job until it completes.

So, when `terminate` is called, the `run` method will exit the loop after finishing the current job. At this point, a `@callback` is invoked. This callback is actually a `Method` instance that wraps `Manager#processor_result`, which is passed by the manager during the initialization of each processor.

```ruby
class Manager
  def initialize(capsule)
    @done = false
    @workers = Set.new
    @plock = Mutex.new
    @count.times do
      @workers << Processor.new(@config, &method(:processor_result))
    end
  end
  
  # ...

  def processor_result(processor, reason = nil)
    @plock.synchronize do
      @workers.delete(processor)
      unless @done
        p = Processor.new(@config, &method(:processor_result))
        @workers << p
        p.start
      end
    end
  end
end
```

  
Reading through the source code of `processor_result`, it becomes clear that processors themselves are responsible for checking out of the `Manager`'s `@workers` set. Therefore, if a processor encounters a `Sidekiq::Shutdown` or any other uncaught exception, it will remove itself from the set, create a new processor in a similar manner to how it's done in `Manager#initialize`, add that processor to the set, and call `start` on it.

However, in the code path we're examining, which follows a call to `quiet`, the callback will only remove the processor from the workers set. Therefore, invoking `quiet` will cause processors to stop picking up new jobs to run, and *eventually*, the worker set will become empty. As we've already noticed, the jobs currently being executed by processors will not be abruptly halted; instead, they will continue until completion naturally.

This makes the SIGTSTP signal the perfect candidate to be sent some time before the process is terminated. `Launcher#quiet` is a way to inform Sidekiq that processors should avoid picking up new jobs after they finish processing their current ones, as the process is about to be terminated. This minimizes the need for intrusive actions when a process needs to fully stop.

#### Stopping

The `Launcher#stop` method begins with a calculation of a deadline utilizing POSIX `clock_gettime`. `CLOCK_MONOTONIC` is employed to acquire the current absolute elapsed time rather than wall clock time, which can vary unpredictably:

```ruby
# Launcher

def stop
  deadline = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC) + @config[:timeout]

  quiet
  stoppers = @managers.map do |mgr|
    Thread.new do
      mgr.stop(deadline)
    end
  end

  stoppers.each(&:join)
end
```

The default `timeout` config is set to 25 seconds and this number is not picked randomly; historically a lot of hosting platforms and orchestrators have been using a 30 second grace period for processes to react to SIGTERM gracefully. Sidekiq makes this timeout a bit lower in order to have better chances at finishing the required cleanup work.

`quiet` gets called as the first step in the `stop` method in order to minimize work that will have to be waited on in the next step. Another purpose of calling `quiet` here is to ensure that processors stop picking up new jobs in case SIGTSTP was not explicitly sent prior to SIGINT or SIGTERM:

```ruby
# Manager

def stop(deadline)
  quiet

  return if @workers.empty?

  logger.info { "Pausing to allow jobs to finish..." }
  wait_for(deadline) { @workers.empty? }
  return if @workers.empty?

  hard_shutdown
ensure
  capsule.stop
end
```

In case processors manage to finish their current work in time, they will remove themselves from their manager's `@workers` array after completing their current job. The 2 conditionals in `stop` are there to handle the happy path by preemptively terminating execution without additional unnecessary work in such cases. This is why it's important to make sure that `quiet` gets called first.

If the manager sees that there are any processors that couldn't finish immediately before the first `return if @workers.empty?` check, it must wait for them in its `stop` method. Remember that the deadline, set to 25 seconds by default, is passed down from the launcher. The `wait_for` method executes the block in a loop until the block's return value is truthy:

```ruby
# Manager

def wait_for(deadline, &condblock)
  remaining = deadline - ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
  while remaining > PAUSE_TIME
    return if condblock.call
    sleep PAUSE_TIME
    remaining = deadline - ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
  end
end
```

If there are still active processors lingering after the deadline, `hard_shutdown` is called. Here's the [body of this method](https://github.com/sidekiq/sidekiq/blob/4ec059d53dbf1de67e41e3bd1687c7d90c12d580/lib/sidekiq/manager.rb#L87-L119) with the original comments preserved:

```ruby
# Manager

def hard_shutdown
  # We've reached the timeout and we still have busy threads.
  # They must die but their jobs shall live on.
  cleanup = nil
  @plock.synchronize do
    cleanup = @workers.dup
  end

  if cleanup.size > 0
    jobs = cleanup.map { |p| p.job }.compact
    # ...
    capsule.fetcher.bulk_requeue(jobs)
  end

  cleanup.each do |processor|
    processor.kill
  end

  # when this method returns, we immediately call `exit` which may not give
  # the remaining threads time to run `ensure` blocks, etc. We pause here up
  # to 3 seconds to give threads a minimal amount of time to run `ensure` blocks.
  deadline = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC) + 3
  wait_for(deadline) { @workers.empty? }
end
```

We won't explore the functionality of `capsule.fetcher.bulk_requeue` at this point. This is one of the most critical pieces of logic in Sidekiq and for now, let's assume that, as the method's name implies, it requeues jobs.

Every processor that did not check itself out of the `@workers` array by the time `hard_shutdown` was invoked gets killed. Here's what [`Processor#kill`](https://github.com/sidekiq/sidekiq/blob/4ec059d53dbf1de67e41e3bd1687c7d90c12d580/lib/sidekiq/processor.rb#L49-L59) does:

```ruby
# Processor

def kill(wait = false)
  @done = true
  return unless @thread

  @thread.raise ::Sidekiq::Shutdown
end
```

It's similar to `quiet`, but it additionally raises a `Sidekiq::Shutdown`, a subclass of `Interrupt`, on the processor thread.

This exception being raised, however, does not impose an upper time bound on when the thread will be truly finished. That's why right after every process has been killed, the manager waits 3 seconds to give them an opportunity to terminate gracefully. We'll get to what this graceful termination consists of later.

We've explored how Sidekiq establishes the necessary class hierarchy to ensure the smooth handling of the process lifecycle. The launcher oversees managers, which in turn manage processors responsible for fetching and processing jobs. Let's now look at how the processors obtain jobs to execute.

### Queue processing

Sidekiq jobs get routed to queues. At the very least each Sidekiq installation will use a `default` queue. The queues that Sidekiq should be processing can be defined globally or on a per-capsule basis. You can specify the set of queues using the `config/sidekiq.yml` configuration file, the `-q` command-line argument, or `Sidekiq.configure_server`. This configuration populates the `queues` parameter of the `default` capsule, unless specific configuration was provided for a particular capsule in the config file or server configuration.

Eventually, all provided queue lists end up in the `Capsule#queues=` setter method, which is crucial for the queue processing logic. Here's [its contents](https://github.com/sidekiq/sidekiq/blob/4ec059d53dbf1de67e41e3bd1687c7d90c12d580/lib/sidekiq/capsule.rb#L48-L70) copied verbatim with the original comment:

```ruby
# Sidekiq checks queues in three modes:
# - :strict - all queues have 0 weight and are checked strictly in order
# - :weighted - queues have arbitrary weight between 1 and N
# - :random - all queues have weight of 1
def queues=(val)
  @weights = {}
  @queues = Array(val).each_with_object([]) do |qstr, memo|
    arr = qstr
    arr = qstr.split(",") if qstr.is_a?(String)
    name, weight = arr
    @weights[name] = weight.to_i
    [weight.to_i, 1].max.times do
      memo << name
    end
  end
  @mode = if @weights.values.all?(&:zero?)
    :strict
  elsif @weights.values.all? { |x| x == 1 }
    :random
  else
    :weighted
  end
end
```

There are three options for how queues are polled. If none of the queues have a weight defined (using the `default,10` notation), the mode is set to `strict`. If all of the queues have their weights set to 1 explicitly, the mode is set to `random`. In any other case, the mode is set to `weighted`.

One peculiar thing to note is that the `@queues` array will contain `m` copies of each queue, where `m` is their weight. For example, if the queues are configured in a weighted manner with `default,10 queue_one,5 queue_two,3`, `@queues` will consist of 10 `:default` elements, 5 `:queue_one` elements, and 3 `:queue_two` elements.

Let's come back over to `Processor#run`.  As we have already seen, this method makes the processor enter a loop that calls `Processor#process_one` until `terminate` or `kill` is called:

```ruby
# Processor

def get_one
  uow = capsule.fetcher.retrieve_work
  if @down
    logger.info { "Redis is online, #{::Process.clock_gettime(::Process::CLOCK_MONOTONIC) - @down} sec downtime" }
    @down = nil
  end
  uow
rescue Sidekiq::Shutdown
rescue => ex
  handle_fetch_exception(ex)
end
```

The conditional branch is there in case Sidekiq recovers from a backoff initiated by `handle_fetch_exception` in the rescue block. That method simply `sleep`s  for 1 second if there's a transient connectivity issue when contacting Redis.

`Sidekiq::Shutdown` is muted here to reduce noise created by the error handler invoked from `handle_fetch_exception`. Processing of new jobs stops regardless since `@done` ivar is set to `false` at this point.

The `fetcher` method in the `Capsule` class extracts the fetcher object. Here's its implementation:

```ruby
def fetcher
  @fetcher ||= begin
    inst = (config[:fetch_class] || Sidekiq::BasicFetch).new(self)
    inst.setup(config[:fetch_setup]) if inst.respond_to?(:setup)
    inst
  end
end
```

The OS version of Sidekiq comes with a single fetcher option, `BasicFetch`.

The Pro version includes [`SuperFetch`](https://github.com/sidekiq/sidekiq/wiki/Reliability#using-super_fetch), which offers a more robust durability guarantee for Sidekiq jobs. However, the specifics of this fetcher are not covered in this article.

Let's examine the internals of `BasicFetch`. Here are the relevant methods, with original comments preserved:

```ruby
class BasicFetch
  # We want the fetch operation to timeout every few seconds so the thread
  # can check if the process is shutting down.
  TIMEOUT = 2
  
  UnitOfWork = Struct.new(:queue, :job, :config) {
    def acknowledge
      # nothing to do
    end
  
    def queue_name
      queue.delete_prefix("queue:")
    end
  
    def requeue
      config.redis do |conn|
        conn.rpush(queue, job)
      end
    end
  }
  
  # ...
  
  def retrieve_work
    qs = queues_cmd
    # 4825 Sidekiq Pro with all queues paused will return an
    # empty set of queues
    if qs.size <= 0
      sleep(TIMEOUT)
      return nil
    end
  
    queue, job = redis { |conn| conn.blocking_call(conn.read_timeout + TIMEOUT, "brpop", *qs, TIMEOUT) }
    UnitOfWork.new(queue, job, config) if queue
  end
  
  # ...
  
  # Creating the Redis#brpop command takes into account any
  # configured queue weights. By default Redis#brpop returns
  # data from the first queue that has pending elements. We
  # recreate the queue command each time we invoke Redis#brpop
  # to honor weights and avoid queue starvation.
  def queues_cmd
    if @strictly_ordered_queues
      @queues
    else
      permute = @queues.shuffle
      permute.uniq!
      permute
    end
  end
end
```

True to its name, the logic in this class is straightforward: construct an array of queues (keep in mind that queue weights result in duplicate entries in the `@queues` array), shuffle it if there's no strict ordering, and then pass it to Redis' `BRPOP` command.

It might seem counterintuitive to call `#uniq!` on the resulting array when there are weighted queues, but it's not. The more identical entries there are in the array, the higher the chance that one of these entries will appear at the head of the array. `uniq!` preserves the ordering of elements.

[`BRPOP`](https://redis.io/commands/brpop/) takes multiple [list](https://redis.io/docs/data-types/lists/) names as arguments and pops the tail element of the first non-empty list in a blocking manner. This means that the first queue in the `@queues` array gets priority. An important detail here is the timeout. As the comment above the `TIMEOUT` constant suggests, Sidekiq wants these operations to time out regularly so that a process can check if `terminate` or `kill` was called in the meantime.

If the command successfully fetches a job from the list, the return values are wrapped in a `UnitOfWork` DTO.

The critical aspect of `BasicFetch` is that `BRPOP` removes the job from the list. Despite Sidekiq's efforts to be as resilient as possible and cover most failure scenarios, this has a significant implication: jobs can be lost. We'll explore some of the scenarios where this might occur and how Sidekiq attempts to mitigate them in a later section.

As you have probably noticed, the `acknowledge` method is empty for a `BasicFetch` `UnitOfWork`. While I haven't had the opportunity to explore the Pro or Enterprise licensed versions of Sidekiq myself, it's reasonable to assume that this method is relevant for the `SuperFetch` fetcher. `SuperFetch` preserves the job in Redis in some form instead of removing it immediately after fetching, which contributes to its enhanced reliability, but makes it necessary to somehow mark the jobs as being successfully processed. `SuperFetch`'s `acknowledge` most likely does exactly that. We will encounter situations where the `acknowledge` method becomes relevant as we dive deeper.

Back in `Processor#process_one`, if the fetch was successful, `Processor#process` is invoked. Since this method is lengthy, we'll examine modified smaller segments at a time.

```ruby
# Processor

def process(uow)
  jobstr = uow.job
  queue = uow.queue_name

  job_hash = nil
  begin
    job_hash = JSON.parse(jobstr)
  rescue => ex
    handle_exception(ex, {context: "Invalid JSON for job", jobstr: jobstr})
    now = Time.now.to_f
    redis do |conn|
      conn.multi do |xa|
        xa.zadd("dead", now.to_s, jobstr)
        xa.zremrangebyscore("dead", "-inf", now - @capsule.config[:dead_timeout_in_seconds])
        xa.zremrangebyrank("dead", 0, - @capsule.config[:dead_max_jobs])
      end
    end
    return uow.acknowledge
  end

  # ...
end
```

The job fetched from Redis is a JSON payload represented as a string, so it needs to be parsed first. Here, we encounter the concept of the morgue and dead jobs. Trying to process a malformed job won't yield positive results no matter how many times it is retried, so marking the job as 'dead' is a practical approach.

This is achieved by the [`ZADD`](https://redis.io/commands/zadd/) command, which adds a member to a [sorted set](https://redis.io/docs/data-types/sorted-sets/), where sorting key is the time at which the job was pronounced dead.

The next 2 commands are there to remove dead jobs that surpassed the allowed time in the morgue, which is 6 months by default, and preserve only the latest 10000 jobs in the set. All of this is done in a Redis transaction using the [`MULTI`](https://redis.io/commands/multi/) command.

After the job payload gets parsed successfully, it needs to be executed. The rest of the `#process` method does exactly that (comments are preserved):

```ruby
# Processor

def process(uow)
  # ...

  ack = false
  Thread.handle_interrupt(Sidekiq::Shutdown => :never) do
    Thread.handle_interrupt(Sidekiq::Shutdown => :immediate) do
      dispatch(job_hash, queue, jobstr) do |inst|
        config.server_middleware.invoke(inst, job_hash, queue) do
          execute_job(inst, job_hash["args"])
        end
      end
      ack = true
    rescue Sidekiq::Shutdown
      # Had to force kill this job because it didn't finish
      # within the timeout.  Don't acknowledge the work since
      # we didn't properly finish it.
    rescue Sidekiq::JobRetry::Handled => h
      # this is the common case: job raised error and Sidekiq::JobRetry::Handled
      # signals that we created a retry successfully.  We can acknowlege the job.
      ack = true
      e = h.cause || h
      handle_exception(e, {context: "Job raised exception", job: job_hash})
      raise e
    rescue Exception => ex
      # Unexpected error!  This is very bad and indicates an exception that got past
      # the retry subsystem (e.g. network partition).  We won't acknowledge the job
      # so it can be rescued when using Sidekiq Pro.
      handle_exception(ex, {context: "Internal exception!", job: job_hash, jobstr: jobstr})
      raise ex
    end
  ensure
    if ack
      uow.acknowledge
    end
  end
end
```

First thing that stands out is the use of `Thread.handle_interrupt`. In short, it allows to alter the handling of internal Ruby asynchronous events such as `Thread#raise` and `Thread#kill` - the former is exactly what is being used by `Processor#kill` as we have already seen.

In this particular case, first `handle_interrupt` is called with `Sidekiq::Shutdown => :never` and wraps the `ensure` block that calls `#acknowledge` on the unit of work. The second call is nested directly after the first one, and it resets the behaviour back to `:immediate`.

This achieves the following: if a processor is killed (using `Thread#raise(Sidekiq::Shutdown)`) when the ensure block is being evaluated, the raised exception will be ignored and the work will be acknowledged. Without setting the behaviour to `:never`, an acknowledgment would be missed in such case. The inner block resets it back to `:immediate` immediately afterward because this is the desired behavior - `Sidekiq::Shutdown` should interrupt the execution of the job's code.

This is not that relevant in the OS version since `BasicFetch`'s `UnitOfWork#acknowledge` is a no op, but it's important for `SuperFetch`, since its version of `acknowledge` most likely removes the job from Redis in order to mark it as processed.

The rescue blocks are self-explanatory thanks to the comments. One noteworthy aspect is that `Sidekiq::JobRetry::Handled` exceptions, which are raised when a retry is successfully created, get re-raised and propagated all the way up to `Processor#run`. This, in turn, triggers the callback supplied by the `Manager`, which deletes the processor and creates a new one. As a result, job retries will force the processor to be recreated, spawning a new Ruby thread in place of the original.

Let's unwrap the `Processor#dispatch` and `Processor#execute_job` methods:

```ruby
# Processor
# Relevant bits from #dispatch, #process & #execute_job combined together

@job_logger.prepare(job_hash) do
  @retrier.global(jobstr, queue) do
    @job_logger.call(job_hash, queue) do
      stats(jobstr, queue) do
        @reloader.call do
          klass = Object.const_get(job_hash["class"])
          inst = klass.new
          inst.jid = job_hash["jid"]
          @retrier.local(inst, jobstr, queue) do
            config.server_middleware.invoke(inst, job_hash, queue) do
              inst.perform(*job_hash["args"])
            end
          end
        end
      end
    end
  end
end
```

The `@job_logger` variable is an instance of `Sidekiq::JobLogger`. Its `prepare` method is responsible for putting job metadata into thread-local context, ensuring that logs emitted further down the stack contain useful correlation information.

Another crucial step in this pipeline is the `@reloader.call` invocation. This is where Sidekiq integrates with the Rails framework. A [reloader](https://guides.rubyonrails.org/threading_and_code_execution.html#reloader), as the name suggests, is responsible for code reloading. This is relevant because jobs typically reside in the `app/` directory of a Rails application, which should be reloadable. Additionally, the reloader handles [ActiveRecord connection cleanup](https://github.com/rails/rails/blob/a255742b2eb711baa8fd7a8937852851ddc8a679/activerecord/lib/active_record/railtie.rb#L326-L331) and other related concerns.

Sidekiq extracts the job class via `Object.const_get(job_hash["class"])` and calls `#perform` on it after invoking the server middleware chain. Sidekiq's middlewares are similar to those of Rack - arbitrary classes that respond to `#call` and yield if the chain should not be halted. This is the public API for integrations that want to augment or alter Sidekiq's processing logic, which is exactly what monitoring libraries like [Sentry](https://github.com/getsentry/sentry-ruby/blob/master/sentry-sidekiq/lib/sentry/sidekiq/sentry_context_middleware.rb), [Datadog](https://github.com/DataDog/dd-trace-rb/blob/e4498741b7e85b7f886a8feb72ec62e64f86ad25/lib/datadog/tracing/contrib/sidekiq/server_tracer.rb) and others do.

### Handling exceptions

Naturally, application code called from within jobs can raise exceptions. Sidekiq provides several ways to handle them, with the default behavior being to retry failed jobs up to 25 times with an exponential backoff.

Let's examine the `#local` method of `Processor`'s `@retrier` ivar, an instance of `Sidekiq::JobRetry` which wraps the `#perform` method of every job class:

```ruby
class JobRetry
  class Handled < ::RuntimeError; end
  class Skip < Handled; end
  
  # ...
  
  def local(jobinst, jobstr, queue)
    yield
  rescue Handled => ex
    raise ex
  rescue Sidekiq::Shutdown => ey
    raise ey
  rescue Exception => e
    raise Sidekiq::Shutdown if exception_caused_by_shutdown?(e)

    msg = JSON.parse(jobstr)
    if msg["retry"].nil?
      msg["retry"] = jobinst.class.get_sidekiq_options["retry"]
    end

    raise e unless msg["retry"]
    process_retry(jobinst, msg, queue, e)

    raise Skip
  end
end
```

This method is called "local" since it can be directly correlated to a particular instantiated job instance. We will see why it's relevant once we get to `#process_retry`.

`Sidekiq::Shutdown` is re-raised because it should bypass the retry system, and `Handled` is being re-raised as well in case a developer decides to manually raise it from within a job.

Rescuing `Exception` (i.e. all exceptions) is the interesting part.

First of all, Sidekiq detects if an exception was raised due to the thread receiving a `Sidekiq::Shutdown` from `Processor#kill`. With this detection, only errors that are caused by a bug or some other transient error within the application code will trigger a retry. This prevents monitoring tools from being polluted unnecessarily and does not force well-behaving jobs into a retry set. We'll skip the internals of `#exception_caused_by_shutdown?` for brevity, only mentioning that its secret sauce is Ruby's [`exception#cause`](https://rubyapi.org/3.3/o/exception#method-i-cause) method.

Next, Sidekiq checks if the job was explicitly configured without retries - it simply re-raises the exception if that's the case. By default, every Sidekiq job is retried up to 25 times.

Before we proceed to `#process_retry`, we need to look at the final line: `raise Skip`. Instead of re-raising the original exception, Sidekiq raises a subclass of `JobRetry::Handled`. We'll see how it relates to the `#global` method once we get to it.

The original `#process_retry` method handles metadata management and formatting; the following snippet is a trimmed-down version of it:

```ruby
# JobRetry

def process_retry(jobinst, msg, queue, exception)
  max_retry_attempts = retry_attempts_from(msg["retry"], @max_retries)

  msg["queue"] = (msg["retry_queue"] || queue)

  # Code that updates the `retry_count` job payload attribute, saves the `retried_at` and `failed_at` timestamps, filters and saves the backtrace, etc
  count = msg["retry_count"] # Increment logic of this value is omitted

  return retries_exhausted(jobinst, msg, exception) if count >= max_retry_attempts

  rf = msg["retry_for"]
  return retries_exhausted(jobinst, msg, exception) if rf && ((msg["failed_at"] + rf) < Time.now.to_f)

  strategy, delay = delay_for(jobinst, count, exception, msg)
  case strategy
  when :discard
    return
  when :kill
    return retries_exhausted(jobinst, msg, exception)
  end

  jitter = rand(10) * (count + 1)
  retry_at = Time.now.to_f + delay + jitter
  payload = JSON.parse(msg)
  redis do |conn|
    conn.zadd("retry", retry_at.to_s, payload)
  end
end
```

First, note that Sidekiq provides an ability to reroute the job into a different queue if it fails; this is what the second line of code is responsible for.

Immediately after, `#retries_exhausted` is called if the job exceeds its maximum retry count, or if the time frame during which it should be retried has passed.

If Sidekiq should attempt to retry the job, it calls `#delay_for`. This method returns a strategy and a delay in seconds. We'll see where the strategy value comes from, but for now, understand that a job can be either `discard`ed or `kill`ed, with the former causing Sidekiq to completely forget about the job instead of retrying it.

In case the job should actually be retried, the timestamp at which it should happen is calculated based on the obtained delay. Jitter is applied to this value to avoid the thundering herd problem, where a bunch of jobs are scheduled for a retry at the same second.

Finally, the job is added to a `retry` sorted set using `ZADD`, following a simillar process to dead jobs.

```ruby
# JobRetry
def delay_for(jobinst, count, exception, msg)
  rv = begin
    block = jobinst&.sidekiq_retry_in_block
    # ...
    block&.call(count, exception, msg)
  rescue Exception => e
    # ...
    nil
  end

  rv = rv.to_i if rv.respond_to?(:to_i)
  delay = (count**4) + 15
  if Integer === rv && rv > 0
    delay = rv
  elsif rv == :discard
    return [:discard, nil]
  elsif rv == :kill
    return [:kill, nil]
  end

  [:default, delay]
end
```

`#delay_for` sources the `strategy` from an optional `sidekiq_retry_in_block` block defined on the job class by a developer. It can either return a symbol representing the strategy or an integer value representing the number of seconds for a delay.

If the delay value was not provided by a developer, it gets calculated with an exponential backoff formula, where `count` is the number of retries already conducted. With the default max retry count being 25, this means that a job (without a custom `sidekiq_retry_in_block` defined) will be retried 25 times over approximately 20 days.

Here's what happens in the `#retries_exhausted` method:

```ruby
# JobRetry

def retries_exhausted(jobinst, msg, exception)
  rv = begin
    block = jobinst&.sidekiq_retries_exhausted_block
    # ...
    block&.call(msg, exception)
  rescue => e
    # Log the error and do not reraise it
    # ...
  end

  return if rv == :discard
  unless msg["dead"] == false
    payload = Sidekiq.dump_json(msg)
    now = Time.now.to_f

    redis do |conn|
      conn.multi do |xa|
        xa.zadd("dead", now.to_s, payload)
        xa.zremrangebyscore("dead", "-inf", now - @capsule.config[:dead_timeout_in_seconds])
        xa.zremrangebyrank("dead", 0, - @capsule.config[:dead_max_jobs])
      end
    end
  end
end
```

Another optional user-supplied job-level configuration being used here is `sidekiq_retries_exhausted_block`, which allows discarding a job once its retries are exhausted. If it's not provided, a job gets sent to the morgue in the exact same fashion as in `Processor#process` when a job payload is malformed.

The last relevant method in the retrier is `#global`. It's worth remembering that it wraps a call to `#local`, `Processor#reloader`, invocation of middlewares, and pretty much every other step in the `Processor#process` pipeline. It's needed to catch any exceptions raised when processing a job, including those that are not raised from within application code, on a best-effort basis. Its only difference from `#local` is that it discards the job if it doesn't have a `retry` attribute set, or if this attribute is set to `false` on the job class:

```ruby
# JobRetry

def global(jobstr, queue)
  yield
rescue Handled => ex
  raise ex
rescue Sidekiq::Shutdown => ey
  raise ey
rescue Exception => e
  raise Sidekiq::Shutdown if exception_caused_by_shutdown?(e)

  msg = Sidekiq.load_json(jobstr)
  if msg["retry"]
    process_retry(nil, msg, queue, e)
  else
    @capsule.config.death_handlers.each do |handler|
      handler.call(msg, e)
    rescue => handler_ex
      handle_exception(handler_ex, {context: "Error calling death handler", job: msg})
    end
  end

  raise Handled
end
```

  
You might notice that similarly to `#local`, this method also rescues `JobRetry::Handled` and does not retry in such cases, since these exceptions are already handled in the `#local` rescue block that raises a `JobRetry::Skip` - a subclass of `Handled`. This avoids duplicate retry processing.

We have now explored the primary process of how Sidekiq handles job processing on the server. However, what about jobs that need to be retried? Also, doesn't Sidekiq offer a mechanism for delaying the execution of jobs until a specified time in the future? We will learn how Sidekiq handles these in the section following the next one.

## Enqueueing jobs

So far, we've looked at the internals of Sidekiq server: `Launcher`, `Manager`, and `Processor` constructs, which operate within a background process responsible for job processing. Now, let's explore how jobs make their way into the queues, which leads us to `Sidekiq::Client`.

Although most Sidekiq users typically don't interact directly with `Sidekiq::Client`, preferring higher-level abstractions like the [Job API](https://github.com/sidekiq/sidekiq/blob/c1607198815d68f60d138010907dd3426d6521bb/lib/sidekiq/job.rb), all the convenience methods provided by this module rely on fundamental building blocks: `Client#push` and `Client#push_bulk`, which accept different combinations of arguments.

Let's see what `Client#push` does:

```ruby
# Client

def push(item)
  normed = normalize_item(item)
  payload = middleware.invoke(item["class"], normed, normed["queue"], @redis_pool) do
    normed
  end
  if payload
    verify_json(payload)
    raw_push([payload])
    payload["jid"]
  end
end
```

`normalize_item` performs several operations on the payload, including argument validation and generation of a unique job identifier.

Subsequently, the payload undergoes processing through the client middleware chain, mirroring the way `Processor` sends job payloads through server middlewares. This enables external integrations to enhance the job payload with extra attributes and implement custom logic around job dispatches.

`verify_json` might not need additional explanation as it does exactly what its name suggests, but it's how it does it that makes it worthwhile to look into:

```ruby
def verify_json(item)
  job_class = item["wrapped"] || item["class"]
  args = item["args"]
  mode = Sidekiq::Config::DEFAULTS[:on_complex_arguments]

  if mode == :raise || mode == :warn
    if (unsafe_item = json_unsafe?(args))
      msg = <<~EOM
        Job arguments to #{job_class} must be native JSON types, but #{unsafe_item.inspect} is a #{unsafe_item.class}.
        See https://github.com/sidekiq/sidekiq/wiki/Best-Practices
        To disable this error, add `Sidekiq.strict_args!(false)` to your initializer.
      EOM

      if mode == :raise
        raise(ArgumentError, msg)
      else
        warn(msg)
      end
    end
  end
end

# ...

RECURSIVE_JSON_UNSAFE = {
  Integer => ->(val) {},
  Float => ->(val) {},
  TrueClass => ->(val) {},
  FalseClass => ->(val) {},
  NilClass => ->(val) {},
  String => ->(val) {},
  Array => ->(val) {
    val.each do |e|
      unsafe_item = RECURSIVE_JSON_UNSAFE[e.class].call(e)
      return unsafe_item unless unsafe_item.nil?
    end
    nil
  },
  Hash => ->(val) {
    val.each do |k, v|
      return k unless String === k

      unsafe_item = RECURSIVE_JSON_UNSAFE[v.class].call(v)
      return unsafe_item unless unsafe_item.nil?
    end
    nil
  }
}

RECURSIVE_JSON_UNSAFE.default = ->(val) { val }
RECURSIVE_JSON_UNSAFE.compare_by_identity
private_constant :RECURSIVE_JSON_UNSAFE

def json_unsafe?(item)
  RECURSIVE_JSON_UNSAFE[item.class].call(item)
end
```

Boiled down, the `verify_json` method validates job arguments expected by the `#perform` method to ensure they adhere to valid JSON format. In versions predating Sidekiq 7.0, the `json_unsafe?` method employed a straightforward check by verifying if the arguments remained unchanged after being dumped and parsed as JSON: `JSON.parse(JSON.dump(item["args"])) == item["args"]`. However, this approach, involving the dumping and parsing of potentially large arguments for each job, clearly warranted performance enhancements.

To address this, the `RECURSIVE_JSON_UNSAFE` constant was introduced. Additional improvement lies in `RECURSIVE_JSON_UNSAFE.compare_by_identity`, which makes the hash resolve key objects based on their `object_id` instead of calling [`hash`](https://rubyapi.org/3.3/o/object#method-i-hash), resulting in a faster process. Extracting a static `object_id` that remains unchanged during an object's lifetime, albeit recursively, is much faster than going through 2 iterations of JSON processing.

In this new version, every Ruby class known to be 'JSON-safe' returns a proc that returns `nil` when executed. Arrays and hashes receive special treatment since they contain other objects, making this hash recursive. If a job payload contains an object of any other class not declared as a key in the hash, the arguments are deemed unsafe, and an appropriate action will be taken, with the default being to raise an error.

`raw_push` is the place where job gets put into Redis:

```ruby
# Client

def raw_push(payloads)
  @redis_pool.with do |conn|
    retryable = true
    begin
      conn.pipelined do |pipeline|
        atomic_push(pipeline, payloads)
      end
    rescue RedisClient::Error => ex
      if retryable && ex.message =~ /READONLY|NOREPLICAS|UNBLOCKED/
        conn.close
        retryable = false
        retry
      end
      raise
    end
  end
  true
end

def atomic_push(conn, payloads)
  if payloads.first.key?("at")
    conn.zadd("schedule", payloads.flat_map { |hash|
      at = hash.delete("at").to_s
      # ...
      [at, JSON.generate(hash)]
    })
  else
    queue = payloads.first["queue"]
    now = Time.now.to_f
    to_push = payloads.map { |entry|
      entry["enqueued_at"] = now
      JSON.generate(entry)
    }
    conn.sadd("queues", [queue])
    conn.lpush("queue:#{queue}", to_push)
  end
end
```

This method accepts an array of payloads to support `#push_bulk`. `#push` passes a single array element as an argument.

The rescue is included to handle Redis failovers that necessitate reopening the connection socket, attempting one transparent retry.

Subsequently, the Redis commands called by `atomic_push` are [pipelined](https://redis.io/docs/manual/pipelining/), reducing the round-trip time (RTT). Note that when jobs are pushed in a batch, all of them are submitted using a single `LPUSH` command, so pipelining here is not as critical as it could have been.[^5]

`atomic_push` has 2 branches. The second branch is for immediate dispatches of jobs that will be processed as soon as possible. The [`SADD`](https://redis.io/commands/sadd/) command is there to store a set of queues for monitoring purposes and is not necessarily relevant to job processing itself. However, the subsequent [`LPUSH`](https://redis.io/commands/lpush/) command is crucial as it puts jobs into the list that is regularly fetched by a `Processor` instance on the server side, which we have already covered. An important detail is that `LPUSH` adds the elements to the front of the list - `BasicFetch#retrieve_work` pops the element from the tail, making Sidekiq queues employ a FIFO model.

It must be strongly emphasized here that despite the first-come first-serve nature of queues, Sidekiq does not guarantee the order of job execution. A subsequent job can and will be popped from the queue list before the preceding one may be finished by another processor. However, it is possible to set the `concurrency` setting of a specific capsule responsible for a set of specified queues to 1. This ensures that only 1 `Processor` is active at any time, making job fetching sequential. Nevertheless, this still does not guarantee ordering in case a job fails to be processed and is sent to the retry set, or in case a preceding job is lost. We will explore when the latter case can happen in the following section. In any case, if strict ordering of jobs is truly needed, Sidekiq is not the best option.

The first branch of `atomic_push` accommodates scheduled jobs, which we haven't touched until now. Scheduled jobs enable users to defer their job's execution until a specific time in the future. In order to achieve this, `ZADD` is used again with a sorted set, similar to `dead` and `retry` sets.

## Retrying & scheduling

By now, we have explored most of the server's internals, and we have also examined how `Sidekiq#client` pushes jobs into the queues, including an option to schedule a job for execution in the future. However, we have not yet explored the final component that enables the processing of scheduled jobs and jobs that need to be retried. We noted that both types of jobs get added into corresponding sorted sets using `ZADD`, but how do they get processed?

When we previously examined the `Launcher`, we intentionally glossed over `Sidekiq::Scheduled::Poller`. Whenever a Sidekiq process boots, it calls `Launcher#run`, which in turn initiates the poller thread.

```ruby
def start
  @thread ||= safe_thread("scheduler") {
    initial_wait

    until @done
      enqueue
      wait
    end
  }
end
```

Its main loop is extremely similar to that of `Processor`, so I won't cover where `@done` is set.

Before we delve into the details of the `initial_wait`, `enqueue`, and `wait` methods, let's take a step back. Based on what we've seen so far, we can confidently say that multiple Sidekiq processes require no coordination at all. It's common practice to use a single Redis instance and launch multiple Sidekiq processes, each sharing the same set of queues, to increase throughput and availability. These processes simply attempt to `BRPOP` jobs from queue lists atomically, and each processor gets its share of work.

However, the `scheduled` and `retry` sets operate differently. Jobs in these sets should not be processed immediately; they are pushed into the respective queues when their time comes for processing by the `Processor`s. The `Poller` handles this task, but what if there are several Sidekiq processes? Each will have its own poller thread competing for access to shared Redis sets. While this isn't an issue for normal processing of queue lists, as `BRPOP` operations take constant time, extracting desired keys from a `scheduled` or `retry` sorted set has a different computational complexity. Continuously bombarding Redis with commands used by the poller from several processes negatively impacts its health and performance. Therefore, the pollers must either coordinate to ensure that only one runs at a time, or their executions must be artificially spread out. Sidekiq opts for the latter option, and we'll explore how it achieves that.

`Sidekiq::Scheduled` is one of the most commented modules in Sidekiq, so all of the original comments are preserved in following snippets. Here's `#initial_wait` that gets called once per Sidekiq process:

```ruby
# Scheduled::Poller

INITIAL_WAIT = 10

# ...

def initial_wait
  # Have all processes sleep between 5-15 seconds. 10 seconds to give time for
  # the heartbeat to register (if the poll interval is going to be calculated by the number
  # of workers), and 5 random seconds to ensure they don't all hit Redis at the same time.
  total = 0
  total += INITIAL_WAIT unless @config[:poll_interval_average]
  total += (5 * rand)

  @sleeper.pop(total)
rescue Timeout::Error
ensure
  # periodically clean out the `processes` set in Redis which can collect
  # references to dead processes over time. The process count affects how
  # often we scan for scheduled jobs.
  cleanup
end
```
  
Heartbeat is mentioned in the first comment - similar to a poller, it's another thread that routinely updates some process metadata stored in Redis. The only thing relevant to the poller is the updating of the `processes` set, which contains unique identifiers of each Sidekiq process; we will see how it exactly comes into play shortly.

`@sleeper.pop(total)` simply makes the thread wait for a specified amount of time.

```ruby
# Scheduled::Poller

def cleanup
  # dont run cleanup more than once per minute
  return 0 unless redis { |conn| conn.set("process_cleanup", "1", "NX", "EX", "60") }

  count = 0
  redis do |conn|
    procs = conn.sscan("processes").to_a
    heartbeats = conn.pipelined { |pipeline|
      procs.each do |key|
        pipeline.hget(key, "info")
      end
    }

    # the hash named key has an expiry of 60 seconds.
    # if it's not found, that means the process has not reported
    # in to Redis and probably died.
    to_prune = procs.select.with_index { |proc, i|
      heartbeats[i].nil?
    }
    count = conn.srem("processes", to_prune) unless to_prune.empty?
  end

  count
end
```

As can be seen, the poller is responsible for cleaning out dead processes' metadata from Redis. Despite what the comment in `#initial_wait` says, this only happens once a poller starts, and, under normal circumstances, it starts only when a process boots up.

Why exactly this is necessary can be seen in the `#wait` method, which is being called in a loop after every `#enqueue`:

```ruby
# Scheduled::Poller

def wait
  @sleeper.pop(random_poll_interval)
rescue Timeout::Error
  # expected
rescue => ex
  # if poll_interval_average hasn't been calculated yet, we can
  # raise an error trying to reach Redis.
  logger.error ex.message
  handle_exception(ex)
  sleep 5
end

def random_poll_interval
  # We want one Sidekiq process to schedule jobs every N seconds.  We have M processes
  # and **don't** want to coordinate.
  #
  # So in N*M second timespan, we want each process to schedule once.  The basic loop is:
  #
  # * sleep a random amount within that N*M timespan
  # * wake up and schedule
  #
  # We want to avoid one edge case: imagine a set of 2 processes, scheduling every 5 seconds,
  # so N*M = 10.  Each process decides to randomly sleep 8 seconds, now we've failed to meet
  # that 5 second average. Thankfully each schedule cycle will sleep randomly so the next
  # iteration could see each process sleep for 1 second, undercutting our average.
  #
  # So below 10 processes, we special case and ensure the processes sleep closer to the average.
  # In the example above, each process should schedule every 10 seconds on average. We special
  # case smaller clusters to add 50% so they would sleep somewhere between 5 and 15 seconds.
  # As we run more processes, the scheduling interval average will approach an even spread
  # between 0 and poll interval so we don't need this artifical boost.
  #
  count = process_count
  interval = poll_interval_average(count)
  
  if count < 10
    # For small clusters, calculate a random interval that is ±50% the desired average.
    interval * rand + interval.to_f / 2
  else
    # With 10+ processes, we should have enough randomness to get decent polling
    # across the entire timespan
    interval * rand
  end
end

# We do our best to tune the poll interval to the size of the active Sidekiq
# cluster.  If you have 30 processes and poll every 15 seconds, that means one
# Sidekiq is checking Redis every 0.5 seconds - way too often for most people
# and really bad if the retry or scheduled sets are large.
#
# Instead try to avoid polling more than once every 15 seconds.  If you have
# 30 Sidekiq processes, we'll poll every 30 * 15 or 450 seconds.
# To keep things statistically random, we'll sleep a random amount between
# 225 and 675 seconds for each poll or 450 seconds on average.  Otherwise restarting
# all your Sidekiq processes at the same time will lead to them all polling at
# the same time: the thundering herd problem.
#
# We only do this if poll_interval_average is unset (the default).
def poll_interval_average(count)
  @config[:poll_interval_average] || scaled_poll_interval(count)
end

# Calculates an average poll interval based on the number of known Sidekiq processes.
# This minimizes a single point of failure by dispersing check-ins but without taxing
# Redis if you run many Sidekiq processes.
def scaled_poll_interval(process_count)
  process_count * @config[:average_scheduled_poll_interval]
end

def process_count
  pcount = Sidekiq.redis { |conn| conn.scard("processes") }
  pcount = 1 if pcount == 0
  pcount
end
```

Poll interval logic is explained in detail thanks to the comprehensive comments. The amount of active Sidekiq processes consuming jobs from the same Redis installation is taken into consideration when calculating an interval with which pollers should contact Redis. It all boils down to minimizing concurrent poller operations.

Finally, let's see what all of this effort is for. `Poller#enqueue` instantiates `Sidekiq::Scheduled::Enq`, which encapsulates scheduled dequeue logic and calls `#enqueue_jobs` on it:

```ruby
class Enq
  LUA_ZPOPBYSCORE = <<~LUA
    local key, now = KEYS[1], ARGV[1]
    local jobs = redis.call("zrange", key, "-inf", now, "byscore", "limit", 0, 1)
    if jobs[1] then
      redis.call("zrem", key, jobs[1])
      return jobs[1]
    end
  LUA

  # ...

  def enqueue_jobs(sorted_sets = %w[retry schedule])
    # A job's "score" in Redis is the time at which it should be processed.
    # Just check Redis for the set of jobs with a timestamp before now.
    redis do |conn|
      sorted_sets.each do |sorted_set|
        # Get next item in the queue with score (time to execute) <= now.
        # We need to go through the list one at a time to reduce the risk of something
        # going wrong between the time jobs are popped from the scheduled queue and when
        # they are pushed onto a work queue and losing the jobs.
        while !@done && (job = zpopbyscore(conn, keys: [sorted_set], argv: [Time.now.to_f.to_s]))
          @client.push(JSON.generate(job))
        end
      end
    end
  end

  # ...

  private

  def zpopbyscore(conn, keys: nil, argv: nil)
    if @lua_zpopbyscore_sha.nil?
      @lua_zpopbyscore_sha = conn.script(:load, LUA_ZPOPBYSCORE)
    end

    conn.call("EVALSHA", @lua_zpopbyscore_sha, keys.size, *keys, *argv)
  rescue RedisClient::CommandError => e
    raise unless e.message.start_with?("NOSCRIPT")

    @lua_zpopbyscore_sha = nil
    retry
  end
end
```

First thing to note is the `LUA_ZPOPBYSCORE` string, along with [`SCRIPT`](https://redis.io/commands/script-load/) and [`EVALSHA`](https://redis.io/commands/evalsha/) Redis commands. This is Sidekiq making use of a [Redis feature](https://redis.io/docs/interact/programmability/eval-intro/) that allows execution of atomic Lua scripts on the server. The script is preloaded and cached in Redis using `conn.script` so that subsequent commands utilizing it can benefit from increased performance.

The script itself takes an array of sets (`retry` and `schedule`) and a current timestamp (note that Lua array indexing starts with 1). It then calls [`ZRANGE`](https://redis.io/commands/zrange/), which returns a single job with the lowest timestamp that should be dispatched to the queue. The job element is then removed from the set using [`ZREM`](https://redis.io/commands/zrem/).

The complexity of `ZRANGE` is O(log(N) + M), where N is the total number of elements in the set and M is the number of elements returned. However, Sidekiq dequeues one scheduled or to-be-retried job at a time to be safe, as the comment suggests, meaning that the overall complexity will be O(M * log(N)).

`ZREM` itself is already O(M * log(N)), so the overall complexity doesn't change by the fact that the whole script is called for every relevant job.

For every successfully dequeued job, `Client#push` is called to dispatch the job to its target queue.

This, along with the fact that Redis is mostly single-threaded, makes it clear why spreading out the pollers in time is so important. With several processes and a large enough retry or scheduled set (and in my experience, retry set sizes can easily be in the order of thousands, if not more), executing this logic concurrently can significantly impair Redis's performance or even grind it to a halt.

## Job loss potential

Now that we've explored the complete lifecycle of a job as it's processed by the server, let's examine potential scenarios where a job might become lost.

We know that the OS version of Sidekiq only provides `BasicFetch` as a means to dequeue jobs from Redis, which effectively removes them from the corresponding queue lists. This means that if a Sidekiq process is terminated abruptly, such as with a SIGKILL, all in-progress jobs will be lost. For instance, this can occur if the process exhausts its memory, prompting Kubernetes to forcefully terminate the pod with a `kill -9` command, or if other orchestrators and hosting providers take similar actions.

But how does Sidekiq manage hanging, long-running, or simply in-progress jobs during a graceful termination?

Let's revisit `Manager#hard_shutdown`, which is called when a Sidekiq process receives a SIGTERM or SIGINT:

```ruby
# Manager

def hard_shutdown
  cleanup = nil
  @plock.synchronize do
    cleanup = @workers.dup
  end

  if cleanup.size > 0
    jobs = cleanup.map { |p| p.job }.compact

    capsule.fetcher.bulk_requeue(jobs)
  end

  cleanup.each do |processor|
    processor.kill
  end

  # ...
end
```

`capsule.fetcher.bulk_requeue(jobs)` is called before processor threads are terminated. At this point, waiting for them to handle the `Sidekiq::Shutdown` exception and gracefully exit is not feasible.[^6] Therefore, the best option is to requeue all jobs that are in progress, even though it means that some jobs that finish just before the process exits will also be requeued.

`BasicFetch#bulk_requeue` simply takes the job payloads extracted from active processors and puts them back into the corresponding Redis lists:

```ruby
# BasicFetch

def bulk_requeue(inprogress)
  return if inprogress.empty?

  # ...
  jobs_to_requeue = {}
  inprogress.each do |unit_of_work|
    jobs_to_requeue[unit_of_work.queue] ||= []
    jobs_to_requeue[unit_of_work.queue] << unit_of_work.job
  end

  redis do |conn|
    conn.pipelined do |pipeline|
      jobs_to_requeue.each do |queue, jobs|
        pipeline.rpush(queue, jobs)
      end
    end
  end
  # ...
end
```
  
`BasicFetch`'s requeue logic is a potential scenario where job loss can occur. Redis might run out of memory while a job is being processed, making it impossible to put the job back into the queue. This is also a concern for ordinary retries.

Additionally, although not directly related to Sidekiq, jobs can be lost due to specific Redis server misconfigurations. The [eviction policy](https://redis.io/docs/reference/eviction/), which determines how Redis handles memory when it's full, plays a significant role here. Any setting other than `noevict` may result in jobs being evicted from Redis under certain circumstances. Furthermore, Redis can encounter failures and lose data after a reboot, particularly with certain [persistence](https://redis.io/docs/management/persistence/) configurations. This situation can lead to Sidekiq clients incorrectly assuming that a job will be processed after a successful push, when in fact it may not reach the Sidekiq server at all.

It is also possible for the SIGTERM or SIGINT handler not to be executed within the predefined timeout period, which the orchestrator running Sidekiq waits for before sending SIGKILL. Redis connectivity issues are the most likely culprit here. Theoretically, GC pauses and the condition of the host machine can also impede the Sidekiq process during this crucial task, but I personally have never encountered, nor have I heard of, such cases where a Ruby program is stalled for 25 seconds.

It goes without saying that killing the Sidekiq process with SIGKILL without having sent SIGINT or SIGTERM prior will result in all of the in-progress jobs being lost.

It should be noted that the decision to design `BasicFetch` in its current manner is intentional. By using a single `BRPOP` command to fetch a job, Sidekiq remains extremely simple and lightweight in terms of its load on Redis. However, this also means that if your jobs absolutely must never be lost, relying solely on Sidekiq might not be the best choice. Nevertheless, it may be possible to refactor the application code and business logic that warrants strong durability guarantees to include a liveness component, such as a recurring cron job, that would attempt to ensure the completion of a specific workflow by repeatedly enqueuing a job until the desired final state is achieved.

This makes Sidekiq employ an 'at least once' delivery semantic, with the possibility of losing jobs during severe degradation of the system's health. However, the Pro version ensures that job loss is impossible, as jobs never leave Redis until they are acknowledged with `SuperFetch` enabled, effectively making it truly 'at least once' without any caveats.

Sidekiq leverages simple Redis data structures like lists with constant-time push and pop operations, along with adjustable thread counts, to achieve scalability, efficiency, and ease of management. In the OS version, scaling can involve deploying multiple Sidekiq processes, each consuming jobs from the same Redis installation. The Enterprise version offers a forking model for multi-process execution, providing an alternative way to scale. For fine-grained control over queues, capsules can be used to organize processing with specific concurrency settings. Additionally, you can prioritize certain queues, enforce strict queue processing order (distinct from job ordering), or evenly poll queues. However, it's important to note that job ordering within queues isn't supported. Nevertheless, employing a single processor per queue could provide a rudimentary form of ordering, which may suffice depending on your application's requirements.

[^1]: Based on my personal experience of having contributed to 6+ Ruby projects, as well as Github 'used by' stats. By no means do I claim this to be the ultimate and definitive metric.
[^2]: Technically, it is possible to require the Rails application or a particular file right in the configuration template, but one might question if this is a wise decision.
[^3]: The SIGTTIN handler is there for ease of debugging. The process will dump stack traces of all active threads once it receives it.
[^4]: A helpful guide to what operations are not permitted in `Signal.trap` context on MRI can be found [here](https://github.com/ruby/ruby/blob/012faccf040344360801b0fa77e85f9c8a3a4b2c/doc/signals.rdoc).
[^5]: Previously, this paragraph stated that pipelining in the case of `atomic_push` helps avoid RTT for every job submitted in a batch, which is not true. Thanks to [Igor Wiedler](https://www.linkedin.com/in/igor-wiedler-4ab29833/) for spotting this error.
[^6]: Waiting for a thread to process an exception raised using `Thread#raise` can [take an indefinite amount of time](https://redgetan.cc/understanding-timeouts-in-cruby/) in certain cases.

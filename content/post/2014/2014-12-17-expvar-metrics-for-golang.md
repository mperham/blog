---
author: Mike Perham
date: 2014-12-17T00:00:00Z
title: The expvar package - Metrics for Go
url: /2014/12/17/expvar-metrics-for-golang/
---

Last week I discovered a mysterious package in the Go standard library, [expvar][1].  A google search turned up
little content on it.  **Undiscovered APIs for exploring? How exciting!**  I immediately dove in
and what I found was neat yet unsurprising.

<!--more-->

The expvar package allows a Go process to **exp**ose **var**iables to the public via an HTTP endpoint that emits
JSON.  The simplest usage requires you to do two things in your custom code:

1\. Import the package - this has the side effect of registering the `/debug/vars` HTTP endpoint.

```go
import "expvar"
```

2\. Start up an HTTP server for your process to handle HTTP requests:

```go
sock, err := net.Listen("tcp", "localhost:8123")
if err != nil {
  return err
}
go func() {
  fmt.Println("HTTP now available at port 8123")
  http.Serve(sock, nil)
}()
```

If you hit [http://localhost:8123/debug/vars][4], you should see something like this:

```json
{
"cmdline": ["/var/folders/bc/27hv15_d2zvcc3n3s9dxmfg00000gn/T/go-build421732654/command-line-arguments/_obj/exe/main","-l","debug","-s","i.sock","-c","realtest"],
"counters": {"a": 10, "b": 10},
"memstats": {"Alloc":1076016,"TotalAlloc":1801544,"Sys":5966072,"Lookups":209,"Mallocs":7986,"Frees":4528,"HeapAlloc":1076016,"HeapSys":2097152,"HeapIdle":327680,"HeapInuse":1769472,"HeapReleased":0,"HeapObjects":3458,"StackInuse":212992,"StackSys":917504,"MSpanInuse":21504,"MSpanSys":32768,"MCacheInuse":8800,"MCacheSys":16384,"BuckHashSys":1441160,"GCSys":1183744,"OtherSys":277360,"NextGC":1436032,"LastGC":1418102095002592201,"PauseTotalNs":2744531,"PauseNs":[480149,171430,603839,288381,494934,522995,182803,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"NumGC":7,"EnableGC":true,"DebugGC":false}
}
```

(Put that blob into [JSONLint][2] if you want to see a more readable but verbose version.)

By default, Go's runtime exposes data about command line arguments, memory usage and garbage collection with very little effort, all
built into the standard library.  Simple and easy yet powerful, like most Go functionality.

## Adding your own Metrics

As the **expvar** name implies though, you can expose your own variables into the mix for monitoring purposes.
In fact Datadog recently announced that [their monitoring agent can pull your custom expvar values][5] into their system
for monitoring purposes.

Here you can see how to declare a map of counters and then start to increment them as actions happen in your daemon.
You can see in the JSON blob above how they appear when exported:

```go
var (
  counts = expvar.NewMap("counters")
)
func init() {
  counts.Add("a", 10)
  counts.Add("b", 10)
}
```

## Wherein I Mix in some Awesome

Well, I'm even more excited because the next version of [Inspeqtor Pro][3] will have a Web UI for visualizing the
memory and GC data which the Go runtime exposes.  This type of functionality is always what I've wanted in
production and with almost no effort.  Sweet.

Here's a prototype I'm working on right now.  You modify your Go daemon to expose the expvar memory data and
Inspeqtor Pro can give you this real-time memory visualization.

![memory and gc visualizer](/wp-content/uploads/2014/12/mem-viz.png)

## The Future

I'd love to see other runtimes expose similar data via HTTP/JSON.  Can Ruby or Python expose similar data?
What about the JVM?  [Rubinius recently discussed their VM metrics support][6], let's see other runtimes do the same!
Make it easy to expose and tooling will appear to support it.


 [1]: http://golang.org/pkg/expvar/
 [2]: http://jsonlint.com
 [3]: http://contribsys.com/inspeqtor
 [4]: http://localhost:8123/debug/vars
 [5]: https://www.datadoghq.com/2014/11/announcing-datadog-agent-5-1-support-btrfs-go-expvar/
 [6]: http://rubini.us/2014/12/10/rubinius-metrics-meets-influxdb/

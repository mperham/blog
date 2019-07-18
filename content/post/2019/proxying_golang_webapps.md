+++
title = "Proxying Golang Web Applications"
date = 2019-07-17T16:26:43-07:00
+++

Recently someone posted an issue asking if [Faktory](https://contribsys/faktory) could support putting
`nginx` in front of Faktory's Web UI.  Normally you access the Web UI
like `http://localhost:7420/` but they wanted it to look something like
`http://somehost:8080/faktory`.  That's quite common when trying to wrap
multiple systems into something that looks like one website to the
browser.

The issue is that the Web UI assumed it was at the root, so
it hardcoded paths like `/static/application.css`.  If you mount the Web
UI at `/faktory`, you want that CSS URL to become
`/faktory/static/application.css`.

After thirty minutes of Googling, I could find nothing on how to solve
this problem so I put on my thinking cap and ground it out over 3-4
hours today.  Here's the scoop.

## nginx Configuration

First, here's the critical nginx configuration to forward `/faktory` to
Faktory at its default URL.  We set a number of headers which might be useful in the future
but only `X-Script-Name` is critical. Note the `/faktory` in the first two lines needs to
stay in sync.

```
location /faktory {
  proxy_set_header X-Script-Name /faktory;

  proxy_pass   http://127.0.0.1:7420;
  proxy_set_header Host $host;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Scheme $scheme;
  proxy_set_header X-Real-IP $remote_addr;
}
```

## Set the Script-Name

`SCRIPT_NAME` is a legacy of CGI but it's used by Python and Ruby apps
to know the proxy prefix for requests coming to an app.  We use a properly
named HTTP header, X-Script-Name, in each request to signal this value to Faktory.

## Abstract that Mux!

Go's http package exposes a Mux type which acts as the router in a Go
webapp. We tell it to route all `/static/` requests like this:

```go
app := http.NewServeMux()
app.HandleFunc("/static/", staticHandler)
```

But this has one very big problem: it doesn't know about the `/faktory`
prefix!

The trick I figured out is to add a special Mux *before* the application
Mux which matches all requests and can unmangle any proxied requests so
they look like an unproxied request to the app Mux:

```go
app := http.NewServeMux()
app.HandleFunc("/static/", staticHandler)

proxy := http.NewServeMux()
proxy.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
  prefix := r.Header.Get("X-Script-Name")
  if prefix != "" {
    r.RequestURI = strings.Replace(r.RequestURI, prefix, "", 1)
    r.URL.Path = r.RequestURI // this is super greasy, not sure it's optimal but Works For Me™
  }
  app.ServeHTTP(w, r)
})
```

## Every Link must be Relative

Within the HTML markup, I had to change every URL and path to use a
helper to generate the relative path with any necessary prefix.

```go
func relative(req *http.Request, relpath string) string {
	return fmt.Sprintf("%s%s", req.Header.Get("X-Script-Name"), relpath)
}
```

```erb
<link href="<%= relative(req, "/static/application.css") %>" ...>
```

`req.Header.Get` returns `""` when there is no value set so the base case is handled smoothly.

## Conclusion

No rocket science here but it was interesting to find a non-trivial HTTP
edge case in Go without a blog post on the subject and very rewarding to
solve it myself. [Here's the big commit that landed in Faktory to add
proxy support.](https://github.com/contribsys/faktory/commit/92d88d33f3a820ad5cc2085b1b12c78b7e5b8ea7)  I hope this helps someone else!

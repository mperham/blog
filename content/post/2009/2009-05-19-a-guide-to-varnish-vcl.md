---
author: Mike Perham
categories:
- Software
date: 2009-05-19T00:00:00Z
title: A Guide to Varnish VCL
url: /2009/05/19/a-guide-to-varnish-vcl/
---

I've been working with Varnish 2.0 for the last two weeks, going from complete n00b to someone who knows enough to feel I can improve the terrible lack of documentation for Varnish and VCL. There's not a lot out there and what's there is hard to find and sometimes erroneous. I'm hoping this post will help others like me who are struggling with Varnish and VCL.

**Basics**

VCL is essentially a set of stubs which you can override to provide your own behavior. It is very limited in what it can do, primarily for performance reasons. You don't have access to the filesystem and the language has no variables or loops.

The two stubs you will most often use:

*   **vcl_recv** -- called at the start of a request. This is primarily used to canonicalize the input URL and headers, determine whether to bypass the cache, etc.
*   **vcl_fetch** -- called when the response has been gathered from the backend before placing it in the cache. You can configure a grace period, enable ESI processing, configure different TTLs, remove user-specific cookies, etc before inserting the response into the cache.

**Examples**

The Varnish VCL examples are rather sparse; here's a few more which may fill in some gaps. These work with Varnish 2.0.4.

```vcl
# If the requested URL starts like "/link/?" then immediately pass it to the given
# backend and DO NOT cache the result ("pass" basically means "bypass the cache").
if (req.url ~ "^/link/?") {
  set req.backend = web;
  pass;
}
```

```vcl
if (req.url ~ "/$") {
  # Handle URLs with a trailing slash by appending index.html
  # (Useful if you are pulling from S3 which does not have default document logic)
  # Note there's no explicit string append operator.
  set req.url = req.url "index.html";
}
```

```vcl
# strip port from the Host header
# (useful when testing against a local Varnish instance on port 6081)
set req.http.Host = regsub(req.http.Host, ":[0-9]+", "");

# /foo/bar.embed -> /foo/bar/embed.js
set req.url = regsub(req.url, "(.*).embed$", "1/embed.js");

# Support feed URLs of the form "/foo/bar.atom" --> "/foo/bar/feed.atom"
if ((req.url ~ ".(rss|atom)$") &#038;&#038; !(req.url ~ "feed.(atom|rss)$")) {
    set req.url = regsub(req.url, "(.*).(.*)$", "1/feed.2");
}
```

The biggest pain in all of this was the very limited logic you can perform on req.url. You don't have variables in VCL so you need to think in terms of regular expression groups like in the RSS/ATOM regexp above when trying to restructure the URL.

```vcl
# use this in vcl_fetch, don't want 404s filling up our cache, so just
# immediately return a client error and bypass the cache.
if (obj.status == 404) {
  error 404 "No such file";
}
```

**Resources**

Here's the best VCL resources I could find:

*   [Varnish VCL][1]
*   [Varnish VCL Examples][2]
*   [VCL Overview (PDF)][3]

Good luck!

 [1]: http://varnish.projects.linpro.no/wiki/VCL
 [2]: http://varnish.projects.linpro.no/wiki/VCLExamples
 [3]: http://phk.freebsd.dk/pubs/varnish_vcl.pdf

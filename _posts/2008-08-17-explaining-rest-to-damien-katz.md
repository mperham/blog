---
title: Explaining REST to Damien Katz
author: Mike Perham
layout: post
permalink: /2008/08/17/explaining-rest-to-damien-katz/
categories:
  - Software
---
This is an excellent summary of REST, why SOAP services should be considered broken and why your services should be RESTful.  One overlooked benefit of REST: interacting with the HTTP ecosystem correctly.  You might not be using a caching proxy on the server-side but if your clients want to use a caching proxy, making your service RESTful means it will behave correctly in unexpected, but legitimate, network architectures.

One fact I did not know: PUT is idempotent, POST is not.

[Explaining REST to Damien Katz][1]

 [1]: http://www.25hoursaday.com/weblog/2008/08/17/ExplainingRESTToDamienKatz.aspx
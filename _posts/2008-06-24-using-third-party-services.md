---
title: Using third-party services
author: Mike Perham
layout: post
permalink: /2008/06/24/using-third-party-services/
categories:
  - Software
---
One interesting tidbit I&#8217;ve learned by building [tracknowledge][1], my race track database and instrumenting it with FiveRuns&#8217;s [Manage][2] service is the ridiculous amount of time required for calling third-party services. If you look at a sample track page, [Donington Park][3], there&#8217;s three services being called: Youtube and Flickr are called server-side and Google Maps is called client-side. According to Manage, 97% of the render time for the track page is spent in calling Flickr and Youtube.

The way I&#8217;ve worked around this in the current incarnation is by using the page caching built into Rails. The first hit to each track is always generated but every hit thereafter is a static HTML page delivered by Apache. More dynamic sites might not be able to cache that aggressively; action or fragment caching could be used to cache just the HTML snippets required for each service&#8217;s block of content.

There&#8217;s a lesson here: **third party services should be mashed up on the client-side if possible for good performance and user experience**. This allows the browser to render the page and asynchronously fill in blank areas as the service responses come back. This goes to show: if you are going to call a 3rd party service, you need to think about contingencies. What happens to your app when the service is down? What happens when the service is sloooow? Caching and asynchronicity are just two mechanisms for dealing with these conditions.

 [1]: http://tracknowledge.org
 [2]: http://fiveruns.com/products/manage
 [3]: http://tracknowledge.org/tracks/996332983-Donington-Park
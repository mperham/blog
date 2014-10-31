---
title: Using svn:externals
author: Mike Perham
layout: post
permalink: /2007/10/19/using-svnexternals/
keywords:
  - subversion svn extern external
categories:
  - Software
---
Subversion allows you to pull external code into your code by using the svn:externals property. It&#8217;s pretty simple to use; assume we have a library &#8220;foo&#8221; which we want to pull into the current directory.  This script will add the external reference for you:

> <pre>TMP=current.tmp

svn pg --strict svn:externals &gt; $TMP
echo "$1 $2" &gt;&gt; $TMP
svn ps svn:externals --file $TMP .
rm $TMP
svn up</pre>

Call it like this:

<pre>extern foo https://svn.myhost.com/source/libraries/foo</pre>
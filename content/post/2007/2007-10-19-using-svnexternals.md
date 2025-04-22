---
author: Mike Perham
categories:
- Software
date: 2007-10-19T00:00:00Z
keywords:
- subversion svn extern external
title: Using svn:externals
url: /2007/10/19/using-svnexternals/
---

Subversion allows you to pull external code into your code by using the svn:externals property. It's pretty simple to use; assume we have a library "foo" which we want to pull into the current directory.  This script will add the external reference for you:

```
TMP=current.tmp

svn pg --strict svn:externals > $TMP
echo "$1 $2" >> $TMP
svn ps svn:externals --file $TMP .
rm $TMP
svn up
```

Call it like this:

```
extern foo https://svn.myhost.com/source/libraries/foo
```

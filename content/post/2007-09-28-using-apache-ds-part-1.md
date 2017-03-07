---
author: Mike Perham
categories:
- Software
date: 2007-09-28T00:00:00Z
keywords:
- apacheds, ldap, osx
title: Using Apache DS, Part 1
url: /2007/09/28/using-apache-ds-part-1/
---

Every business beyond a certain size has an LDAP server. If you want to do anything with users in an enterprise, chances are you'd better understand LDAP. This blog post isn't not going to teach you LDAP **but you need to understand LDAP**. 30 minutes of reading will dramatically improve your understanding of how LDAP works and its terminology. If you don't understand what a Relative Distinguished Name is, stop reading this and go find [an introduction to LDAP][1].

We're going to install [Apache's Directory Service][2] or ApacheDS as it is commonly known. ApacheDS is a good server to use for development as it is lightweight, very easy to install and cross-platform.

1.  Download the latest ApacheDS installer. Mine was 1.5.1 for Mac OS X.
2.  Run the installer. In the case of OSX, it doesn't give any indication as to where things were installed. It actually installs the server in **/usr/local/apacheds**. (This took me way too long to figure out!) We'll call this directory DS_HOME.
3.  Open DS_HOME/server.xml in your favorite text editor. You'll need to configure the server to your own environment. Specifically you'll want to change a couple of items: 
    *   The default admin user and password is right at the top. For development, you should probably just stick with the defaults.
    *   The default LDAP port is 10389, **not** 389, so you don't have to run the server as root. In production, you'll want to run this on the standard LDAP 389 port.
4.  Once the configuration is complete, you can start up the server by running DS_HOME/apacheds.

You should see a bunch of junk printed out, followed by a nice ApacheDS ASCII graphic. Fancy! You're up and running but it's not very useful just yet...

 [1]: http://www.ldapman.org/articles/intro_to_ldap.html
 [2]: http://directory.apache.org/

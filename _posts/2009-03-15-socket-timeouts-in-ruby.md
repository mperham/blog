---
title: Socket Timeouts in Ruby
author: Mike Perham
layout: post
permalink: /2009/03/15/socket-timeouts-in-ruby/
categories:
  - Ruby
---
One of Ruby&#8217;s weaknesses is its poor networking performance. Much of that has to do with the net/http implementation, which uses Ruby&#8217;s awful Timeout library. The issues with Timeout are [well documented][1]. [SystemTimer][2] provides a reliable alternative that also performs better.

However I started today wondering if there was a better way. Enabling timeouts has a huge performance hit on my memcache-client library and reducing the overhead would go a long way to making it perform safely **and** quickly. Since C programs need socket timeouts also, I figured there had to be a low-level alternative, and indeed there is: the `SO_SNDTIMEO` and `SO_RCVTIMEO` socket options. It&#8217;s a bit involved to create a proper socket with these options but possible:

<pre lang="ruby">def connect_to(host, port, timeout=nil)
      addr = Socket.getaddrinfo(host, nil)
      sock = Socket.new(Socket.const_get(addr[0][0]), Socket::SOCK_STREAM, 0)

      if timeout
        secs = Integer(timeout)
        usecs = Integer((timeout - secs) * 1_000_000)
        optval = [secs, usecs].pack("l_2")
        sock.setsockopt Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, optval
        sock.setsockopt Socket::SOL_SOCKET, Socket::SO_SNDTIMEO, optval
      end
      sock.connect(Socket.pack_sockaddr_in(port, addr[0][3]))
      sock
    end
</pre>

There are a few complexities in the code:

*   We use the low-level operations, `Socket.new` and `connect` rather than just `TCPSocket.new(host, port)` because otherwise we can&#8217;t set the socket options before the connection is attempted; we want to ensure the connection attempt itself is timed out also.
*   We have to look up the host via DNS by hand as some systems (\*cough\*, OSX) can return either IPv6 or IPv4 addresses and the address family constant used in Socket.new must match the address used in the connect statement.
*   The `setsockopt` method takes a native C struct so we need to construct it using the `Array#pack` method.

Here&#8217;s the results, from worst to best:

<pre>== memcache-client 1.7.0 with Ruby 1.8.6, normal Ruby timeouts
                                     user     system      total        real
mixed:ruby:memcache-client      14.240000   7.470000  21.710000 ( 22.173267)
</pre>

<pre>== memcache-client 1.7.0 with Ruby 1.8.6, SystemTimer 1.1.1
                                     user     system      total        real
mixed:ruby:memcache-client      12.400000   1.960000  14.360000 ( 14.857924)
</pre>

<pre>== memcache-client 1.7.0 with Ruby 1.8.6, raw socket timeouts
                                     user     system      total        real
mixed:ruby:memcache-client       2.750000   0.620000   3.370000 (  5.841545)
</pre>

<pre>== memcache-client 1.7.0 with Ruby 1.8.6, no socket timeouts
                                     user     system      total        real
mixed:ruby:memcache-client       2.760000   0.620000   3.380000 (  5.902549)</pre>

Awesome. **With raw socket timeouts, there is no performance impact!** SystemTimer provides an excellent replacement for Timeout if you want to guarantee a ceiling on the time spent in an arbitrary block, but if you just need timeouts for low-level socket operations, nothing beats the operating system&#8217;s native socket timeout support.

There is a caveat in the paragraph above: **low-level** socket operations. memcache-client uses three IO methods: read, write and gets. The first two are low-level and time out properly, but gets is built on the low-level read operation; it has to ignore the EAGAIN error in order to ensure it returns a full line of text. So we use a hybrid approach, read and write will use the raw socket timeouts and gets will use SystemTimer. It&#8217;s not quite as fast as with no/raw timeouts but it&#8217;s definitely an improvement:

<pre>== memcache-client 1.7.0 with Ruby 1.8.6, raw socket timeouts and SystemTimer
                                     user     system      total        real
mixed:ruby:memcache-client       7.490000   1.270000   8.760000 (  9.361547)
</pre>

So we&#8217;ve gone from 22 sec with Timeout to 15 sec with SystemTimer to 9 sec using raw socket timeouts where possible ([Github commit][3]). For my next trick, I figure I&#8217;ll rewrite `gets` to use read so I can remove the need for SystemTimer and Timeout altogether.

 [1]: http://blog.headius.com/2008/02/rubys-threadraise-threadkill-timeoutrb.html
 [2]: http://ph7spot.com/articles/system_timer
 [3]: http://github.com/mperham/memcache-client/commit/9f5201b77ccb6ef0d021e741cab8468151f2535d
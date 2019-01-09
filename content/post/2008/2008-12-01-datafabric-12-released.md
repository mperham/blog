---
author: Mike Perham
categories:
- Rails
date: 2008-12-01T00:00:00Z
title: DataFabric 1.2 released
url: /2008/12/01/datafabric-12-released/
---

DataFabric 1.2 supports ActiveRecord 2.2 and its overhauled connection handling. Believe me, this is a good thing. The old connection handling code was awful; the new code is much nicer.

**How It Works**

data_fabric 1.0 supported dynamic connections by proxying the connection stored in the global static connection hash. This is thread-unsafe and therefore didn't support ActiveRecord's multithreaded mode (`allow_concurrency` = true).

data\_fabric 1.2 supports ActiveRecord 2.0 and 2.1 through the exact same code as data\_fabric 1.1 except refactored to load only when those two versions are detected. If ActiveRecord 2.2 or greater is detected, the new proxy code is used. The new proxy works on a per-class basis and overrides the four class methods which make up the public connection API on ActiveRecord::Base:

<pre lang="ruby">def data_fabric(options)
        DataFabric.log { "Creating data_fabric proxy for class #{name}" }
        @proxy = DataFabric::ConnectionProxy.new(self, options)

        class &lt;&lt; self
          def connection
            @proxy
          end

          def connected?
            @proxy.connected?
          end

          def remove_connection(klass)
            DataFabric.log(Logger::ERROR) { "remove_connection not implemented by data_fabric" }
          end

          def connection_pool
            raise "dynamic connection switching means you cannot get direct access to a pool"
          end
        end
      end
</pre>

This proxy is thread-safe in that its mutable state is stored in thread-local variables. Note the latter two methods aren't implemented, for reasons you can see. `remove_connection` would be nice to implement but since we don't use it at FiveRuns, I didn't see any immediate need for it. I would happily accept patches for it.

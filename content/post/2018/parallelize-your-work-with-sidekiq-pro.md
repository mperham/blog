+++
title = "Parallelize your work with Sidekiq Pro"
date = 2018-08-24T09:00:00-07:00
+++

A common issue for Sidekiq users are long jobs: jobs which
process in serial a long list of things.  Why not parallelize that work
and make it a lot faster?

[Map/Reduce](https://en.wikipedia.org/wiki/MapReduce) is a pattern for distributed computing: a list of things is **mapped** onto a set of jobs.
Your Sidekiq workers execute those jobs in parallel and store the results of the work.
Something then **reduces** those calculations into a single result.
In this way, large volumes of work can be done in parallel, speeding up batch processing.

I've got a CSV file which needs to be processed.
Processing each row might involve web crawling or some other intensive work so we can't process it in serial without it taking hours.
We'll create a contrived example where we have a list of webpages and we want to get the bytesize of each page.
We'll use Sidekiq Pro's Batch API to perform the work in parallel:

```csv
id,name,uri
1273,Google,https://google.com
1209,Yahoo,https://yahoo.com
8273,Sidekiq,https://sidekiq.org
```

Now we'll create a worker which kicks off the CSV processing and a worker which processes each row in the CSV.

```ruby
require 'csv'
require 'net/http'

class CSVProcessor
  include Sidekiq::Worker

  # MAP - create a job for each row
  def perform(csv_filename="./pages.csv")
    batch = Sidekiq::Batch.new
    batch.on(:success, self.class, 'filename' => csv_filename)
    batch.jobs do
      CSV.foreach(csv_filename, :headers => true) do |row|
        RowProcessor.perform_async(row.fields)
      end
    end
  end

  # REDUCE - do something with all the results
  def on_success(status, options)
    # Sidekiq Pro will call this once all the RowProcessor jobs are done.
    data, _ = Sidekiq.redis do |conn|
      conn.multi do
        conn.hgetall "crawl-#{status.bid}"
        conn.del "crawl-#{status.bid}"
      end
    end

    data.each_pair do |name, size|
      puts "#{name} is #{size} bytes"
    end
  end
end

class RowProcessor
  include Sidekiq::Worker

  def perform(row)
    name = row[1]
    uri = row[2]
    content = Net::HTTP.get(URI(uri))

    # The only tricky part: we need to store the results
    # somewhere so the callback can gather the data together.
    # Redis is perfect for this.
    # The BID is the Batch ID shared by all jobs in the batch.
    Sidekiq.redis do |conn|
      conn.hset "crawl-#{self.bid}", name, content.bytesize
    end
  end
end
```

The Batch feature tracks the set of jobs and runs any callbacks when all jobs are finished.

I put that CSV data into ./pages.csv.
We kick off the entire process with a simple `CSVProcessor.perform_async`.

Here's the result:

```
2018-08-24T15:19:03.279Z 93268 TID-ov9mbken4 CSVProcessor JID-418bed33391e0d9d23c8151d INFO: start
2018-08-24T15:19:03.286Z 93268 TID-ov9mbken4 CSVProcessor JID-418bed33391e0d9d23c8151d INFO: done: 0.006 sec
2018-08-24T15:19:03.286Z 93268 TID-ov9mbkeg4 RowProcessor JID-97e9e7e8058a48a4cb5dc9dd BID-zFk-b6ZVqoS-6w INFO: start
2018-08-24T15:19:03.290Z 93268 TID-ov9mbkeak RowProcessor JID-754a8ecd713507ca396bf3d7 BID-zFk-b6ZVqoS-6w INFO: start
2018-08-24T15:19:03.294Z 93268 TID-ov9mbkfhk RowProcessor JID-1dfa5546400901f9a16f2181 BID-zFk-b6ZVqoS-6w INFO: start
2018-08-24T15:19:03.442Z 93268 TID-ov9mbkeg4 RowProcessor JID-97e9e7e8058a48a4cb5dc9dd BID-zFk-b6ZVqoS-6w INFO: done: 0.156 sec
2018-08-24T15:19:03.487Z 93268 TID-ov9mbkfhk RowProcessor JID-1dfa5546400901f9a16f2181 BID-zFk-b6ZVqoS-6w INFO: done: 0.193 sec
2018-08-24T15:19:03.647Z 93268 TID-ov9mbkeak RowProcessor JID-754a8ecd713507ca396bf3d7 BID-zFk-b6ZVqoS-6w INFO: done: 0.358 sec
2018-08-24T15:19:04.414Z 93268 TID-ov9mbka0k Sidekiq::Batch::Callback JID-00672f540b4dcc0f5c3d80e7 INFO: start
2018-08-24T15:19:04.420Z 93268 TID-ov9mbka0k Sidekiq::Batch::Callback JID-00672f540b4dcc0f5c3d80e7 INFO: done: 0.006 sec
2018-08-24T15:19:05.428Z 93268 TID-ov9mbkatw Sidekiq::Batch::Callback JID-9cebed28a6fd88f1877dcb46 INFO: start
Google is 11340 bytes
Sidekiq is 19475 bytes
Yahoo is 483535 bytes
```

(Side note: good grief, Yahoo!)

We built a parallel web crawling system in less than 50 lines of Ruby code + Sidekiq Pro.
Nice.

Helpful links:

* [Batches wiki](https://github.com/mperham/sidekiq/wiki/Batches)
* [Batches screencast](https://www.youtube.com/watch?v=b2fI0vGf3Bo&list=PLjeHh2LSCFrWGT5uVjUuFKAcrcj5kSai1)
* [Buy Sidekiq Pro](https://billing.contribsys.com/spro/new.cgi)

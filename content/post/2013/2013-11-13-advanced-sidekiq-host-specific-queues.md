---
author: Mike Perham
categories:
- Sidekiq
date: 2013-11-13T00:00:00Z
title: 'Advanced Sidekiq: Host-specific Queues'
url: /2013/11/13/advanced-sidekiq-host-specific-queues/
---

This is the first in a series of posts offering neat tricks to get the most out of Sidekiq.

Recently we rewrote part of The Clymb to process images asynchronously using Sidekiq. The user uploads the image file, it is saved to disk and a job created to process the file. Almost immediately we saw a bunch of retries with the error "Unable to find file xyz.jpg". We just uploaded the file, how could it not be there?

The problem is that we have multiple app servers and they all run Unicorn and Sidekiq. This means the file can be uploaded to a Unicorn on app-1 and the job processed by a Sidekiq on app-2. The job queue is global to the cluster but the filesystem is local. The solution is a cool hack: use a queue which is processed only by Sidekiq processes on that server.

First we need to tell each Sidekiq process to listen to a queue named after the machine's hostname. In your `config/sidekiq.yml`, do this:

```
---
:verbose: false
:concurrency: 25
:queues:
  - default
  - <%= `hostname`.strip %>
```

Sidekiq runs the YAML file through ERB automatically so you can easily add the queue dynamically.

Second, we need to configure the jobs to use the queue:

```ruby
class ImageUploadProcessor
  include Sidekiq::Worker
  sidekiq_options queue: `hostname`.strip

  def perform(filename)
    # process image
  end
end
```

Now when we create an ImageUploadProcessor job, it will be saved to a queue named after the machine's hostname and processed by a Sidekiq worker on that machine. Easy!

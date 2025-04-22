---
author: Mike Perham
categories:
- Rails
date: 2007-10-02T00:00:00Z
keywords:
- ruby, rails, merb, jmeter, file, upload
title: File Uploads in Merb versus Rails
url: /2007/10/02/file-uploads-in-merb-versus-rails/
---

<p>At <a href="http://www.fiveruns.com/">FiveRuns</a>, we have a set of installed clients which upload data to our service periodically.  Because of the way it is implemented, Rails is quite slow in handling file uploads.  Merb is an alternative, albeit much simpler, stack to Rails which handles file uploads in a much saner manner.  The performance difference is quite large.</p>
<p><strong>Optimizations</strong></p>
<p>Merb -- turned off ActiveRecord, environment to production, log level to warn, disabled sessions globally.</p>
<p>Rails --  environment to production, log level to warn, disabled sessions for the controller.</p>
<p>The Merb controller code:</p>
```ruby
  def put
    FileUtils.mv params[:file][:tempfile].path, MERB_ROOT+"/uploads/#{params[:file][:filename]}.#{next_count}"
    render :action => 'index'
  end
```
<p>The Rails controller code:</p>
```ruby
  def put
    File.open(RAILS_ROOT+"/uploads/#{params[:file].original_filename}.#{next_count}", "w") { |f| f.write(params[:file].read) }
    render :action =&gt; 'index'
  end
```

<p>I used <a href="http://jakarta.apache.org/jmeter/">Apache JMeter</a> to create a group of 25 users trying to upload a 250k image as fast as possible.  On a side note, I can't recommend JMeter highly enough.  I downloaded it and was generating this load within 10 minutes.  The user manual walked me through the basics and the UI had exactly the controls I need to create the FORM POST.</p>
<p>Without further ado, here's the results.</p>
<p><a href="http://www.mikeperham.com/wp-content/uploads/2007/10/merb.png" title="merb results"><img src="http://www.mikeperham.com/wp-content/uploads/2007/10/merb.thumbnail.png" alt="merb results" /></a><a href="http://www.mikeperham.com/wp-content/uploads/2007/10/rails.png" title="rails results"><img src="http://www.mikeperham.com/wp-content/uploads/2007/10/rails.thumbnail.png" alt="rails results" /></a></p>
<p>I'm not sure how to read these results.  Merb's average response time is 16 ms while Rails's average is 205 ms (over 10x faster), yet the throughput is 3000 vs 2000 req/min (only 50% greater).  Note that Merb seems to be much more deterministic in the response times.  Rails response handling times appear to fluctuate wildly while the Merb results have a much tighter standard deviation.  These results remind me of the old proverb: "Data is not information and information is not knowledge".  While the specifics are still a little unclear, it is clear to me that Merb is several times faster than Rails at just handling file uploads.</p>

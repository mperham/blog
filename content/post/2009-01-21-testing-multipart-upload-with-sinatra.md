---
author: Mike Perham
categories:
- Ruby
date: 2009-01-21T00:00:00Z
title: Testing Multipart Upload with Sinatra
url: /2009/01/21/testing-multipart-upload-with-sinatra/
---

Here's how we create multipart uploads in our test suite for testing with Sinatra 0.3, similar to the `post_it` test helper method:

<pre lang="ruby">def upload_it(path, params, rack_opts, file)
    @request = Rack::MockRequest.new(Sinatra.build_application)
    opts = normalize_rack_environment(opts)
    input = FiveRuns::Multipart::FileUpload.new(file, params)
    opts[:input] ||= input.to_s
    opts['CONTENT_TYPE'] = input.content_type
    opts['CONTENT_LENGTH'] = opts[:input].length
    @response = @request.request('POST', path, opts)
  end
</pre>

You can use it as such:

<pre lang="ruby">filedata = Zlib::Deflate.deflate({'foo' => 'bar'}.to_json)
    other_params = {"pid"=>"20256"}
    upload_it "/apps/#{app.token}/processes.json", other_params, {}, StringIO.new(filedata)
</pre>

Here's the multipart helper: [multipart.rb][1]. I hope this saves someone a few hours of experimentation out there!

 [1]: http://www.mikeperham.com/wp-content/uploads/2009/01/multipart.rb

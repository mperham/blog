---
author: Mike Perham
categories:
- Ruby
date: 2011-02-15T00:00:00Z
title: Filling out PDF forms with JRuby
url: /2011/02/15/filling-out-pdf-forms-with-jruby/
---

I recently had to figure out how to programmatically fill out a PDF based on the form input from a Rails application. It looks like there's nothing native to Ruby but there is a comprehensive PDF library called [iText][1] which will handle [form][2] duties. Using JRuby, we can access their Java API to fill out the form pretty easily:

<pre lang="ruby">require 'java'
require 'iText-5.0.6.jar'

module Pdf
  include_package "com.itextpdf.text.pdf"
  include_package "java.io"

  def self.write
    reader = PdfReader.new('application.pdf');
    stamper = PdfStamper.new(reader, FileOutputStream.new('completed.pdf'))
    form = stamper.acro_fields
    puts "Form has these fields: #{form.fields.key_set.to_a}"
    form.set_field("some_zipcode_field", "94115")
    stamper.close
  end
end

Pdf.write
</pre>

Obviously sample code, not production quality, etc. Really the only hard/tedious part is mapping field names to Ruby object attribute values. If you have a complex form, you may have tens or even hundreds of `set_field` calls.

 [1]: http://api.itextpdf.com/
 [2]: http://itextpdf.com/themes/keyword.php?id=247

---
title: '12 Gems of Christmas #8 &#8211; wicked_pdf'
author: Mike Perham
layout: post
permalink: /2012/12/05/12-gems-of-christmas-8-wicked_pdf/
categories:
  - Ruby
---
We recently rolled out gift certificates in time for the holiday shopping season at [The Clymb][1] and one of our major implementation hurdles was a very innocent feature request: send the certificate via email as a PDF.

How on earth do I create a PDF? I&#8217;m a web developer &#8211; HTML/CSS is no problem &#8211; but PDF is a binary format and making a PDF with a &#8220;nice&#8221; design is way out of my bailiwick. [wicked_pdf][2] to the rescue! wicked_pdf wraps the `wkhtmltopdf` command line tool which can convert an HTML file into a PDF file for offline access or printing purposes. Our email code is simple: we render the HTML content and then pass it to WickedPdf for conversion.

<pre lang="ruby">pdf_str = render_to_string(:template => 'emails/gift_certificate',
                           :layout => false,
                           :locals => { :amount => number_to_currency(amount),
                                        :product_code => pc.code } )
pdfs &lt;&lt; WickedPdf.new.pdf_from_string(pdf_str)
</pre>

With wicked_pdf, we didn't have to sacrifice the tools and technologies we know best in order to support PDF files. We rolled out the feature on time and no web developers were harmed in the process.

I couldn't resist this platform to plug one of my own gems; tomorrow I'll cover my own favorite, under-utilized creation.

 [1]: http://theclymb.com/invite-from/mperham
 [2]: https://github.com/mileszs/wicked_pdf
---
author: Mike Perham
categories:
- Ruby
date: 2009-06-12T00:00:00Z
title: Scraping with Typhoeus and Nokogiri
url: /2009/06/12/scraping-with-typhoeus-and-nokogiri/
---

I've been working on some cool new functionality at [OneSpot][1]. We want to provide a widget that can give the reader more context about a given article. [Zemanta][2] takes the article text and hands us back a set of semantic entities, including links to their Wikipedia page, but we wanted to get a nice blurb about each entity and figured that the opening paragraph from the Wikipedia page would be reasonable.

To do this, we use [Typhoeus][3] to fetch the Wikipedia pages in parallel and [Nokogiri][4] to pull the relevant content using a custom XPath expression for Wikipedia's page layout.

Some notes:

*   We configure Typhoeus to use Rails's cache store for its own cache store. We cache the Wikipedia response for 7 days in order to be good Netizens and not overburden their servers.
*   Wikipedia links do not specify a hostname so we make them absolute so the links will work embedded in another page.
*   We tried Curl::Multi but it was giving us occasional bus errors.
*   My wordpress syntax highlighter is obviously subpar when it comes to regular expressions.

<pre lang="ruby">require 'typhoeus'
require 'nokogiri'

class Wikipedia
  include Typhoeus
  #self.cache = Rails.cache.instance_variable_get(:@data)

  remote_defaults :cache_responses => 7*24*60*60,
      :user_agent => 'typhoeus crawler',
      :timeout => 5

  define_remote_method :extract,
      :on_success => lambda {|response| Wikipedia.extract_first_paragraph(response.body) }

  def self.extract_first_paragraph(content)
    nh = Nokogiri::HTML(content)
    str = nh.xpath("//div[@id='bodyContent']/p[1]").inner_html
    str.gsub /href="/wiki/, 'href="http://en.wikipedia.org/wiki'
  end
end
</pre>

And here's how you use it.

<pre lang="ruby">entities = %w(

http://en.wikipedia.org/wiki/Garth_Marenghi's_Darkplace


http://en.wikipedia.org/wiki/Bus_error


http://en.wikipedia.org/wiki/Washington

)
    content = entities.map do |url|
      Wikipedia.extract(:base_uri => url)
    end
    p content
</pre>

 [1]: http://www.onespot.com
 [2]: http://www.zemanta.com
 [3]: http://github.com/pauldix/typhoeus
 [4]: http://github.com/tenderlove/nokogiri

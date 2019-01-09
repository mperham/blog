---
author: Mike Perham
categories:
- Ruby
date: 2007-09-29T00:00:00Z
keywords:
- ruby ldap
title: Accessing LDAP from Ruby
url: /2007/09/29/accessing-ldap-from-ruby/
---

Ok, we've got our nifty Apache DS running with some custom data. This doesn't do much unless our application can access the data in order to perform some sort of logic. So let's connect the two worlds!

Make sure your Apache DS server is up and running. We first need to install a Ruby API for accessing LDAP. I found the simplest to use was ruby-net-ldap:

> <pre>gem install ruby-net-ldap</pre>

Next, create a simple ldaptest.rb file to use the API:

<pre>require 'net/ldap'

username = 'uid=admin,ou=system'
password = 'secret'
ldap_con = Net::LDAP.new( {:host =&gt; 'localhost', :port =&gt; 10389, :auth =&gt;
    { :method =&gt; :simple, :username =&gt; username, :password =&gt; password }} )
treebase = "dc=fiveruns,dc=com"
op_filter = Net::LDAP::Filter.eq( "objectClass", "person" )
ldap_con.search( :base =&gt; treebase, :filter =&gt; op_filter, :attributes=&gt; 'dn') do |entry|
  puts "DN: #{entry.dn}"
end</pre>

Running it should give this output:

> mikeperham:~$ ruby -rubygems ldaptest.rb  
> DN: uid=mike,ou=engineering,dc=fiveruns,dc=com

It works! Everything from this point on is just gravy. You can explore the [ruby-net-ldap rdoc][1] in more depth or try more advanced libraries like [ActiveLdap][2].

 [1]: http://www.gemjack.com/gems/ruby-net-ldap-0.0.4/index.html
 [2]: http://wiki.rubyonrails.org/rails/pages/ActiveLDAP

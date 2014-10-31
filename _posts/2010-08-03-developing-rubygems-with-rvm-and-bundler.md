---
title: Developing Rubygems with RVM and Bundler
author: Mike Perham
layout: post
permalink: /2010/08/03/developing-rubygems-with-rvm-and-bundler/
categories:
  - Ruby
---
It&#8217;s safe to say that RVM and Bundler have completely changed how I interact with my Ruby applications and gems. It&#8217;s pretty well understood how to use each by itself, I didn&#8217;t have a good idea how to use them in tandem until recently. Parts of this post are based on [Derek Kastner&#8217;s great post on using Bundler][1].

When I grab the source for a random rubygem from github and want to run its tests or test drive it, I use RVM and Bundler to create a sandbox so I don&#8217;t pollute the gems used by other Ruby projects on my box:

<pre lang="bash">rvm use 1.9.2@&lt;gemname> --create
  gem install bundler --pre
# Would love to see this cleaned up for bundler 1.0
# e.g. bundle install --from-gemspec
  cat > Gemfile &lt;&lt;eom
source 'http://rubygems.org'
gemspec :path => '.'
EOM
  bundle install
  rake
</pre>

The only trick here is using Bundler&#8217;s support for gemspecs to avoid the need for a separate (and redundant) Gemfile. But [Andre Arko suggests that we prefer Bundler][2] to Jeweler and I agree with him. [Jeweler should check for an existing Gemfile][3] and defer to it for dependencies when generating the gemspec:

<pre lang="ruby">require 'bundler'
Gem::Specification.new do |s|
  s.add_bundler_dependencies
end
</pre>

This means that **gems should check in their gemspec into git** and jeweler (or however you are generating your gemspec) should be declared as a development dependency. Do your gems pass this simple test? Any thoughts on how to make this even simpler?

 [1]: http://numbers.brighterplanet.com/2010/07/28/bundler-to-the-max/
 [2]: http://andre.arko.net/2010/05/01/bundler-for-gem-development/
 [3]: http://github.com/technicalpickles/jeweler/issues#issue/120
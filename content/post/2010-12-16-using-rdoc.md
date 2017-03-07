---
author: Mike Perham
categories:
- Ruby
date: 2010-12-16T00:00:00Z
title: Using RDoc
url: /2010/12/16/using-rdoc/
---

One longstanding weakness with the Ruby community is subpar documentation. I think many Rubyists tend to look down on actual API documentation, preferring instead to just read source code directly. I've been guilty of this too and I think some of this is due simply to unfamiliarity with RDoc. Let's change that now.

**Creating RDoc**

I've never found an easily accessible RDoc markup reference. The only one I know of is unlinkable, buried at the bottom of the RDoc readme instead of front and center as it should be. So I extracted the [RDoc markup reference][1] for your reading pleasure. Jan Varwig created a great [RDoc cheatsheet PDF][2] for local or offline access.

Next time you're working on a gem, take 10 minutes to read the reference and document the main class for the gem. It'll make you a better Rubyist, I guarantee it.

**Generating RDoc**

Ok, so you've learned RDoc markup and your code is documented like a champ. What do you do now? You've got several choices:

*   Generate rdoc by hand -- the `rdoc` command ships with Ruby and by default generates all .rb files in or below the current directory. You probably want something like `rdoc lib` to just include your project's main Ruby code.
*   Integrate RDoc into Rake -- Rake has an [RDocTask][3] which can be configured for your project, so you can just run `rake rdoc`.

Once generated, you can view the generated output at `doc/index.html`.

**Viewing RDoc**

Rubygems has built-in support for generating and viewing the RDoc for installed gems. rdoc is generated when the gem is installed (using `gem install --no-rdoc [name]` skips the local rdoc generation). You can then use `gem server` to view your local gem rdoc at <http://localhost:8808>.

**Check out YARD**

[YARD][4] is an interesting project by Loren Segal to create a next generation Ruby documentation system. [Getting started with YARD][5] is well documented; try it out if you want an alternative to RDoc. YARD's syntax is a superset of RDoc's so backwards compatibility should not be an issue. The [generated documentation][6] looks pretty awesome (note the support for Markdown-formatted README files, which RDoc does not have).

The YARD team also created [RubyDoc.info][7], which hosts documentation for popular gems and is a great resource for finding linkable documentation.

I hope this helps de-mystify rdoc for people. Any other rdoc tips, please leave a comment. Happy documenting!

 [1]: http://www.mikeperham.com/wp-content/uploads/2010/12/rdoc.html
 [2]: http://jan.varwig.org/wp-content/uploads/2006/09/Rdoc%20Cheat%20Sheet.pdf
 [3]: http://rake.rubyforge.org/classes/Rake/RDocTask.html
 [4]: http://yardoc.org
 [5]: http://rubydoc.info/docs/yard/file/docs/GettingStarted.md
 [6]: http://rubydoc.info/github/mperham/dalli/master/frames
 [7]: http://rubydoc.info/

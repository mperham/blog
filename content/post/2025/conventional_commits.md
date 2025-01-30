---
title: "Conventional Commits"
date: 2025-01-30T11:27:04-08:00
publishdate: 2025-01-30
lastmod: 2025-01-30
draft: true
tags: []
---

[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) is a defacto standard for writing commit messages in a manner more useful for both humans and machines. Examples:

```
feat(batches): adjust callback data model to conform to naming standards
ci: add ruby 3.4 to matrix
style: upgrade standard formatting
```

I learned of conventional commits recently and like the simplicity and ease of use.
I want to use this standard going forward for all of my projects but I had one problem: how do I train myself to use this every time?
It's too easy to forget or skip without some sort of prompt or cheatsheet so that's exactly what I did!

git supports a template for commit messages and any lines that start with `#` are ignored. I added this as `~/.gitmessage`:

```
# type(subsystem): short description
### Types
# feat: A new feature
# fix: A bug fix
# docs: Documentation only changes
# build: Changes that affect the build system or external dependencies
# ci: Changes to our CI configuration files and scripts
# perf: A code change that improves performance
# refactor: A code change that neither fixes a bug nor adds a feature
# style: Changes that do not affect the meaning of the code
# test: Adding missing tests or correcting existing tests
```

and then adjusted `~/.gitconfig` like this:

```
[commit]
  template = ~/.gitmessage
```

Now when I run `git commit`, it shows me the block of text which reminds me of the different categories.
I hope this helps someone else!
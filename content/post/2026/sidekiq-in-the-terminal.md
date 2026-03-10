---
title: "Sidekiq in the terminal"
date: 2026-03-10T10:35:10-07:00
publishdate: 2026-03-10
lastmod: 2026-03-10
tags: []
---

My favorite tech movement in 2025 wasn't anything artifical, but rather the resurgence in interest around building terminal interfaces with two new frameworks.
[Charm](https://charm.land) and [Ratatui](https://ratatui.rs) which make developing pure text user interfaces easier than ever before using Go or Rust.
They provide a huge set of [components](https://www.ratatui.rs/showcase/widgets/) and [examples](https://github.com/charmbracelet/bubbletea/tree/main/examples) showing you how to build various types of functionality.

Mainframe applications ruled the 70s and 80s, providing terminal interfaces for business operations.
You might still see a ticket agent using a terminal to check you in at the airport.
That's an interface to a mainframe application, allowing the agent to lookup your ticket and assign you a seat quickly, with just a few keystrokes.
To this day I remember my mom, a pharmacist, complaining about the new DOS -> Windows upgrade that the IT department rolled out to stores.
Navigating their retail point of sale terminal application was much faster with a keyboard, the Windows version required a stream of precise mouse clicks and couldn't rely on typing by muscle memory.
Today interactive terminal interfaces are rare but I think Charm and Ratatui make this option much easier to provide.

## Old Man shouts at Cloud

To quote a wise man:

> The web browser is a terrible interface for many tasks --me, 2026

He makes a great point.
Web browsers tend to be complex and quite difficult to program application user interface logic, requiring expertise in HTML, CSS, JS.
But for many ["line of business"](https://en.wikipedia.org/wiki/Line_of_business) applications, a keyboard-based terminal interface can be much faster in a far more secure environment, with none of the browser security concerns around accessing remote content and executing JavaScript.

Tasks are often quite simple:

0. navigate to feature
1. display a list of data
2. choose a subset via filtering or manual selection
3. take some action

Basic CRUD operations are also common, think of any admin web interface using scaffolding or gems like `active_admin`, `rails_admin` or Avo.
For many tasks and use cases, using a text interface could operate much faster and is far simpler and easier to develop and maintain.
I'm thinking of things like Mastodon's admin tools and Sidekiq's own Web UI.
Some moderation tools work on user posts, others on job retry sets!

<figure>
  <img alt="kiq" src="/images/kiq.png">
  <figcaption>
    <small>
      Four scheduled jobs selected, notice the Controls at the bottom where I can Delete, Enqueue or Kill the selected jobs with a keystroke.
    </small>
  </figcaption>
</figure>


So with that context in mind, for the last few months I've been iterating on `kiq`, a new administration interface for Sidekiq, a speedy terminal application based on Kerrick Long's [ratatui_ruby](https://www.ratatui-ruby.dev) gem.
It's not a 100% clone of Sidekiq's Web UI, some of the missing bits are intentional, some are TBD due to the different environments.
It's also very beta in performance and polish; we'll improve that over time but I would not use kiq in production just yet.
You can try it out locally if you're already running Sidekiq 8.1:

```ruby
# in your Gemfile, need to use the main branch
gem "sidekiq", github: "sidekiq/sidekiq"
gem "ratatui_ruby"

# now run
bundle install
bundle exec kiq
# Set REDIS_URL or REDIS_PROVIDER to talk to another Redis over the network
REDIS_URL=redis://redis.example.com:6379/0 bundle exec kiq
```

I don't think terminals are good for information dense views/graphs like the Home and Metrics tabs.
Maybe those screens should be removed or redesigned to focus on tables of text rather than display a low fidelity graph.
That's where your opinion matters!
Which Sidekiq admin tasks or use cases can we improve with `kiq`?
Please send me feedback via [this Discussion](https://github.com/sidekiq/sidekiq/discussions/6946) and we'll make it better together!

## An Idle Thought

> If Ratatui is replacing the web interface, who's going to build a proper application framework on top of Ratatui? [Rooibos](https://www.rooibos.run) provides an interesting, Ractor-friendly routing API. I think there's lots of potential for innovation here if someone wants to build the next big open source project for Ruby.

## Special Thanks

Thank you so much to Felipe Vogel and Kerrick Long for their work over the last few months.
Felipe has contributed substantially to `kiq`'s implementation and Kerrick has provided help and quick bug fixes to [ratatui_ruby](https://github.com/setdef/RatatuiRuby?tab=readme-ov-file#ratatui_ruby).
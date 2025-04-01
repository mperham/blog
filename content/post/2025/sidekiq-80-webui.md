---
title: "Sidekiq 8.0: Improvements to the Web UI"
date: 2025-04-01T12:07:17-07:00
publishdate: 2025-04-01
lastmod: 2025-04-01
tags: []
---

Since its release last month, Sidekiq 8.0 has been very smooth with few reported issues.
I've been quite happy with the rollout and wanted to provide a little more context about the changes.
My goals for any user-friendly, high quality software is to reduce dependencies and keep it simple.
Sidekiq 8.0 brings a significant overhaul to its Web UI and these changes further those goals.

The Web UI was introduced in 2012 in Sidekiq 0.9 and used Sinatra for its framework along with Twitter Bootstrap for CSS.
Sidekiq 4.2 removed the Sinatra dependency (thanks @badosu!) and made the Web UI a plain Rack app with no framework.

## Vanilla CSS

Sidekiq 8.0 removes the Bootstrap CSS framework and uses [vanilla CSS](https://github.com/sidekiq/sidekiq/blob/main/web/assets/stylesheets/style.css).

Historically web developers had to use a build process to generate CSS because the CSS standard didn't support variables (so things like colors were hardcoded everywhere).
This was the value that Bootstrap provided to Sidekiq: we built it once so Sidekiq didn't need a build process, we just used the generated classes in bootstrap.css.

But Bootstrap has changed significantly since we last touched it. We were using v3.3.7 from 2016 and they are on v5.3.3 now, with each major version requiring significant CSS changes.
Upgrading proved to be difficult, I attempted it once or twice and quickly gave up. I opened an issue and hoped for a miracle.

My front end and UX skills may be minimal but the Open Source community is amazing.
@antoinem saw the open issue and [migrated Sidekiq's CSS](https://github.com/sidekiq/sidekiq/pull/6551).
Modern CSS supports variables so we can DRY up the CSS classes and don't need Bootstrap or a build process anymore.

```css
:root {
  --color-primary: oklch(48% 0.2 13);
  --color-bg: oklch(99% 0.005 256);
  --color-elevated: oklch(100% 0 256);
  --color-border: oklch(95% 0.005 256);
}
```

```css
body {
  background: var(--color-bg);
  color: var(--color-text);
}
```

Special attention was paid to color accessibility to ensure enough contrast for easy reading.
My eyes aren't as young as they were in 2012!

Also note that any framework will contain pieces that we don't use.
Bootstrap.css was 165k in size.
Our vanilla CSS is 16k in size, an order of magnitude smaller!

## Internals

Much of the web internals hadn't changed since 4.2 and as it was written by someone else, I was not confident in my own understanding of how it worked.
[I refactored much of it](https://github.com/sidekiq/sidekiq/pull/6532) to help my own understanding and to remove any unnecessary code.
For instance, helper methods now distinguish between route and URL parameters, preventing an attacker from overriding one type with another.

The other major refactoring was providing a configuration API.
Before, Sidekiq::Web's configuration API was ad hoc, we now have a proper API which looks similar to the existing Sidekiq configuration APIs:

```ruby
# config/routes.rb
require "sidekiq/web"
Sidekiq::Web.configure do |config|
  config.register(Some::Extension, ...)
  config.use Some::Rack::Middleware
  config.app_url = "https://acmecorp.com"
end
```

## Profiling

Before I started my refactoring, I explicitly wanted to get a baseline for performance.
I ran Sidekiq::Web 7 through Vernier to see the current performance and was shocked at how bad it was.
Empty pages were taking 50-100ms to render.
Vernier made it very easy to find the bug: loading YAML files on every request due to incorrect caching.
Empty pages now render in 1-3ms; the fix was backported to 7.3.

**Profile your code, Dear Reader!**
You'll be amazed at the low hanging fruit and easy wins you can find with just a few minutes of investigation.

## Summary

The fact that the Web UI has been so stable for the last decade is a point in favor of my rules: reduce dependencies, keep it simple.
Open standards like CSS change very slowly but improvements like variables allowed us to remove a dependency and shrink our total CSS size by an order of magnitude.

Much faster rendering. 10x smaller CSS. I hope you find Sidekiq 8's Web UI incredibly fast and a delight to use.

❤️❤️❤️
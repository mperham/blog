---
author: Mike Perham
categories:
- Rails
date: 2009-04-18T00:00:00Z
title: Engines in Rails 2.3
url: /2009/04/18/engines-in-rails-23/
---

Engines have been around Rails for years but it wasn't until the recent 2.3 release that Rails officially supported Engines. So what is an Engine? An Engine is a Rails plugin with full MVC capabilities. In essence, that means your Engine has an app directory with helpers, controllers, models and views just like a standard Rails application. You add an engine to `vendor/plugins` or through `config.gem` in your application, just like a plugin, but additionally its app directory is effectively overlaid on top of your application's app directory.

Let's spelunk through the code:

`rails-2.3.2/lib/rails/plugin/loader.rb`

```ruby
def configure_engines
  if engines.any?
    add_engine_routing_configurations
    add_engine_controller_paths
    add_engine_view_paths
  end
end

def add_engine_routing_configurations
  engines.select(&:routed?).collect(&:routing_file).each do |routing_file|
    ActionController::Routing::Routes.add_configuration_file(routing_file)
  end
end

def add_engine_controller_paths
  ActionController::Routing.controller_paths += engines.collect(&:controller_path)
end

def add_engine_view_paths
  # reverse it such that the last engine can overwrite view paths from the first, like with routes
  paths = ActionView::PathSet.new(engines.collect(&:view_path).reverse)
  ActionController::Base.view_paths.concat(paths)
  ActionMailer::Base.view_paths.concat(paths) if configuration.frameworks.include?(:action_mailer)
end
```

For each engine, we add any routes, any controllers and any views. Additionally, the directories within app will be added to the global LOAD_PATH, as with a normal application. Note that engines are processed in order exactly like plugins: alphabetically or based on the order they are listed in `config/environment.rb`.

There are some limitations you should be aware of:

*   No migration support: while the engine can add models, it is not obvious how to manage any database structure needed by the engine. I would imagine the engine should use the install.rb hook to copy migrations to the app's `db/migrate` directory.
*   No public asset support: like migrations, any stylesheets, javascripts or images must be copied as part of the install.rb hook to the app's public directory.
*   Like plugins, naming becomes a concern. An engine can have a User model but this will lead to problems with the 90% of Rails applications that have a model of the same name. You can put your models within a module but I've heard of problems when trying to mix Rails autoloading with modularized classes. As with plugins, be sure to err on the side of safety and use a unique name for your classes. I'm building an engine called **Queso** and it provides a model called **QuesoSearch**, which is unlikely to collide with application classes unless you are building an application for a Mexican cheese provider. :-)

So while Engines do have some limitations to be aware of, they do fill a valuable niche; engines provide a good framework for building full-stack generic application functionality. [ActiveScaffold][1] is one example of a Rails plugin that would be an excellent choice to rewrite as an Engine.

 [1]: http://activescaffold.com

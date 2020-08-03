---
title: Open source status update, July 2020
permalink: 2020/08/03/open-source-status-update-july-2020
published_at: 2020-08-03 22:30:00 +1000
---

July was a great month for my work on Hanami!

After a feeling like I stalled a little [in June](/writing/2020/06/28/open-source-status-update-june-2020/), this time around I was able to get to the very end of my initial plans for application/action/view integration, as well as improve clarity around comes next for our 2.0 efforts overall.

## Getting closer on extensible component configuration

Whenever I’ve worked on integrating the configuration of the standalone Hanami components (like hanami-controller or view) into the application core, I’ve asked myself, “if the app author chose _not_ to use this component, would the application-level configuration still make sense?” I wanted to avoid baking in too many assumptions about hanami-controller or hanami-view particulars into the config that you can access on `Hanami.application.config`.

In the long term, I hope we can build a clean extensions API so that component gems can cleanly register themselves with the framework and expose their configuration that way. In the meantime, however, we need to take a practical, balanced approach, to make it easy for hanami-controller and hanami-view to do their job while still honouring that longer-term goal in spirit.

I’m happy to report that I think I’ve found a pretty good arrangement for all of this! You can see it in action with we we load the `application.config.actions` configuration:

```ruby
module Hanami
  class Configuration
    attr_reader :actions

    def initialize(env:)
      # ...

      @actions = begin
        require_path = "hanami/action/application_configuration"
        require require_path
        Hanami::Action::ApplicationConfiguration.new
      rescue LoadError => e
        raise e unless e.path == require_path
        Object.new
      end
    end
  end
end
```

With this approach, if the hanami-controller gem is available, then we’ll make its own `ApplicationConfiguration` available as `application.config.actions`. This means the hanami gem itself doesn’t need to know _anything else_ about how action configuration should be handled at the application level. This kind of detail makes much more sense to live in the hanami-controller gem, where those settings will actually be used.

Let’s take a look at that:

```ruby
module Hanami
  class Action
    class ApplicationConfiguration
      include Dry::Configurable

      # Define settings that are _specific_ to application integration
      setting :name_inference_base, "actions"
      setting :view_context_identifier, "view.context"
      setting :view_name_inferrer, ViewNameInferrer
      setting :view_name_inference_base, "views"

      # Then clone all the standard settings from Action::Configuration
      Configuration._settings.each do |action_setting|
        _settings << action_setting.dup
      end

      def initialize(*)
        super

        # Apply defaults to standard settings for use within an app
        config.default_request_format = :html
        config.default_response_format = :html
      end

      # ...
    end
  end
end
```

This configuration class:

- (a) Defines settings specifically for the `Hanami::Action` behaviour activated only when used within a full Hanami app
- (b) Clones the standard settings from `Hanami::Action::Configuration` (which are there for standalone use) and makes them available
- (c) Then tweaks some of the default values of those standard settings, to make them fit better with the full application experience

This feels like an ideal arrangement. It keeps the `ApplicationConfiguration` close to the code in `ApplicationAction`, which uses those new settings. It means that all the application integration code can live together and evolve in sync.

Further, because `Hanami::Action::ApplicationConfiguration` exposes a superset of the base `Hanami::Action::Configuration` settings, we can make it so any `ApplicationAction` (i.e. any action defined within an Hanami app) automatically _configures every aspect of itself_ based on whatever settings are available on the application!

So for the application author, the result of all this groundwork should be a blessedly unsurprising experience: if they’re using hanami-controller, then they can go and tweak whatever settings they want right there on `Hanami.application.config.actions`, both the basic action settings as well as the integration-specific settings (though most of the time, I hope the defaults should be fine!).

When we do eventually implement an extensions API, we can at that point just remove the small piece special-case code from `Hanami::Application::Configuration` and replace it with hanami-controller reigstering itself and making its settings available.

If you’re interested in following these changes in more detail, check out [hanami/hanami#1068](https://github.com/hanami/hanami/pull/1068) for the change from the framework side, and then [hanami/controller#321](https://github.com/hanami/controller/pull/321) for the `ApplicationConfiguration` and [hanami/controller#320](https://github.com/hanami/controller/pull/320) for the self-configuring application actions. (I also took an initial pass at this in [hanami/hanami#1065](https://github.com/hanami/hanami/pull/1065), but that was surpassed by all the changes linked previously - I took small steps, and learnt along the way!)

I also made matching changes to view configuration. All the same ideas apply: if you have hanami-view loaded, you’ll find an `Hanami.application.config.views` with all the view settings you need, and then application views will self-configure themselves based on those values! Check out [hanami/hanami#1066](https://github.com/hanami/hanami/pull/1066) and [hanami/view#176](https://github.com/hanami/view/pull/176) for the implementation.

## Fixed `handle_exception` inside actions

One of the settings on Hanami::Action classes is its array of `config.handled_exceptions`, which you can also supply one-by-one through the `config.handle_exception` convenience method.

It turns out another `handle_exception` still existed as a class method, clearly an overhang of the previous action behaviour. [I took care of removing that](https://github.com/hanami/controller/pull/323), so now there should be no confusion whenever action authors configure this behaviour (especially since the old class-level method didn’t work with inheritence).

## Automatically infer paired views for actions

Believe it or not, the work so far only took me about half-way through the month! This left enough time to roll through all my remaining “minimum viable action/view integration” tasks!

First up was inferring paired views for actions. The idea here is that if you’re building an Hanami 2 app and following the sensible convention of matching your view and action names, then the framework can take care of auto-injecting an action’s view for you.

So if you had an action class like this:

```ruby
class Main
  module Actions
    module Articles
      class Index < Main::Action
        include Deps[view: "views.articles.index"]

        def handle(request, response)
          response.render view
        end
      end
    end
  end
end
```

Now, you can drop that `include Deps[view: "…"]` line. A matching view will now automatically be available as the `view` for the action!

This works even for RESTful-style actions too. For example, an `Actions::Articles::Create` action would have an instance of `Views::Articles::New` injected, since that’s the view you’d want to re-render in the case of presenting a form with errors.

If you need it, you can also configure your own custom view inference by providing your own `Hanami.application.config.actions.view_name_inferrer` object.

To learn more about the implementation, [check out the PR](https://github.com/hanami/controller/pull/322) and then this [follow-up fix](https://github.com/hanami/controller/pull/325) (in which I learnt I should _always_ write integration tests that exercise at least two levels of inheritance).

## Automatically render an action’s view

With the paired view inference above, our action class is now looking like this:

```ruby
class Main
  module Actions
    module Articles
      class Index < Main::Action
        def handle(request, response)
          response.render view
        end
      end
    end
  end
end
```

But we can do better. For simple actions like this, we shouldn’t have to write that “please render your own view” boilerplate.

So how about just this?

```ruby
class Main
  module Actions
    module Articles
      class Index < Main::Action
      end
    end
  end
end
```

Now, any call to this action will automatically render its paired view, passing through all request params for the view to handle as required.

And the beauty of this change was that, after all the groundwork laid so far, [it was only a single line of code!](https://github.com/hanami/controller/pull/324)

As Kent Beck [has said](https://twitter.com/kentbeck/status/250733358307500032), “for each desired change, make the change easy (warning: this may be hard), then make the easy change.” The easy change indeed. Moments like these are why I love being a programmer :)

## Integrated, application-aware view context, and some helpers

Let’s keep going! This month I also gave the “automatic application integration” treatment to `Hanami::View::Context`. Now when you inherit from this within your application, it’ll be all set up to accept the request/response details that `Hanami::Action` is already passing through whenever you render a view from within an action.

With these in place, we’re now providing useful methods like `session` and `flash` for use within your view-related classes and templates. If you want to add additional behaviour, you can now access `request` and `response` on your application’s view context class, too.

While I was doing this, I also took the opportunity to hash out some initial steps towards a standard library of view context helpers with an `Hanami::View::ContextHelpers::ContentHelpers` module. If you mix this into your app’s view context class, you’ll also have a convenient `content_for` method that works like you’d expect. Longer term, I’ll look to move this into the hanami-helpers gem and update the existing helpers to work with the new views, including providing a nice way to opt in to whatever specific helpers you want your application to expose.

In the meantime, [check out all this fresh view context goodness here](https://github.com/hanami/view/pull/177).

## Hanami 2.0 application template is up to date

After all of this, I took a moment to update my [Hanami 2 application template](https://github.com/timriley/hanami-2-application-template). If you create an app from this template today, all the features I’ve described above will be in place and ready for you to try. I also enabled rack session middleware in the app, because this is a requirement for the flash and session objects as well as CSRF protection.

## Hanami 2.0 Trello board

Last but not least, as I was finally seeing some clear air ahead, I took a chance to bring our [Hanami 2.0 Trello board](https://trello.com/b/lFifnBti/hanami-20) up to date!

As it currently stands, I have just 7-8 items left before I think we’ll be ready for the long-awaited Hanami 2.0.0.alpha2 release.

Beyond that, I hope the board will help everyone coordinate the remainder of our work in preparing 2.0.0. At very least, I’m already feeling much better knowing we’re a little more _oranized_, with a single, up-to-date place where it’s easy to see what’s next as well as add new items whenever we think of them (I’ve no doubt that plenty more little things will crop up).

## Plans for August

So that was July. What. A. Month.

I tell you, I was _exceedingly_ happy to have finally completed my “get views and actions properly working together for the first time” list, which turns out to have taken the better past of **five months**.

For August, I plan to knock out as many of my remaining 2.0.0.alpha2 tasks. Some of them are pretty minor, but one or two are looming a little larger. We’ll see how many I can get through. One thing I’m accepting more and more is that when open sourcing across nights and weekends, patience is a virtue.

Thanks for sticking with me through this journey so far!

## 🙌🏼 Thanks to my sponsors… could you be the next?

I’ve been working _really_ hard on preparing a truly powerful, flexible Ruby application framework. I’m in this for the long haul, but it’s not easy.

If you’d like to help all of this come to fruition, I’d love for you to [sponsor my open source work](https://github.com/sponsors/timriley).

Thanks especially to [Benjamin Klotz](https://github.com/tak1n) for your continued support.

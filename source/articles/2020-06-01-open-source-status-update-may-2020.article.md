---
title: Open source status update, May 2020
permalink: 2020/06/01/open-source-status-update-may-2020
published_at: 2020-06-01 16:30:00 +1000
---

May was a breakthrough month in terms of the integration of the standalone components into Hanami 2. Let's dig right in.

## Seamless Hanami view integration

[Last month](https://timriley.info/writing/2020/04/30/open-source-status-update-april-2020/) I wrote about my first pass at integrating Hanami view classes with application they exist within. It looked like this:

```ruby
module Main
  # "Base" view class for `main` slice
  class View < Hanami::View[:main]
  end

  module Views
    class Articles
      # Class for a specific view, inheriting from base
      class Index < Main::View
      end
    end
  end
end
```

In this approach, inheriting from `Hanami::View[:main]` would tell the subclass to apply its configuration using details from the `main` slice. It worked fine, but there's still some redundancy there:

```ruby
module Main                         # <- We're clearly in the `main` slice
  class View < Hanami::View[:main]  # <- So why do we have to repeat it here?
  end
end
```

In trying to get this stuff done for the next alpha release, Luca has definitely been encourating a pragmatic approach to getting things in place (“perfect is the enemy of good,” or in this case “shipped”). It’s the right way to go, but even still, this nagged at me, especially given our goal of reducing boilerplate as much as possible.

After a while I realised that the _application itself_ could provide a facility to help us out in this situation. Given a class like `Main::View`, and given that each slice ”owns” a specific namespace, there is enough information in the class name alone to infer which slice it belongs to. So now we have this:

```ruby
Hanami.application.component_provider(Main::View)
#=> #<Hanami::Slice:0x00007fc2ae074568
# @application=Soundeck::Application,
# @booted=true,
# @container=Main::Container,
# @name=:main,
# @namespace=Main,
# @namespace_path="main",
# @root=#<Pathname:/Users/tim/Source/hanami/soundeck/slices/main>>
```

Pass in a class or instance, and get its slice. Easy. With this in place, we can use it from the `.inherited` hook of `Hanami::View` to get all the information we need for truly seamless integration:

```ruby
module Main
  class View < Hanami::View
  end
end
```

_Look, zero boilerplate!_

But this is only half of the seamless view integration story: now that we can infer the slice that provides a given view, how do we add the slice-specific behaviour, especially given we're still inheriting directly from `Hanami::View`, which still needs to be able to provide the behaviour for _standalone_ (non-integrated) views?

Our original approach for this was also pragmatic: when we need a subclass of a given Hanami component (like `Hanami::View` or `Hanami::Action`) to behave differently within an Hanami application versus when used standalone, we would just monkey patch the application-specific behaviour. Now, anyone who knows me would know this isn't approach I would not tolerate for long. 😉 Even still, I was willing to do it for the sake of expedience. You can see the approach (and all my misgivings about it) in `lib/hanami/action/extensions/application_action.rb` [in my proof of concept action integration PR](https://github.com/hanami/hanami/pull/1049/files).

But as is the theme of this section, it nagged at me. What we really needed here was for the patched methods providing the integration specialisations to be able to call `super` to get to the standalone behaviour wherever they needed. With a monkey patch, this isn't possible because you end up completely replacing the methods (or having to resort to hacky “alias method chain”-style approaches).

One way to solve this would be to have a deeper inheritance chain (`Hanami::ApplicationView < Hanami::View`) and using different superclasses for integrating views versus standalone views, but that bifurcates view usage in an unfriendly way, and more likely than not would make one of those two use cases more awkward than the other.

At this point I realised Ruby gives us another option for this: modules! What we needed here were two different modules in the ancestor chain for a given view class, with the “nearest” one providing the application integration behaviour (e.g. `[Main::Views::Articles::Index, Main::View, ApplicationView, StandaloneView]`), and the next one back providing the standard standalone behaviour. This way, the application integration module can add only the specialisations it requires, and can call `super` whenever it needs.

The final piece to this puzzle is to make it so that the `ApplicationView` module can provide behaviour that’s _specific_ to a given slice. This is where the [module builder pattern](https://dejimata.com/2017/5/20/the-ruby-module-builder-pattern) comes in. Instead of this `ApplicationView` module being a plain old static module, we can _initialize_ it with the slice object that we get when we're subclassing `Hanami::View` in the first place.

So with this in place, here’s what `Hanami::View` and its `.inherited` roughly look like:

```ruby
require_relative "view/application_view"
require_relative "view/standalone_view"
# ...

module Hanami
  class View
    include StandaloneView

    # ...

    def self.inherited(subclass)
      super

      # If inheriting directly from Hanami::View within an Hanami app, configure
      # the view for the application
      if subclass.superclass == View && (provider = application_provider(subclass))
        subclass.include ApplicationView.new(provider)
      end
    end

    def self.application_provider(subclass)
      if Hanami.respond_to?(:application?) && Hanami.application?
        Hanami.application.component_provider(subclass)
      end
    end
    private_class_method :application_provider
  end
end
```

And the resulting ancestors for an actual view class:

```ruby
Main::Views::Articles::Index.ancestors
# => [
#   Main::Views::Home::Index,
#   Main::View,
#   #<Hanami::View::ApplicationView[main]>,
#   Hanami::View,
#   Hanami::View::StandaloneView::InstanceMethods,
#   Hanami::View::StandaloneView,
#   # ...
# ]
```

These are exactly the number of different places we need to neatly slot in all the behaviour for our truly seamless view integration!

The resulting arrangement has some other nice benefits, too, because the integration logic has now moved out from the hanami gem and over into the hanami-view gem itself:

* It makes hanami-view easier to maintain, because the the standalone and integration view behaviours can be seen side by side and kept in sync.
* It also represents some first steps towards ensuring there isn’t just a single “blessed” view system, by making it clear that components should integrate _themselves_ with the application framework, rather than the other way around.

I was chuffed with how this all worked out, and I'm much, much happier with the overall arrangement now. Hats off to Ruby for being such a flexible language! [Check out the full hanai-view PR for this new integration approach](https://github.com/hanami/view/pull/173), as well as [the corresponding integration hooks (and reduction in view integration code!) inside the hanami gem](https://github.com/hanami/hanami/pull/1052).

## New `Hanami.application?` check

A small subtle thing you might have noticed above was that check for `Hanami.application?`. This is [another hook I added](https://github.com/hanami/hanami/pull/1052) to make it easier for components to integrate (or not) with an Hanami application. Because many of the Hanami components can be used on their own (hanami-view, hanami-router, and hanami-controller in particular), the `Hanami` namespace will definitely exist, but not necessarily a full `Hanami.application`. This `Hanami.application?` check provides a safe way to determine if an application has been defined before activating any integration code.

Right now this is defined directly on the `Hanami` module by the hanami gem, but we’ll also be adding it to hanami-utils so you can safely use it without having to require the full application gem.

## Seamless view rendering within Hanami actions

All the polishing of the view integration was a warm-up for the main game this month: properly implementing the integration of view rendering into Hanami actions.

This was the approach we agreed upon after [our experiments last month](https://timriley.info/writing/2020/04/30/open-source-status-update-april-2020/):

```ruby
class Index < Main::Action
  include Deps[view: "views.articles.index"]

  def handle(req, res)
    # Views are rendered by the response
    res.render view
  end
end
```

And as of a few days ago, [the work is complete!](https://github.com/hanami/controller/pull/314)

That single `res.render view` belies _a lot_ of underlying logic. What we do with this integration is provide the view with all the request-specific data that it might need to render itself, things like the current session, flash messages, CSRF token, etc. This is all set up automatically for you as soon as you inherit from `Hanami::Action` within an existing Hanami application.

Sound familiar? That’s because we follow the exact same integration approach for actions as we do for views. Hanami::Action now has a `StandaloneAction` module providing the basic functionality, and an `ApplicationAction` module that is initialized with the action’s slice, so it can pick up whatever details it needs from the slice or application to provide the view rendering integration.

The crux of the integration is the action setting up a [view context object](https://dry-rb.org/gems/dry-view/0.7/context/) with the request/response pair created when the action is called. This view context is automatically [passed to the view](https://dry-rb.org/gems/dry-view/0.7/context/#providing-the-context) when `res.render` is called. Having the request/response pair available to the context means that the context object can provide methods to make those details like the `flash` available for use within the view [templates](https://dry-rb.org/gems/dry-view/0.7/templates/#template-scope), [scopes](https://dry-rb.org/gems/dry-view/0.7/scopes/#accessing-the-context), and [parts](https://dry-rb.org/gems/dry-view/0.7/parts/#accessing-the-context) (these are links to dry-view documentation, since at this point, hanami-view unstable and dry-view 0.7 are effectively the same).

This integration is eminently flexible. There are multiple points at which an application author can customise it. The first would be to add their own methods to the view context class within their application (I’ll show examples of this this next month). The next would be to override any of these methods within their base action class:

- `#view_options`, to pass additional options to every view as it is rendered
- `#view_context_options`, to pass additional options to the view context
- `#build_response`, to customize the response object that is prepared for passing to the action’s `#handle` method (it’s unlikely this will need to be customised, but it’s nice to keep all options open)

I think these methods are a perfect example of the approach we’re taking with Hanami 2 development: conveniences by default, but _every possible measure_ available to adjust things when you need to diverge from the defaults.

## Next steps for actions and views

This month was all about laying the proper groundwork for action and view integration. With this done, my plan for June is to roll through all these steps to round it out:

- Making `Hanami::Action` configuration class-based, like we have for view configuration, so we can auto-configure actions based on their slice
- Making actions automatically infer a paired view (think a "views.article.index" view for an `Actions::Articles::Index`) so you don’t need to explicitly auto-inject them
- Then going a step further, making it so that actions automatically _render_ their paired view too, meaning you don’t not even need to implement `#handle` for basic render-only actions
- Creating an `Hanami::View::ApplicationContext` context class with a default set of helpful methods for use within all Hanami views, including those that require access to the request (as described above)
- Making the view context container identifier configurable

With Hanami 2, while we’re building upon many years worth of open source efforts in terms of the existing libraries we’re pulling together, it’s become very clear to me through this process that doing good integration work is just as much effort all over again. Thanks for your patience while we work through this as best we can.

## Thanks to my sponsors 🙌🏼

Earlier this month I announced that [I joined GitHub sponsors](https://timriley.info/writing/2020/05/21/sponsor-me-on-github/), and since then, two more kind people [began sponsoring me](https://github.com/sponsors/timriley). Thank you so much [Samuel Williams](https://github.com/ioquatix) and [Thomas Klemm](https://github.com/thomasklemm)!

And a big shout out to [Benjamin Klotz](https://github.com/tak1n) for your continuing support 😄

## Thanks for reading!

This post turned out to be a big one! The fact that I had so much to say speaks to just how pivotal a month this was. I’m looking forward to the next few weeks of rolling downhill from here and collecting a bunch of quick wins. See you all again at the end of June! 👋🏼

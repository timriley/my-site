---
title: Open source status update, October 2020
permalink: 2020/11/03/open-source-status-update-october-2020
published_at: 2020-11-03 22:30:00 +1100
---

October was the month! I finally got through the remaining tasks standing between me and an Hanami 2.0.0.alpha2 release. Let’s work through the list now!

## Application views configured with application inflector

Now when you subclass `Hanami::View` inside an Hanami app, it will now use the application’s configured inflector automatically. This is important because hanami-view uses the inflector to determine the class names for your [view parts](https://dry-rb.org/gems/dry-view/0.7/parts/#part-class-resolution), and it’s just plain table stakes for an framework to apply inflections consistently (especially if you’ve configured custom inflection rules).

The [implementation within hanami-view](https://github.com/hanami/view/pull/180) was quite interesting, because it was the first time I had to adjust an `ApplicationConfiguration` (this one being exposed as `config.views` on the `Hanami::Application` subclass) to _hide_ one of its base settings. In this case, it hides the `inflector` setting because we know it will be configured with the application’s inflector as part of the `ApplicationView` behaviour (to refresh your memory, `ApplicationView` is a module that’s mixed in whenever `Hanami::View` is subclassed within a namespace managed by a full Hanami application).

Ordinarily, I’m all in favour of exposing as many settings as possible, but in this case, it didn’t make sense for a view-specific inflector to be independently configurable right alongside the application inflector itself.

Rest assured, you don’t lose access to this setting entirely, so if you ever have reason to give your views a different inflector, you can go right ahead and directly assign it in a view class:

```ruby
module Main
  class View < Hanami::View
    # By default, the application inflector is configured

    # But you can also override it:
    config.inflector = MyCustomInflector
  end
end
```

There was a [counterpart hanami PR for this change](https://github.com/hanami/hanami/pull/1081), and I was quite happy to see it all done, because it means we now have consistent handling of both action and view settings: each gem provides their own `ApplicationConfiguration` class, which is made accessible via `config.actions` and `config.views` respectively. This consistency should  make it easier to maintain both of these imported configurations going forward (and, one day, to devise a system for any third party gem to register application-level settings).

## Application views have their template configured always

One aspect of the `ApplicationView` behaviour is to automatically configure a template name on each view class. For example, a `Main::Views::Articles::Index` would have its template configured as `"articles/index"`.

This is great, but there was an missing piece from the implementation. It assumed that your view hierarchy would always include an abstract base class defined within the application:

```ruby
module Main
  # Abstract base view
  class View < Hanami::View
  end

  module Views
    module Articles
      # Concrete view
      class Index < View
      end
    end
  end
end
```

Under this assumption, the base view would never have its template automatically configured. That makes sense in the above arrangement, but if you ever wanted to directly inherit from `Hanami::View` for a single concrete view (and I can imagine cases where this would make sense), you’d lose the nice template name inference!

[With this PR](https://github.com/hanami/view/pull/181), this limitation is no more: every `ApplicationView` has a template configured in all circumstances.

## Application views are configured with a Part namespace

Keeping with the theme of improving hanami-view integration, another gap I’d noticed was that application views are not automatically configured with a [part namespace](https://dry-rb.org/gems/dry-view/0.7/parts/#defining-a-part-class). This meant another wart if you wanted to use this feature:

```ruby
require "main/views/parts"

module Main
  class View < Hanami::View
    # Ugh, I have to _type_ all of this out, _by hand?_
    config.part_namespace = Views::Parts
  end
end
```

Not any more! [As of this PR](https://github.com/hanami/view/pull/182), we now have a `config.views.parts_path` application-level setting, with a default value of `"views/parts"`. When an `ApplicationView` is activated, it will take this value, convert it into a module (relative to the view’s application or slice namespace), and assign it as the view’s `part_namespace`. This would see any view defined in `Main` having `Main::Views::Parts` automatically set as its part namespace. Slick!

## Security-related default headers restored

Sticking with configuration, but moving over to hanami-controller, `Hanami::Action` subclasses within an Hanami app (that is, any `ApplicationAction`) now have [these security-related headers configured out of the box](https://github.com/hanami/controller/pull/336):

- `X-Frame-Options: DENY`
- `X-Content-Type-Options: nosniff`
- `X-XSS-Protection: 1; mode=block`
- `Content-Security-Policy:` _[it’s long, just go check the code](https://github.com/hanami/controller/pull/336/files#diff-fcfb514bd1756b038ab734a8223067a66d87794d98fb70c877376b95286b843b)_

These are set on the `config.actions.default_headers` application-level setting, which you can also tweak to suit your requirements.

Previously, these were part of a bespoke one-setting-per-header arrangement in the `config.security` application-level setting namespace, but I think this new arrangement is both easier to understand and much more maintainable, so I was happy to [drop that whole class from hanami](https://github.com/hanami/hanami/pull/1085) as part of rounding this out this work.

## Automatic cookie support based on configuration

The last change I made to hanami-controller was to move the `config.cookies` application-level setting, which was defined in the hanami gem, directly into the `config.actions` namespace, which is defined inside hamami-controller, much closer to the related behaviour.

We now also automatically include the `Hanami::Action::Cookies` module into any `ApplicationAction` if cookies are enabled. This removes yet another implmentation detail and piece of boilerplace that users would otherwise need to consider when building their actions. I’m really happy with how the `ApplicationAction` idea is enabling this kind of integration in such a clean way.

Check out the finer details in [the PR to hanami-controller](https://github.com/hanami/controller/pull/337) and witness the [corresponding code removal](https://github.com/hanami/hanami/pull/1086) from hanami itself.

## Released a minimal application template

It’s been a while now since I released my original [Hanami 2 application template](https://github.com/timriley/hanami-2-application-template), which still serves as a helpful base for traditional all-in-one web applications.

But this isn’t the only good use for Hanami 2! I think it can serve as a helpful base for _any_ kind of application. When I had a colleague ask me on the viability of Hanami to manage a long-running system service, I wanted to demonstrate how it could look, so I’ve now released an [Hanami 2 _minimal_ application template](https://github.com/timriley/hanami-2-minimal-application-template). This one is fully stripped back: nothing webby at all, just a good old `lib/` and a `bin/app` to demonstrate an entry point. I think it really underscores the kind of versatility I want to achieve with Hanami 2. Go check it out!

## Gave dry-types a nice require-time performance boost

Last but not least, one evening I was investigating just how many files were required as one of my applications booted. I noticed an unusually high number of concurrent-ruby files being required. Turns out this was an unintended consequence of requiring dry-types. [One single-line PR later](https://github.com/dry-rb/dry-types/pull/406) and now a `require "dry/types"` will load 242 fewer files!

## Savouring this moment

It’s taken quite some doing to get to this moment, where an Hanami 2.0.0.alpha2 release finally feels feasible. As you’d detect from my previous posts, it’s felt tantalisingly close for every one of the last few months. As you’d also detect from _this_ post, the final stretch has involed a lot of focused, fiddly, and let’s face it, not all that exciting work. But these are just the kind of details we need to get right for an excellent framework experience, and I’m glad I could continue for long enough to get these done.

I’m keenly aware that there’ll be much, much more of this kind of work ahead of us, but for the time being, I’m savouring this interstice.

In fact, I’ve even given myself a treat: I’ve already started some early explorations of how we could adapt dry-system to fit with [zeitwerk](http://github.com/fxn/zeitwerk) so that we can reliable autoloading a part of the core Hanami 2 experience. But more on that later ;)

## Thank you to my sponsors!

I now have a [sponsors page](/sponsors) on this here site, which contains a small list of people to whom I am very thankful. I’d really love for you to join their numbers and [sustain my open source work](https://github.com/sponsors/timriley).

As for the next month, new horizons await: I’ll start working out some alpha2 release notes (can you believe it’s been nearly 2 years of work?), as well as continuing on the zeitwerk experiment.

See you all again, same place, same time!

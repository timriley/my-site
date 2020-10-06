---
title: Open source status update, September 2020
permalink: 2020/10/06/open-source-status-update-september-2020
published_at: 2020-10-06 22:32:00 +1100
---

Well, didn’t September just fly by? [Last month](https://timriley.info/writing/2020/08/31/open-source-status-update-august-2020/) I predicted I’d get through the remaining tasks standing in the way of an Hanami 2.0.0.alpha2 release, and while I made some inroads, I didn’t quite get there. At this point I’ve realised that after many consecutive months of really strong productivity on OSS work (which for me right now is done entirely on nights and weekends), a downtick of a couple of months was inevitable.

Anyway, let’s take a look at what I did manage to achieve!

## Reintroduced CSRF protection module to hanami-controller

Sometime during the upheaval that was hanami and hanami-controller’s initial rewrite for 2.0.0, we lost the important `CSRFProtection` module. I’ve [brought it back now](https://github.com/hanami/controller/pull/327), this time locating it within hanami-controller instead of hanami, so it can live alongside the action classes that are meant to include it.

For now, you can manually include it in your action classes:

```ruby
require "hanami/action"
require "hanami/action/csrf_protection"

class MyAction < Hanami::Action
  include Hanami::Action::CSRFProtection
end
```

And if you need to manually opt out of the protections for any reason, you can implement this method in any one of your action classes:

```ruby
def verify_csrf_token?(req, res)
  false
end
```

Either way, I encourage you to [check out the code](https://github.com/hanami/controller/pull/327/files); it’s a simple module and very readable.

## Started on automatic enabling of CSRF protection

For a _batteries included_ experience, having to manually include the `CSRFProtection` module isn’t ideal. So I’m currently working to make it so the module is automatically included when the Hanami application has sessions enabled. This is close to being done already, in this [hanami-controller PR](https://github.com/hanami/controller/pull/332) and this [counterpart hanami PR](https://github.com/hanami/hanami/pull/1078). I’m also taking this an an opportunity to move all session-related config away from hanami and into hanami-controller, which I think is a more rational location both in terms of end-user understandability and future maintainability.

We’ll see this one fully wrapped up in next month’s update :)

## Improving preservation of state in dry/hanami-view context objects

This one was a doozy. It started with my [fixing a bug in my site](https://github.com/timriley/my-site/commit/fa72585bd73288c1824be1e2f35ac2025eeb42fb) to do with missing page titles, and then realising that it only partially fixed the problem. I wasn’t doing anything particularly strange in my site, just following a pattern of setting page-specific titles in individual templates:

```
- page_title "Writing"

h1 Writing
  / ... rest of page
```

And then rendering the title within the layout:

```
html
  head
    title = page_title
```

Both of these `page_title` invocations called a single method on my view [context object](https://dry-rb.org/gems/dry-view/0.7/context/):

```ruby
def page_title(new_title = Undefined)
  if new_title == Undefined
    [@page_title, settings.site_title].compact.join(" | ")
  else
    @page_title = new_title
  end
end
```

Pretty straightforward, right? However, because the context is reinitialized from a base object for each different rendering environment (first the template, and then the layout), that `@page_title` we set in the template never goes anywhere else, so it’s not available afterwards in the layout.

This baffled me for a quite a while, because I’ve written similar `content_for`-style helpers in context classes and they’ve always worked without a hitch. Well, it turns out I got kinda lucky in those cases, because I was using a _hash_ (instead of a direct instance variable) to hold the provided pieces of content, and since hashes (like most objects in Ruby) are passed by reference, that just so happened to permit the same bits of content to be seen from all view context instances.

Once I made this relisation, I first [committed this egregious hack](https://github.com/timriley/my-site/commit/f9d029178dfeecd36586a7672ab17f1413f1145b) just to get my site properly showing titles again, and then I mulled over a couple of options for properly fixing this inside hanami-view.

One option would be to acknowledge this particular use case and adjust the underlying gem to support it, ensuring that [the template context is used to initialize the layout context](https://github.com/hanami/view/pull/178). This works, and it’s certainly the smallest possible fix, but I think it papers over the fundamental issue here: the the creation of multiple context instances is a low-level implementation detail and should not be something the user needs to think about. I think a user _should_ feel free to set an ivar in a context instance and reasonably expect that it’ll be available at all points of the rendering cycle.

So how do we fix this? The obvious way would be to ensure we create only a single context object, and have it work as required for rendering the both the template and the layout. The challenge here is that we require a different [`RenderEnvironment`](https://github.com/hanami/view/blob/c4fb06a6b419cc83f2bb7f8b3027b07f03d3f199/lib/hanami/view/render_environment.rb) for each of those, so the correct partials can be looked up, whether they’re called from within templates, or within part or scope classes. This is why we took the approach of creating those multiple context objects in the first place, so each one could have an appropriate `RenderEnvironment` provided.

So how do we keep a single context instance but somehow swap around the underlying environment? Well, as a matter of fact, _there’s a gem for that._ After discovering this bug, I was inspired and stayed up to midnight [spiking on an approach](https://github.com/hanami/view/pull/179) that relies upon [dry-effects](https://dry-rb.org/gems/dry-effects/) and a [reader effect](https://dry-rb.org/gems/dry-effects/0.1/effects/reader/) to provide the differing `render_environment` to a single context object.

(The other _effect_ I felt was the extreme tiredness the next day, I’m not the spritely youth I used to be!)

Anyway, if you haven’t checked out dry-effects, I encourage you to do so: it may help you to discover some novel approaches to certain design challenges. In this case, all we need to do is include the effect module in our context class:

```ruby
module Hanami
  class View
    class Context
      # Instance methods can now expect a `render_env` to be available
      include Dry::Effects.Reader(:render_env)
    end
  end
end
```

And ensure we’re wrapping a handler around any code expected to throw the effect:

```ruby
module Hanami
  class View
    module StandaloneView
      # This provides `with_render_env`, used below
      include Dry::Effects::Handler.Reader(:render_env)

      def call(format: config.default_format, context: config.default_context, **input)
        # ...

        render_env = self.class.render_env(format: format, context: context)
        template_env = render_env.chdir(config.template)

        # Anything including Dry::Effects.Reader(:render_env) will have access to the
        # provided `template_env` inside this handler block
        output = with_render_env(template_env) {
          render_env.template(config.template, template_env.scope(config.scope, locals))
        }

        # ...
      end
    end
  end
end
```

With this in place, we have a design that allows us to use a single context object only for entirety of the render lifecycle. For the simplicity to the user, I think this is a very worthwhile change, and I plan to spend time assessing it in detail this coming month. As Nikita (the author of dry-effects) points out, there’s a performance aspect to consider: although we’re saving ourselves some object allocations here, we now have to dispatch to the handler every time we throw the reader effect for the `render_env`. Still, it feels like a very promising direction.

## Filed issues arising from production Hanami 2 applications

Over the month at work, we put the finishing touches on two brand new services built with Hanami 2. This helped us to identify a bunch of rough edges that will need addressing before we’re done with the release. I filed them on our public Trello board:

- [Need ability to insert middleware before framework-provided ones, e.g. rack_logger](https://trello.com/c/rF8HgBxP)
- [Add all slice lib/ dirs to LOAD_PATH as early as possible](https://trello.com/c/XoduxZxZ)
- [Allow application author to configure application container
Make a Types module automatically available (if possible) inside the Hanami.application.settings block](https://trello.com/c/qExli5cy)
- [(dry-system) How can we `use :foo` from inside a slice-specific bootable file, when `:foo` is an application-level bootable?](https://trello.com/c/JQG7oocI)
- [Properly support conditional loading of slices](https://trello.com/c/HDuJeazH)
- [Body parsing should be built into hanami-controller, not be (solely) a standalone middleware](https://trello.com/c/dh4Wtjea)
- [`accept :json` should be forgiving on requests that have no request bodies (or offer more expansive behavior, encompassing all request methods)](https://trello.com/c/KujFWMWw)
- [Action enforce_accepted_mime_types callback should return 415 status code upon failure, not 406](https://trello.com/c/oPeUNfC5)

This goes to show how critical it is for frameworks like Hanami to have real-world testing, even at these very early stages of new release development. I’m glad I can also serve in this role, and grateful for keenness and patience of our teams in working with cutting edge software!

## Fixed accidental memoization of dry-configurable setting values

Last but not least, I [fixed this bug in dry-configurable](https://github.com/dry-rb/dry-configurable/pull/99) that arose from an earlier change I made to have it [evaluate settings immediately](https://github.com/dry-rb/dry-configurable/pull/95) if a value was provided.

This was a wonderful little bug to fix, and the perfect encapsulation of why I love programming: we started off with two potentially conflicting use cases, represented as two different test cases (one failing), and had to find a way to satisfy them both while still upholding the integrity of the gem’s overall design. I’m really happy with how this one turned out.

## 🙌🏼 Thanks to my sponsors!

This month I was honoured to have a new sponsor come on board. Thank you [Sven Schwyn](https://github.com/svoop) for your support! If you’d like to give a boost to my open source work, [please consider sponsoring me on GitHub](https://github.com/sponsors/timriley).

See you all next month!

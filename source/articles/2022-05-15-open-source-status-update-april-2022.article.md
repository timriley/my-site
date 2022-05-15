---
title: Open source status update, April 2022
permalink: 2022/05/15/open-source-status-update-april-2022
published_at: 2022-05-15 22:20 +1000
---

April was a pretty decent month for my OSS work! Got some things wrapped up, kept a few things moving, and opened up a promising thing for investigation. What are these things, you say? Let’s take a look!

## Finished centralisation of Hanami action and view integrations

I [wrote about the need](/writing/2022/04/10/open-source-status-update-march-2022/) to centralise these integrations last month, and in April, I [finally got the work done!](https://github.com/hanami/hanami/pull/1156)

This was a relief to get out. As a task, while necessary, it felt like drudge work – I’d been on it since early March, after all! I was also conscious that this was also blocking Luca’s work on helpers all the while.

My prolonged work on this (in part, among other things like Easter holidays and other such Real Life matters) contributed to us missing April’s Hanami release. The good thing is that it’s done now, and I’m hopeful we can have this released via another Hanami alpha sometime very soon.

In terms of the change to Hanami apps, the biggest change from this is that your apps should use a new superclass for actions and views:

```ruby
require "hanami/application/action"

module Main
  module Action
    class Base < Hanami::Application::Action # Used to be just Hanami::Action
    end
  end
end
```

Aside from the benefit to us as maintainers of having this integration code kept together, this distinct superclass should also help make it clearer where to look when learning about how actions and views work within full Hanami apps.

## Enabled proper access to full `locals` in view templates

I wound up doing a little more work in actions and views this month. The first was a quickie to unblock some more of Luca’s helpers work: making access to the `locals` hash within templates [work like we always expected it would](https://github.com/hanami/view/pull/208).

This turned out to be a fun one. For a bit of background, the context for every template rendering in hanami-view (i.e. what `self` is for any given template) is an `Hanami::View::Scope` instance. This instance contains the template’s locals, makes the full locals hash available as `#locals` (and `#_locals`, for various reasons), and uses `#method_missing` to make also make each local directly available via its own name.

Luca found, however, that calling `locals` within the template didn’t work at all! After I took a look, it seemed that while `locals` didn’t work, `self.locals` or just plain `_locals` _would_ work. Strange!

Turns out, this all came down to implementation details in [Tilt](https://github.com/rtomayko/tilt), which we use as our low-level template renderer. The way Tilt works is that it will compile a template down into [a single Ruby method](https://github.com/rtomayko/tilt/blob/9b02c6f27e720abb0ec3e95856c6c14df24c9b15/lib/tilt/template.rb#L272-L276) that receives a `locals` param:

```ruby
def compile_template_method(local_keys, scope_class=nil)
  source, offset = precompiled(local_keys)
  local_code = local_extraction(local_keys)

  # <...snip...>

  method_source << <<-RUBY
    TOPOBJECT.class_eval do
      def #{method_name}(locals)
        #{local_code}
  RUBY
```

Because of this, `locals` is actually a _local variable_ in the context of that method execution, which will override any other methods also available on the scope object that Tilt turns into `self` for the rendering.

Here is how we were originally rendering with Tilt:

```ruby
tilt(path).render(scope, &block)
```

My first instinct was simply to pass our locals hash as the (optional) second argument to Tilt’s `#render`:

```ruby
tilt(path).render(scope, scope._locals)
```

But even that didn’t work! Because in generating that `local_code` above, Tilt will actually take the `locals` and [explode it out into individual variable assignments](https://github.com/rtomayko/tilt/blob/9b02c6f27e720abb0ec3e95856c6c14df24c9b15/lib/tilt/template.rb#L251-L259):

```ruby
def local_extraction(local_keys)
  local_keys.map do |k|
    if k.to_s =~ /\A[a-z_][a-zA-Z_0-9]*\z/
      "#{k} = locals[#{k.inspect}]"
    else
      raise "invalid locals key: #{k.inspect} (keys must be variable names)"
    end
  end.join("\n")
end
```

But we don’t need this at all, since hanami-view’s scope object is already making those locals available individually, and we want to ensure access to those locals continues to run through the scope object.

So the ultimate fix is to make locals of our locals. Yo dawg:

```ruby
tilt(path).render(scope, {locals: scope._locals}, &block)
```

This gives us our desired access to the `locals` hash in templates (because that `locals` key is itself turned into a solitary local variable), while preserving the rest of our existing scope-based functionality.

It also shows me that I probably should’ve written an integration test back when I [introduced access to a scope’s locals back in January 2019](https://github.com/dry-rb/dry-view/commit/c1bf77e14cb4dac3cc10a5b7e2abd276334024ea). 😬

Either way, I’m excited this came up and I could fix it, because it’s an encouraging sign of just how much of this view system we’ll be able to put to use in creating a streamlined and powerful view layer for our future Hanami users!

## Merged a fix to stop unwanted view rendering of halted requests

Thanks to our extensive use of Hanami at Culture Amp, my friend and colleague Andrew [discovered and fixed a bug](https://github.com/hanami/controller/pull/372) with our automatic rendering of views within actions, which I was happy to merge in.

## Shipped some long awaited dry-configurable features

After keeping poor [ojab](https://github.com/ojab) waiting way too long, I also merged a couple of nice enhancements he made to dry-configurable:

- [Make `Config#finalize!` finalize itself recurively and (optionally) allow freezing of setting values](https://github.com/dry-rb/dry-configurable/pull/105)
- [Accept hashes as possible setting values when using `#update`](https://github.com/dry-rb/dry-configurable/pull/131), which [I followed up](https://github.com/dry-rb/dry-configurable/pull/133) with support for anything implicitly convertible to a hash.

I then released these as [dry-configurable 0.15.0](https://github.com/dry-rb/dry-configurable/releases/tag/v0.15.0).

## Started work on unifying Hanami slices and actions

Last but definitely not least, I started work on one of the last big efforts we need in place before 2.0: making Hanami slices act as much as possible like complete, miniature Hanami applications. I’m going to talk about this a lot more in future posts, but for now, I can point you to a few PRs:

- [Introducing `Hanami::SliceName`](https://github.com/hanami/hanami/pull/1159) (a preliminary, minor refactoring to fix some slice and application name determination responsibilities that had somehow found their way into our configuration class).
- [A first, abandoned attempt](https://github.com/hanami/hanami/pull/1160) at combining slices and applications, using a mixin for shared behaviour.
- [A much more promising attempt](https://github.com/hanami/hanami/pull/1162) using a composed slice object within the application class, which is currently the base of my further work in this area.

Apart from opening up some really interesting possibilities around making slices fully a portable, mountable abstraction (imagine bringing in slices from gems!), even for our shorter-term needs, this work looks valuable, since I think it should provide a pathway for having application-wide settings kept on the application class, while still allowing per-slice customisation of those settings in whichever slices require them.

The overall slice structure is also something that’s barely changed since I put it in place way back in late 2019. Now it’s going to get the spit and polish it deserves. Hopefully I’ll be able to share more progress on this next month :) See you then!

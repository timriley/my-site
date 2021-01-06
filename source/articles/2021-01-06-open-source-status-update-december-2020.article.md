---
title: Open source status update, December 2020
permalink: 2021/01/06/open-source-status-update-december-2020
published_at: 2021-01-06 22:50:00 +1100
---

Happy new year! Before we get too far through January, here’s the recap of my December in OSS.

## Advent of Code 2020 (in Go!)

This month started off a little differently to usual. After spending some time book-learning about Go, I decided to [try the Advent of Code for the first time](https://github.com/timriley/aoc2020) as a way to build some muscle memory for a new language. And gosh, it was a lot of fun! Turns out I like programming and problem-solving, go figure. After ~11 days straight, however, I decided to put the effort on hold. I could tell the pace wasn't going to be sustainable for me (it was a lot of late nights), and I’d already begun to feel pretty comfortable with various aspects of Go, so that’s where I left it for now.

## Rich dry-system component_dir configuration (and cleanups!)

Returning to my regular Ruby business, December was a good month for dry-system. After [the work in November](/writing/2020/12/07/open-source-status-update-november-2020) to prepare the way for Zeitwerk, I moved onto introducing a new `component_dirs` setting, which permits the addition of any number of component directories (i.e. where dry-system should look for your Ruby class files), each with their own specific configurations:

```ruby
class MyApp::Container < Dry::System::Container
  configure do |config|
    config.root = __dir__

    config.component_dirs.add "lib" do |dir|
      dir.auto_register = true    # defaults to true
      dir.add_to_load_path = true # defaults to true
      dir.default_namespace = "my_app"
    end
  end
end
```

Along with this, I’m removing the following from `Dry::System::Container`:

- The top-level `default_namespace` and `auto_register` settings
- The `.add_to_load_path!` and `.auto_register!` methods

Together, this means there’ll be only a single place to configure the behaviour related to the loading of components from directories: the singular `component_dirs` setting.

This has been a rationalization I’ve been wanting to make for a long time, and happily, it’s proving to be a positive one: as I’ve been working through the changes, it’s allowed me to simplify some of the gnarlier parts of the gem.

What all of this provides is the right set of hooks for Hanami to specify the component directories for your app, as well as configure each one to work nicely with Zeitwerk. That’s the end goal, and I suspect we’ll arrive there in late January or February, but in the meantime, I’ve enjoyed the chance to tidy up the internals of this critical part of the Hanami 2.0 underpinnings.

You can [follow my work in progress over in this PR](https://github.com/dry-rb/dry-system/pull/155).

## Helpers for hanami-view 2.0

Towards the end of the month I had a call with Luca (the second in as many months, what a treat!), in which we discussed how we might bringing about full support for view helpers into hanami-view 2.0.

Of course, these won’t be ”helpers” in quite the same shape you’d expect from Rails or any of the Ruby static site generators, because if you’ve ever heard me talk about dry-view or hanami-view 2.0 ([here’s a refresher](/writing/2020/07/14/philly-rb-talk-on-hanami-view-2-0)), one of its main goals is to help move you from a gross, global soup of unrelated helpers towards view behaviour modelled as focused, testable, well-factored object oriented code.

In this case, we finished the discussion with a plan, and Luca turned it around within a matter of days, with a quickfire set of PRs!

First he introduced the concept of [custom anonymous scopes for any view](https://github.com/hanami/view/pull/183). A [scope](https://dry-rb.org/gems/dry-view/0.7/scopes/) in dry-view/hanami-view parlance is the object that provides the total set of methods available to use within the template. For a while we’ve supported [defining custom scope classes](https://dry-rb.org/gems/dry-view/0.7/scopes/#defining-a-scope-class) to add behavior for a view that doesn’t belong on any one of its particular exposures, but this requires a fair bit of boilerplate, especially if it’s just for a method or two:


```ruby
class ArticleViewScope < Hanami::View::Scope
  def custom_method
    # Custom behavior here, can access all scope facilities, e.g. `locals` or `context`
  end
end

class ArticleView < Hanami::View
  config.scope = ArticleViewScope

  expose :article do |slug:|
    # logic to load article here
  end
end

```

So to make this eaiser, we now we have this new class-level block:

```ruby
class ArticleView < Hanami::View
  expose :article do |slug:|
    # logic to load article here
  end

  # New scope block!
  scope do
    def custom_method
      # Custom behavior here, can access all scope facilities, e.g. `locals` or `context`
    end
  end
end
```

So nice! Also nice? That it was a literal 3-line change to the hanami-view code 😎 Also, also nice? You can still “upgrade” to a fully fledged class if the code ever requires it.

Along with this, Luca also began [adapting the existing range of global helpers](https://github.com/hanami/helpers/pull/166) for use in hanami-view 2.0. I may dislike the idea of helpers in general, but truly stateless things like html builders, etc. I’m generally happy to see around, and with the improvements to template rendering we have over hanami-view 1.x, we’ll be able to make these a lot more expressive for Hanami view developers. This PR is just the first step, but I expect we’ll be able to make some quick strides once this is in place.

## Thank you to my sponsors! 🙌🏼

Thank you to my six GitHub sponsorts for your continuing support! If you’re reading this and would like to chip in and help push forward the Ruby web application ecosystem for 2021, [I’d really appreciate your support](https://github.com/sponsors/timriley).

See you all next month!

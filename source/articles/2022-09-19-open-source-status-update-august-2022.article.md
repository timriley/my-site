---
title: Open source status update, August 2022
permalink: 2022/09/18/open-source-status-update-august-2022
published_at: 2022-09-18 07:30 +1000
---

August’s OSS work landed one of the last big Hanami features, saw another Hanami release out the door, began some thinking about memory usage, and kicked off a fun little personal initiative. Let’s dive in!

## Conditional slice loading in Hanami

At the beginning of the month I [merged support for conditional slice loading in Hanami](https://github.com/hanami/hanami/pull/1189). I’d wanted this feature for a long time, and in fact I’d hacked in workarounds to achieve the same more than 2 years ago, so I was very pleased to finally get this done, and for the implementation work to be as smooth as it was.

The feature provides a new `config.slices` setting on your app class, which you can configure like so:

```ruby
module MyApp
  class App < Hanami::App
    config.slices = %w[admin]
  end
end
```

For an app consisting of both `Admin` and `Main` slices and for the config above, when the app is booted, only the `Admin` slice will be loaded:

```ruby
require "hanami/prepare"

Hanami.app.slices.keys # => [:admin]

Admin::Slice # exists, as expected
Main         # raises NameError, since it was never loaded
```

As we see from `Main` above, slices absent from this list will not have their namespace defined, nor their slice class loaded, nor any of their Ruby source files. Within that Ruby process, they effectively do not exist.

Specifying slices to load can be very helpful to improve boot time and minimize memory usage for specific deployed workloads of your app.

Imagine you have a subset of background jobs that run via a dedicated job runner, but whose logic is otherwise unneeded for the rest of your app to function. In this case, you could organize those jobs into their own slice, and then load only that slice for the job runner’s process. This arrangement would see the job runner boot as quickly as possible (no extraneous code to load) as well as save all the memory otherwise needed by all those classes. You could also do the invserse for your main deployed process: specify all slices _except_ this jobs slice, and you gain savings there too.

Organising code into slices to promote operational efficiency like this also gives you the benefit of greater clarity in the separation of responsibilities between those slices: when a single slice of code is loaded and the rest of your app is made to disappear, that will quickly surface any insidious dependencies from that slice to the rest of your code (they’ll be raised as exceptions!). Cleaning these up will help ensure your slices remain useful as abstractions for reasoning about and maintaining your app.

To make it easy to tune the list of slices to load, I also introduced a new `HANAMI_SLICES` env var that sets this config without you having to write code inside your app class. In this way, you could use them in your `Procfile` or other similar deployment code:

```
web: HANAMI_SLICES=main,admin bundle exec puma -C config/puma.rb
feed_worker: HANAMI_SLICES=feed bundle exec rake jobs:work
```

This effort was also another example of why I’m so happy to be working alongside the Hanami core team. After initially proposing a more complex arrangement including separate lists for including or excluding slices, [Luca jumped in](https://github.com/hanami/hanami/pull/1189#pullrequestreview-1063372221) and help me dial this back to the much simpler arrangement of the single list only. For an Hanami release in which we’re going to be introducing so many new ideas, the more we can keep simple around them, the better, and I’m glad to have people who can remind me of this.

## Fixed how slice config is applied to component classes

Our action and view integration code relies on their classes detecting when they’re defined inside a slice’s namespace, then applying relevant config from the slice to their own class-level config object. It turned out our code for doing this broke a little when we adjusted our default class hierarchies. Thanks to some of our wonderful early adopters, we picked this up quickly and [I fixed it](https://github.com/hanami/hanami/pull/1193). Now things just work like you expect however you choose to configure your action classes, whether through the app-level `config.actions` object, or by directly updating `config` in a base action class.

In doing this work, I became convinced we need an API on dry-configurable to determine whether any config value has been assigned or mutated by the user, since it would help so much in reliably detecting whether or not we should ignore config values at particular levels. For now, we could work around it, but I hope to bring this to dry-configurable at some point in the future.

## Released Hanami 2.0.0.beta2

Another month passed, so it was time for another release! With my European colleagues mostly enjoying some breaks over their summer, I hunkered down in chilly Canberra and [took care of the 2.0.0.beta2 release](https://hanamirb.org/blog/2022/08/16/announcing-hanami-200beta2/). Along with the improvements above, this release also included slice and action generators (`hanami generate slice` and `hanami generate action`, thank you Luca!), plus a very handle CLI middlewares inspector ([thank you Marc!](https://github.com/hanami/cli/pull/30)):

```shell
$ hanami middlewares

/    Dry::Monitor::Rack::Middleware (instance)
/    Rack::Session::Cookie
```

The list of things to do over the beta phase is getting smaller. I don’t expect we’ll need too many more of these releases!

## Created memory usage benchmarks for dry-configurable

As the final 2.0 release gets closer, we’ve been doing various performance tests just to make sure the house is in order. One thing we discovered is that `Hanami::Action` is not as memory efficient as we’d like it to be. One of the biggest opportunities to improve this looked to be in dry-configurable, since that’s what is used to manage the per-class action configuration.

I suspected any effort here would turn out to be involved (and no surprise, it turned out to be involved 😆), so I thought it would be useful as a first step to [establish a memory benchmark](https://github.com/dry-rb/dry-configurable/pull/137) to revisit over the course of any work. This was also a great way to get my head in this space, which turned out to take over most of my September (but more on that next month).

## Quietly relaunched Decaf Sucks

Decaf Sucks was once a thriving little independent online café review community, with its own web site (starting from humble beginnings as a [Rails Rumble entry in 2009](/writing/2009/09/02/decaf-sucks-and-a-rails-rumble-redux/)) and even native iOS app ([two iterations](https://www.icelab.com.au/notes/decaf-sucks-launch-countdown-development-complete), [in fact](https://www.icelab.com.au/notes/announcing-decaf-sucks-20)).

I was immensitely proud of what Decaf Sucks became, and for the collaboration with [Max Wheeler](https://www.makenosound.com) in building it.

Unfortunately, as various internet APIs changed, the site atrophied, eventually became disfunctional, and we had to take it down. I still have the database, however, and I want to bring it back!

This time around, my plan is to do it as a fully open source Hanami 2 example application. Max is even on board to bring back all the UI goodness. For now, you can [follow along with the early steps on GitHub](https://github.com/timriley/decafsucks). Right now the app is little more than the basic Hanami skeleton with added database integration and a CI setup (Hello [Buildkite!](https://buildkite.com)), but I plan to grow it bit by bit. Perhaps I’ll try to have something small that I can share with each of these monthly OSS updates.

After Hanami 2 ships, hopefully this will serve as a useful resource for people wanting to see how it plays out in a real working app. And beyond that, I look forward to it serving once again as a place for me to commemorate my coffee travels!

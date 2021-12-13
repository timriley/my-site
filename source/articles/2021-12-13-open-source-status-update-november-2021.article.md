---
title: Open source status update, November 2021
permalink: 2021/12/13/open-source-status-update-november-2021
published_at: 2021-12-13 23:35 +1100
---

One of the things I find hardest about writing these open source status updates is my opening sentence. So I’m just going to leave this one in here and get on with journalling another month of steady progress!

## We shipped the first of our monthly Hanami alphas!

After our [last alpha release](https://hanamirb.org/blog/2021/11/09/announcing-hanami-200alpha3/) and our promise to ship monthly, we delivered the next alpha right on time, with [Hanami 2.0.0.alpha4 going out the door](https://hanamirb.org/blog/2021/12/07/announcing-hanami-200alpha4/) on the 7th of December.

The release was a very orderly process this time around, especially compared to my late night marathons of the last two. Luca was our release manager (we’re alternating duties), and a few days before the release, we already had the gems lined up and release announcement prepared. I’ve a feeling this will make for a really helpful cadence for us. Anyway, go check out the [announcement post](https://hanamirb.org/blog/2021/12/07/announcing-hanami-200alpha4/) for the changes, a few of which I’ll cover in detail below.

## Access to routes helpers inside all actions

Way back in July, Marc Busqué [prepared a class](https://github.com/hanami/hanami/pull/1119) to provide access to helper methods returning URLs for all of the named routes in an application. This languished for a while, but we got it merged in preparation for the alpha3 release. This made the routes helpers accessible via a component registered with the `"routes"` container key. This is all fine if you want to inject this object explicitly, but we want to make it easier still in the common usage contexts, like action and view classes.

For alpha4 we’ve made it automatically available in both those places!

Making it available in the actions was [a fairly straightforward extension](https://github.com/hanami/controller/pull/358) of the existing set of dependencies we automatically provide. There was a little wrinkle here, however: the “resolver” that we have the Hanami application provide to the router (for resolving action objects from string container keys) was resolving those objects eagerly, i.e. directly fetching them from the container for every declared route. This led to an infinite loop, since the first action would auto-inject the router helper, which in turn required the router, which then tried to load each again again, and so on. After [a small change to make the router resolver lazy](https://github.com/hanami/hanami/pull/1132), we were back in business and the routes helper was available. The lazy router resolver is something we would have wanted to build before 2.0.0 final anyway (a big principle behind 2.0.0 is to make it easy to load only subsets of your application), so I’m glad we had this as a prompt to do it now.

The end result is that you can now have routes like this:

```ruby
module TestApp
  class Routes < Hanami::Application::Routes
    define do
      slice :main, at: "/" do
        get "test", to: "test"
        get "examples", to: "examples.index", as: :examples
      end
    end
  end
end
```

And then access your named routes inside an action with no extra work:

```ruby
module Main
  module Actions
    class Test < Hanami::Action
      def handle(req, res)
        res.redirect routes.path(:examples)
      end
    end
  end
end
```

Thanks to Marc’s ongoing work in this space, we’ll have the same arrangement set up for views by this time next month, too.

## Improvements to the Hanami console

I’ve been preparing another Hanami app at work lately, and noticed we’d experienced some regressions in the console experience compared to the arrangement we had in place back for [our original Hanami 2 application template](/writing/2020/05/07/sharing-my-hanami-2-application-template/). Notably, slice helpers weren’t available, nor was there a shortcut to access the application class. I [fixed these here](https://github.com/hanami/cli/pull/5), and now this wonderful experience is available again:

```
$ ./bin/hanami console

test_app[development]> app
=> RecognitionService::Application

test_app[development]> main
=> #<Hanami::Slice:0x00007fdc97ab47a0
 @application=RecognitionService::Application,
 @container=Main::Container,
 @name=:main,
 @namespace=Main,
 @namespace_path="main",
 @root=#<Pathname:/Users/tim/Source/cultureamp/recognition-service/slices/main>>
```

Having such quick and easy access to the application and its slices is a big part of what makes the Hanami console experience so pleasurable! And this is in addition to its constant start time, no matter how large your app (remember my note above about having the framework support loading subsets of the application?), because it only loads the most minimal subset of the app, and then brings in the rest of your components lazily, only as you require them.

While I was in CLI land, I also decided to finally figure out why our IRB-based console wasn’t offering a custom prompt, and [managed to get that one fixed too](https://github.com/hanami/cli/pull/6). IRB shows its age in this regard: Pry offers a much nicer setup and customisation experience.

## Preparing for flexible source dir configuration

In the remainder of my OSS time this month, I was slowly moving towards the next evolution of the configurable Hanami component dirs I shipped [last month](/writing/2021/11/15/open-source-status-update-october-2021). The plan here is to make it support “source dir” configuration in general, not just for component dirs. This should allow a user to configure component dirs when they want source dirs to be auto-registered (along with full access to the dry-system component dir configuration), as well as ordinary source dirs, when they want a directory to be autoloaded by Zeitwerk, but not populate the container.

The beginning of my work on the Hanami side [is available here](https://github.com/hanami/hanami/pull/1133), and the approach I’m taking is to leverage dry-system’s own `Config::ComponentDirs` class for most of the component dir heavy lifting. This means we’ll need to add a range of new behaviours to that class, which is [in progress here](https://github.com/dry-rb/dry-system/pull/195).

I’m hoping to have this one ready by the end of the year. More on this in next month’s update.

<!-- ## Thank you to my sponsors ❤️

The log4j incident this week has [hopefully](https://twitter.com/FiloSottile/status/1469441477642178561) [served](https://twitter.com/FiloSottile/status/1469749412998041610) as a [timely](https://twitter.com/carmatrocity/status/1469829256146468865) [reminder](https://twitter.com/solnic29a/status/1470306767594733568) that our open source model [needs work](https://christine.website/blog/open-source-broken-2021-12-11).

I’m working on building the next generation of Ruby web frameworks – bringing vitality and diversity to a space sorely needs it – almost exclusively in my spare time. If you’d like to support this effort, consider [sponsoring my work on GitHub](https://github.com/sponsors/timriley). Triply so if you’re a company working with any of Hanami, dry-rb, or rom-rb.

Thanks as ever to [Jason Charnes](https://github.com/jasoncharnes) for your support as my sole level 3 sponsor. -->

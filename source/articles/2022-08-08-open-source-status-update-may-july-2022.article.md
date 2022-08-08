---
title: Open source status update, May–July 2022
permalink: 2022/08/08/open-source-status-update-may-july-2022
published_at: 2022-08-08 15:20 +1000
---

Hi there friends, it’s certainly been a while, and a lot has happened across May, June and July: [I left my job, took some time off, and started a new job](/writing/2022/06/14/joining-buildkite-and-sticking-with-ruby/). I also managed to get a good deal of open source work done, so let’s take a look at that!

## Released Hanami 2.0.0.alpha8

Since we’d skipped a month in our releases, I helped [get Hanami 2.0.0.alpha8 out the door](https://hanamirb.org/blog/2022/05/19/announcing-hanami-200alpha8/) in May. The biggest change here was that we’d finished relocating the action and view integration code into the hanami gem itself, wrapped up in distinct “application” classes, like `Hanami::Application::Action`. In the end, this particular naming scheme turned out to be somewhat short lived! Read on for more :)

## Resurrected work using dry-effects within hanami-view

As part of an effort to make it easy to use our conventional view “helpers” in all parts of our view layer, I [resurrected my work from September 2020(!)](/writing/2020/10/06/open-source-status-update-september-2020/) on using dry-effects within hanami-view. The idea here was to achieve two things:

1. To ensure we keep only a single context object for the entire view rendering, allowing its state to be preserved and accessed by all view components (i.e. allowing both templates, partials and parts all to access the very same context object)
2. To enable access to the _current_ template/partial’s `#locals` from within the context, which might help make our helpers feel a little more streamlined through implicit access to those locals

I got both of those working ([here’s my work in progress](https://github.com/hanami/view/pull/179)), but I discovered the performance had worsened due to the cost of using an effect to access the locals. I took a few extra passes at this, reducing the number of effects to one, and memoziing it, leaving us with improved performance over the `main` branch, but with a slightly different stance: the single effect is for accessing the context object only, so any helpers, instead of expecting access to locals, will instead only have access to that context. The job from here will be to make sure that the context object we build for Hanami’s views has everything we need for an ergonomic experience working with our helpers. I’m feeling positive about the direction here, but it’ll be a little while before I get back to it. Read on for more on this (again!).

## Unified application and slice

The biggest thing I did over this period was to unify Hanami’s `Application` and `Slice`. This one took some doing, and I was glad that I had a solid stretch of time to work on it between jobs.

I already wrote about this [back in April’s update](/writing/2022/05/15/open-source-status-update-april-2022/), noting that I’d settled on the approach of having a composed slice inside the `Hanami::Application` class to providing slice-like functionality at the application level. This was the approach I continued with, and as I went, I was able to move more and more functionality out of `Hanami::Application` and into `Hanami::Slice`, with that composed “application slice” being the thing that preserved the existing application behaviour. At some point, a pattern emerged: the application _is_ a slice, and we could achieve everything we wanted (and more) by turning `class Hanami::Application` into `class Hanami::Application < Hanami::Slice`.

Turning the application into a slice sublcass is indeed [how I finished the work](https://github.com/hanami/hanami/pull/1162), and I’m extremely pleased with how it turned out. It’s made slices so much more powerful. Now, each slice can have its own config, its own dedicated settings and routes, can be run on its own as a Rack application, and can even have its own set of child slices.

As a user of Hanami you won’t be required to use all of this per-slice power features, but they’ll be there if or when you want them. This is a great example of _progressive disclosure_, a principle I follow as much as possible when designing Hanami’s features: a user should be able to work with Hanami in a simple, straightforward way, and then as their needs grow, they can then find additional capabilities waiting to serve them.

Let’s explore this with a concrete example. If you’re building a simple Hanami app, you can start with a single top-level `config/settings.rb` that defines all of the app’s own settings. This settings object is made available as a `"settings"` component registration in both the app as well as all its slices. As the app grows and you add a slice or two, you start to add more slice-specific settings to this component. At this point you start to feel a little uncomfortable that settings specific to `SliceA` are also available inside `SliceB` and elsewhere. So you wonder, could you go into `slices/slice_a/` and drop a dedicated `config/settings.rb` there? The answer to that is now yes! Create a `config/settings.rb` inside _any_ slice directory and it will now become a dedicated settings component for that slice alone. This isn’t a detail you had to burden yourself with in order to get started, but it was ready for you when you needed it.

Another big benefit of this code reorganisation is that the particular responsibilities of `Hanami::Application` are _much_ clearer: its job is to provide the single entrypoint to the app and coordinate the overall boot process; everything else comes as part of it also being a slice. This distinction is made clear through the number of public methods that exist across the two classes: `Application` now has only 2 distinct public methods, whereas `Slice` currently brings 27.

There’s [plenty more detail over in the pull request](https://github.com/hanami/hanami/pull/1162): go check it out!

The work here also led to changes across the ecosystem:

- Because we’re now importing components from the app into other slices in the root key namespace (rather than prefixed by `"application."` as before), we needed to [make that possible in dry-system](https://github.com/dry-rb/dry-system/pull/236).
- But with it being possible for each slice to have its own dedicated version of certain components (like `"settings"` in the example above), we also needed to make dry-system [prefer local components when importing](https://github.com/dry-rb/dry-system/pull/241).
- This itself needed a tweak to dry-container such that we could [reverse the order of its `Container#merge` via a block parameter](https://github.com/dry-rb/dry-container/pull/83).
- To make certain components conditional within the slice containers, we’re using dry-system’s class-based provider sources, which [needing tweaking to support deeper class hierarchies](https://github.com/dry-rb/dry-system/pull/240).

This is one the reasons I’m excited about Hanami’s use of the dry-rb gems: it’s pushing them in directions no one has had to take them before. The result is not only the streamlined experience we want for Hanami, but also vastly more powerful underpinnings.

## Devised a slimmed down core app structure

While I had my head down working on internal changes like the above, Luca had been thinking about Hanami 2 adoption and the first run user experience. As we had opted for a slices-only approach for the duration of our alpha releases, it meant a fairly _bulky_ overall app structure: every slice came with multiple deeply nested files. This might be overwhelming to new users, as well as feeling like overkill for apps that are intended to start small and stay small.

To this end, we agreed upon a stripped back starter structure. Here’s how it looks at its core (ignoring tests and other general Ruby files):

```
├── app/
│   ├── action.rb
│   └── actions/
├── config/
│   ├── app.rb
│   ├── routes.rb
│   └── settings.rb
├── config.ru
└── lib/
    ├── my_app/
    │   └── types.rb
    └── tasks/
```

That’s it! Much more lightweight. This approach takes advantage of the Hanami app itself becoming a fully-featured slice, with `app/` now as its source directory.

In fact, I took this opportunity to [unify the code loading rules for both the app and slices](https://github.com/hanami/hanami/pull/1174), which makes for a much more intuitive experience. You can now drop any ruby source file into `app/` or a `slices/[slice_name]/` slice dir and it will be loaded in the same way: starting at the root of each directory, classes defined therein are expected to inhabit the namespace that the app or slice represents, so `app/some_class.rb` would be `MyApp::SomeClass` and `slices/my_slice/some_class` would be `MySlice::SomeClass`. Hat tip to [me of September 2021](/writing/2021/10/11/open-source-status-update-september-2021/) for implementing the dry-system namespaces feature that enabled this! 😜

(Yet another little dry-system tweak came out of preparing this too, with [`Component#file_name` now exposed](https://github.com/dry-rb/dry-system/pull/237) for auto-registration rules).

This new initial structure for starter Hanami 2.0 apps is another example of progressive disclosure in our design. You can start with a simple all-in-one approach, everything inside an `app/` directory, and then as various distinct concerns present themselves, you can extract them into dedicated slices as required.

Along with this, some of our names have become shorter! Yes, [“application” has become “app”](https://github.com/hanami/hanami/pull/1180) (and `Hanami::Application` has become `Hanami::App`, and so on). These shorter names are easier to type, as well as more reflective of the words we tend to use when verbally describing these structures.

We also tweaked our actions and views integration code so that it is automatically available when you inherit directly from `Hanami::Action`, so it will no longer be necessary to have the verbose `Hanami::Application::Action` as the superclass for the app’s actions. We also [ditched that namespace](https://github.com/hanami/hanami/pull/1172) for both routes and settings too, so now you can just inherit from `Hanami::Settings` and the like.

## Devised a slimmed down release strategy

Any of you following my updates would know by now that the Hanami 2.0 release has been a long time coming. We have ambitious goals, we’re doing our best, and everything _is_ slowly coming together. But as hard as it might’ve been for folks who’re waiting, it’s been doubly so for us, feeling the weight of both the work along with everyone’s expectations.

So to make sure we can focus our efforts and get something out the door sooner rather than later, we decided to stagger our 2.0 release. We’ll start off with an initial 2.0 release centred around hanami, hanami-cli, hanami-controller, and hanami-router (enough to write some very useful API applications, for example), then follow up with a “full stack” 2.1 release including database persistence, views, helpers, assets and everything else.

I’m already feeling empowered by this strategy: 2.0 feels actually achievable now! And all of the other release-related work like updated docs and a migration guide will become correspondingly easier too.

## Released Hanami 2.0.0.beta1!

With greater release clarity as well as all the above improvements under our belt, it was time to usher in a new phase of Hanami 2.0 development, so [we released 2.0.0.beta1](https://hanamirb.org/blog/2022/07/20/announcing-hanami-200beta1/) in July! This new version suffix represents just how close we feel we are to our final vision for 2.0. This is an exciting moment!

## And a bunch more

This update is getting rather long, so let me list a bunch of other Hanami improvements I managed to get done:

- You can now [autoload your app’s constants from within your settings file](https://github.com/hanami/hanami/pull/1186), which is useful if you’re referring to a types module to type check your settings. This turned out to be a larger change than expected, but it’s further bolstered our slice capabilities, because it led to each slice getting its own Zeitwerk autoloader instance, meaning each slice fully owns its code loading lifecycle.
- `.env` file loading is now [a much clearer step upon subclassing `Hanami::App`](https://github.com/hanami/hanami/pull/1190), rather than it being a side effect of loading the settings. This is useful in case you want to directly access the `ENV` for any other purpose.
- The `.prepare_container` escape hatch allowing for last-minute manual adjustments to a slice’s internal dry-system container is now [run after all possible framework setup has been applied](https://github.com/hanami/hanami/pull/1185)
- In the few places we rescue from `LoadError`, we now ensure [we don’t swallow any unintended errors](https://github.com/hanami/hanami/pull/1166)
- Hanami now [respects RACK_ENV if HANAMI_ENV is not set](https://github.com/hanami/hanami/pull/1168), which is useful for Rack-first apps that happen to be migrating to Hanami 2.0 (these do exist!)
- I [removed the settings allowing for customisation of the routes and settings file paths](https://github.com/hanami/hanami/pull/1175). The further I go with batteries included framework development, the better sense I think I’m developing for what _should’t_ be configurable. This is one such case: we can’t provide reasonable documentation or support if these files can live in arbitrary locations.
- Last but not least, I built [conditional slice loading](https://github.com/hanami/hanami/pull/1189)! But since this isn’t merged yet, I’ll go into details on this in next month’s update ;)

Outside my Hanami development, a new job and a new computer meant I also took the change to [reboot my dotfiles](http://github.com/timriley/dotfiles), which are now powered by [chezmoi](https://www.chezmoi.io). I can't speak highly enough of chezmoi, it’s an extremely powerful tool and I’m loving the flexibility it affords!

That’s it from me for now. I’ll come back to you all in another month!

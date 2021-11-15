---
title: Open source status update, October 2021
permalink: 2021/11/15/open-source-status-update-october-2021
published_at: 2021-11-15 11:30:00 +1100
---

It’s one of my favourite kinds of monthly updates, folks, because I have another Hanami alpha release to share! Let’s dive straight into it.

## We shipped dry-system 0.21.0!

Remember [all that good stuff](https://timriley.info/writing/2021/10/11/open-source-status-update-september-2021/) I described about dry-system’s component dir namespaces last month? It’s now properly released! You can upgrade to dry-system 0.21.0 to give it a try.

You can also check out the new [component dirs page](https://dry-rb.org/gems/dry-system/0.21/component-dirs/) of our user documentation that I created for this release, which outlines every configurable aspect of dry-system’s component dirs. There’s a lot more we can do to improve dry-system’s documentation, but this is at least a start.

## We shipped Hanami 2.0.0.alpha3!

And here’s the big one! After 6 months, we shipped another Hanami 2.0 alpha release! Go [read the announcement post](https://hanamirb.org/blog/2021/11/09/announcing-hanami-200alpha3/) to start with – I’ll wait! – then we can look a bit more behind the scenes.

So what was this actually like for me? Shipping this alpha turned out almost exactly like the last one: a few nights straight trying to get everything ready, followed by another in which I decide we’re shipping come hell or high water. And exactly like last time, it ended with me in a daze at 1:30am having just finished the blog post, waiting for the Hanami website static generation to to complete so I could finally hit the sack 😅

A notable milestone for me was that this was the first time I pushed out the releases of all the individual Hanami gems. I’m looking forward to this becoming a regular thing in the future.

## Streamlined slice directories

Given the months I spent getting dry-system ready for week, of course this is favourite aspect of this release. We now support this as a standard source directory structure for each of your application’s slices:

```
└── slices
    └── main
        ├── actions/
        ├── lib/
        ├── repositories/
        └── views/
```

`lib/` is intended to hold your slice’s core business logic. Inside `lib/`, every file is expected to define a class inside your slice’s Ruby namespace, in this case `Main`. So `lib/my_class.rb` would define `Main::MyClass`, and would be registered in the slice as `"my_class".`

Previously, this had to be `lib/main/my_class.rb`, and removing that one redundant `main/` from the path was the driver behind our months of work in this space. I’m thankful now there’s one less possible papercut for our users, but I’m also thankful we did the work _right_, because it opened up the possibility for those other source directories in the slice!

`actions/`, `views/`, and `repositories/` are these new entrants here. The intention for these directories is to hold special categories of classes for your slice. In this case `actions/` and `views/` are key _entrypoints_, in that their job is to provide an external interface, then and mostly coordinate with other objects from the slice to invoke the necessary business logic. `repositories/` are intended to be the key interface between your slice and its persistence layer, and in many cases may provide cross-cutting behaviour within the slice.

For each of these non-`lib/` directories, there are some different rules: they’re expected to hold files defining classes in a matching namespace. So in this case, `actions/posts/show.rb` would define `Main::Actions::Posts::Show`, and would be registered under a matching namespace, at `"actions.posts.show"`.

You can add your own additional source directories too, too. To start with, we’ve made them configurable via `config.component_dir_paths` inside your application class, which defaults to `["actions", "repositories", "views"]`. I plan to make this a much richer configuration object in the coming months, allowing you to add directories for autoloading only (i.e. not for component auto-registration), as well as manually configure the namespace rules for those dirs that are auto-registering components.

## New loading rules for the top-level lib/

Along with the changes to the source directories in the slices, we made a big change to how we handle the top-level `lib/`. Previously, we would auto-register components from `lib/[application_namespace]/`. These would end up in the application container, and then in turn be imported into every slice container.

For example, given a `lib/my_app/my_shared_class.rb`, the application container would have a `"my_shared_class"` component, and every slice would then have an imported `"application.my_shared_class"` component. This general approach is one I’ve worked with for a while now, including in the in-house Icelab framework that preceded Hanami 2 development, and it’s worked reasonably well. The application container has been a good place to put components that are common to other slices. For a moment in the lead up to this release, I even toyed with further enshrining this approach, and loading such components from a special `app/` directory. However, this led to some great feedback and a follow-up discussion with Luca, in which he noted that directories like these are ripe for unintended misuse, in that they create undesirable coupling between the application and all of its slices (not to mention the possible confusion with the Rails-like `app/` directory naming).

So to address this concern and encourage a healthier separation of concerns within Hanami 2 apps, we’ve changed the code loading rules for the top-level `lib/`:

- `lib/[application_namespace]/` will still be autoloaded, so you won’t need to manage any manual `require` statements to bring in your own classes
- However, `lib/[application_namespace]` will no longer be a component directory, so files here will no longer auto-register in the application container

With these changes, you can still use `lib/[application_namespace]` to keep your own shared base classes and other manually invokable code, but if you would like to share _components_ with your slices, we’re encouraging you to create your own dedicated slices to house them. This act of slice creation and naming will hopefully encourage you to take the opportunity to draw more appropriate boundaries between these extra slices, giving them better cohesion and allowing other slices to import only the parts they need.

For example, if you previously had clusters of components in your app container related to (a) password encryption as well as (b) exchange rate calcuation, both as common concerns, then the approach to take here would be to extract them into well-bounded slices of their own, at `slices/password_encryption` and `slices/exchange_rates`, and then import those from only the other slices that need them, e.g.

```ruby
module MyApp
  class Application < Hanami::Application
    config.slice :admin do
      # Importing a common "password_encryption" slice into the admin slice; all components from
      # the imported slice will be accessible with keys prefixed by "password_encryption."
      import :password_encryption
    end
  end
end
```

This is a much more intentional arrangement of concerns, and should result in a better factored and more maintainable modular application.

Of course, if you really do need to register components in the application container, you can still do this via a file in `config/boot/`, e.g.

```ruby
Hanami.application.register_bootable :my_component do |container|
  start do
    require "some_global_component"

    register "my_component", SomeGlobalComponent.new
  end
end
```

Hopefully this provides just the right amount of friction (compared to the ease of creating a new slice with its own auto-registered classes) that this path is only taken for the very small number of components that truly need to be global.

Lastly, after all of these changes, one thing we haven’t messed with is the fact that the top-level `lib/` directory is still added to Ruby’s standard `$LOAD_PATH`, which means you have a place to put any files _outside_ of the application namespace (e.g. if you’re incubating future-gems inside your application) and still `require` them explicitly.

## All in on Zeitwerk

One thing is common to all the changes above: they all depend on the [Zeitwerk](https://github.com/fxn/zeitwerk) autoloader. Our experience with Zeitwerk has been fantastic: it’s well documented, has been configurable wherever we need it, and then utterly predictable once we’ve set it up.

These changes have further embedded the importance of Zeitwerk for Hanami 2: it’s become well and truly a “load bearing” part of the framework. So we’ve decided to go _all in_ on Zeitwerk for Hanami 2.

Initially, the autoloader was configurable, with it being possible to opt out and fall back to managing your own standard `require` statements everywhere. As of alpha3, however, the autoloader is now always on, an expected part of the framework. As a former "require what you require" kind of Rubyist, now that I’ve had some experience with Zeitwerk, there’s no way I’m going back. I expect every Hanami 2 user to feel the same, and with Zeitwerk in place, we give ourselves the best chances for further streamlining our users’ experience in the future.

Thank you [Xavier Noria](https://github.com/fxn) for your sterling work in this space 🙏🏼

## Coming up: monthly alphas!

Getting to the point of releasing alpha3 was a lot of work, and hopefully the last of our big foundational overhauls. Now we’re on the other side of this, we want to really build our momentum towards a 2.0.0 final release. So from here we’ll be releasing monthly alphas, collecting up any of the work that’s happened over the previous month. We’ve already set a date for the next one: look out for something on or around December 7th!

I’m _really_ excited about this next phase. If you’ve followed along with my previous OSS updates, you would’ve picked up how much of a drag it has been for working on months on end with no reward or punctuation of any kind. I hope the monthly cadence will help us keep our changes short and sharp, and things overall moving at a much faster clip.

## Thank you to my sponsors ❤️

My work in Ruby OSS is kindly supported by my [GitHub sponsors](https://github.com/sponsors/timriley).

Thank you in particular to [Jason Charnes](https://github.com/jasoncharnes) for your continued support as my sole level 3 sponsor. Jason, you’re an absolute mensch.

If you want to help make Hanami 2 a reality, I’d love it if you could [join my sponsors too](https://github.com/sponsors/timriley).


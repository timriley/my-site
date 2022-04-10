---
title: Open source status update, 🇺🇦 February 2022
permalink: 2022/03/19/open-source-status-update-february-2022
published_at: 2022-03-19 23:55 +1100
---

After the [huge month of January](/writing/2022/02/14/open-source-status-update-december-2021-january-2022/), February was naturally a little quieter, but I did help get a couple of nice things in place.

## Stand with Ukraine 💙💛

This is my first monthly OSS update since Russia began its brutal, senseless war on Ukraine. Though I was able to ship some work this month, there are millions of people whose lives and homeland have been torn to pieces. For a perspective from one of our Ruby friends in Ukraine, read [this piece](https://zverok.space/blog/2022-03-03-WAR.html) and [this update](https://zverok.space/blog/2022-03-15-STILL-WAR.html) from Victor Shepelev, aka [zverok](http://twitter.com/zverok/).

Let’s all continue to [support Ukraine](https://ua-aid-centers.com/funds-and-foundations), and help the international community continue doing the same.

## Concrete slice classes

For this month I focused mostly on getting [concrete slice classes in place](https://github.com/hanami/hanami/pull/1150) for Hanami applications. As I described in the [alpha7 release announcement](https://hanamirb.org/blog/2022/03/08/announcing-hanami-200alpha7/), concrete slice classes give you a nice place for any slice-specific configuration.

They live in `config/slices/`, and look like this:

```
# config/slices/main.rb:

module Main
  class Slice < Hanami::Slice
    # Slice config goes here...
  end
end
```

As of this moment, you can use the slice classes to configure your slice imports:

```ruby
# config/slices/main.rb:

module Main
  class Slice < Hanami::Slice
    # Import all exported components from "search" slice
    import from: :search
  end
end
```

As well as particular components to export:

```ruby
# config/slices/search.rb:

module Search
  class Slice < Hanami::Slice
    # Export the "index_entity" component only
    export ["index_entity"]
  end
end
```

Later on, I’ll look to expand this config and find a way for a subset of application-level settings to be configured on individual slices, too. I imagine that configuring `source_dirs` on a per-slice basis may be useful, for example, if you want particular source dirs to be used on one slice, but not others.

The other thing you can currently do on these slice classes is configure their container instance:

```ruby
# config/slices/search.rb:

module Search
  class Slice < Hanami::Slice
    prepare_container do |container|
      # `container` (a Dry::System::Container subclass) is available here with
      # slice-specific configuration already applied
    end
  end
end
```

This is an advanced feature and not something we expect typical Hanami users to need. However, I wanted this in place so I could continue providing “escape valves” across the framework, to allow Hanami users to reach below the framework layer and manually tweak the lower-level parts without having to eject entirely from the framework and all the other niceties it provides.

## Slice registration refactors

As part of implementing the concrete slice classes, I was able to make some [quite nice refactors](https://github.com/hanami/hanami/pull/1150) around the way we handle slices within the Hanami application:

- All responsibility for slice loading and registration has now away from `Application` (which is already doing a lot of other work!) into a new [`SliceRegistrar`](https://github.com/hanami/hanami/blob/32c5bd4bafe938e9c14ba2611f10670f7fefa98b/lib/hanami/application/slice_registrar.rb).
- The `.prepare` methods inside both [`Application`](https://github.com/hanami/hanami/blob/32c5bd4bafe938e9c14ba2611f10670f7fefa98b/lib/hanami/application.rb#L57-L68) and [`Slice`](https://github.com/hanami/hanami/blob/32c5bd4bafe938e9c14ba2611f10670f7fefa98b/lib/hanami/slice.rb#L47-L59) are now roughly identical in structure, with their many constituent setup steps extracted into their own well-named methods ([for example](https://github.com/hanami/hanami/blob/32c5bd4bafe938e9c14ba2611f10670f7fefa98b/lib/hanami/slice.rb#L155-L164)). This will make this phase of the boot process much easier to understand and maintain, and I also think it hints at a future in which we have an _extensible_ boot process, wherein other gems may register their own steps as part of the overall sequence that is run when you `.prepare` and application or slice.

## The single-file-app dream lives on

One nice outcome of the concrete slice work is the fact that these classes are _not actually required_ in your Hanami application for it to boot and do its job. It will still look for directories under `slices/` and dynamically create those classes if they don’t already exist in `config/slices/`. What’s even better, however, is that I made this behaviour more easily user-invokable via a public `Application.register_slice` method. This means you can choose to explicitly register a slice, in cases where the framework may not otherwise detect it:

```ruby
module MyApp
  class Application < Hanami::Application
    # That's all! This will define a `Main::Slice` class for you.
    register_slice :main
  end
end
```

But that’s not all! Since these slice classes will now be the place for slice-specific configuration, we may need to provide this when explicitly registering a slice too. For this, you can provide a block that is then evaluated within the context of the generated slice class:

```ruby
module MyApp
  # Defines `Main::Slice` class and instance_evals the given block
  class Application < Hanami::Application
    register_slice(:main) do
      import from: :search
    end
  end
end
```

And lastly, you can also provide your own concrete slice class at this point, too:

```ruby
module MyApp
  class Application < Hanami::Application
  end
end

module Main
  class Slice < Hanami::Slice
  end
end

MyApp::Application.register_slice :main, Main::Slice
```

One of the guiding forces behind this level of flexibility (apart from it just feeling like the Right Thing To Do) is that I want to keep open the option for single-file Hanami applications. While the framework will always be designed primarily for fully-fledged applications, with their components spread across many source files, sometimes a single file app is still the right tool for the job, and I want Hanami to work here too. As I put the final polish on the core application and slice structures over the coming couple of months, I’ll be keeping this firmly in mind, and will look to share a nice example of this in a future blog post :)

## Removed some unusued (and unlikely to be used) flexibility

While I like to try and keep the Hanami framework flexible — and we’ve already looked at several approaches to this just above — I’m also conscious of the cost of this flexibility, and how in certain cases, those costs are just not worth it. One example of this was the [removal of the configurable key separator in dry-system](https://github.com/dry-rb/dry-system/pull/206) earlier this year. In this case, keeping the key separator configurable meant not only significant internal complexity, but also the fact that we could never write documentation that we could be fully confident would work for all people. To boot, we hadn’t heard of a single user wanting to change that separating over the whole of dry-system’s existence.

As part of [my work this month](https://github.com/hanami/hanami/pull/1150), I removed a couple of similar settings from Hanami:

- I removed the `config.slices_namespace` setting, which existed in theory to allow slices to also live inside the application’s own module namespace if a user desired (e.g. `MyApp::Main` instead of just `::Main`). In reality, I think that extra level of nesting will be too invoncenient for users to want. More importantly, I think that having our slices always mapping to single top-level modules will be important for our documentation (and generators, and many other things I’m sure) to be clearer.
- I also remove the `config.slices_dir` setting, for much the same reasons. Hanami will be far easier to document and support if slices are always loaded from `slices/` and nowhere else.

## Made `Application.shutdown` complete

Did you know that you can both boot _and_ shut down an Hanami application? The latter will call `stop` on any registered providers, which can be useful if you need to actively disconnect from any external resources, such as database connections.

You can shutdown an Hanami application via `Application.shutdown`, but the implementation was only partially complete. As of [this PR](https://github.com/hanami/hanami/pull/1154), shutdown now works for both slices (and their providers) and when shutting down an application, it will shutdown all the slices in turn.

## Simplified configuration by permitting `env` to be provided just once

Another little one: the application configuration depends on knowing the current Hanami env (i.e. `Hanami.env`) in several ways, such as knowing when to set env-specific defaults, or apply user-provided env-specific config. Until now, it’s been theoretically possible to re-set the env even after the configuration has loaded, which makes the env-specific behaviour much harder to reason about. With [this change](https://github.com/hanami/hanami/pull/1153), the env is now set just once (based on the `HANAMI_ENV` env var) when the configuration is initialized, allowing us to much more confidently address the env across all facets of the configuration behavior.

(This and the `shutdown` work together in a single evening session. For many reasons, I was feeling down, and this was a nice little bit of therapy for me. So much of what I’ve been doing here lately spans multiple days and weeks, and having a task I could complete in an hour was a refreshing change.)

## Worked to define a consistent action and view class structure

This effort was mostly driven by Luca, but we worked together to arrive at a consistent structure for the action and view classes to be generated in Hanami applications.

For actions, for example, the following classes will be generated:

- A single application-level base class, e.g. `MyApp::Action::Base` in `lib/my_app/action/base.rb`. This is where you would put any logic or configuration that should apply to every action across all slices within the application.
- A base class for each slice, e.g. `Main::Action::Base` in `slices/main/lib/action/base.rb`, inheriting from the application-level base class. This is where you would put anything that should apply to all the actions only in the particular slice.
- Every individual action class would then go into the `actions/` directory within the slice, e.g. `Main::Actions::Articles::Index` in `slices/main/actions/articles/index.rb`.

For views, the structure is much the same, with `MyApp::View::Base` and `Main::View::Base` classes located within an identical structure.

The rationale for this structure is that it provides a clear place for any code to live that serves as supporting “infrastructure” for your application’s actions and views: it can go right alongside those `Base` classes, in their own directories, clearly separated from the rest of your concrete actions and views.

This isn’t an imagined requirement: in a standard Hanami 2 application, we’ll already be generating additional classes for the view layer, such as a view context class (e.g. `Main::View::Context`) and a base view part class (e.g. `Main::View::Part`).

This structure is intended to serve as a hint that your own application-level action and view behavior can and should be composed of their own single-responsibility classes as much as possible. This is one of the many ways in which Hanami as a framework can help our users make better design choices, and build this up as a muscle that they can apply to all facets of their application.

## Released alpha7

Last but not least, I cut the release of Hanami 2.0.0.alpha7 and [shared it with the world](https://hanamirb.org/blog/2022/03/08/announcing-hanami-200alpha7/).

## What’s next?

My next focus has been on a mostly internal refactor to move a bunch of framework integration code from hanami-controller and hanami-view back into the hanami gem itself, since a lot of that is interdependent and important to maintain in sync in order to provide a cohesive, integrated experience for people building full stack Hanami applications. This should hopefully be ready by the next alpha, and will then free me up to move back onto application/slice polish.

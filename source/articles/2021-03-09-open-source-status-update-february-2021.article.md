---
title: Open source status update, February 2021
permalink: 2021/03/09/open-source-status-update-february-2021
published_at: 2021-03-09 22:20:00 +1100
---

Well hey there, Ruby open source fans! February for me was all about consolidating the [dry-system breakthroughs](/writing/2021/02/01/open-source-status-update-january-2021/) I made last month.

I started off by testing the work on a real app I made, and happily, all was fine! Things all looking good, I wrote myself a list and shared it with my Hanami colleagues:

> [timriley] So what’s left for me to do here:
>
> - Release dry-configurable with the new cloneable values support
> - Apply @Nikita Shilnikov’s excellent feedback to https://github.com/dry-rb/dry-system/pull/157
> - Merge https://github.com/dry-rb/dry-system/pull/155
> - Merge https://github.com/dry-rb/dry-system/pull/155
> - Merge https://github.com/hanami/controller/pull/341
> - Merge https://github.com/hanami/hanami/pull/1093
> - In a new PR, configure Zeitwerk for Hanami, and enable the autoloading loader for Hanami’s container component_dirs

Everything started well: by the 15th of Feb I [released dry-configurable 0.12.1](https://github.com/dry-rb/dry-configurable/releases/tag/v0.12.1) with the new `cloneable` option for custom setting values. And a mere hour later, I merged the two dry-system PRs! Woo, we’re on the home straight!

At that point, I gave [Nikita](https://github.com/flash-gordon) the go-ahead to test all the dry-system changes on some of the apps that he manages: he’s absolutely brazen about running our bleeding edge code, and I love it. I this case, it was very helpful, because it revealed little wrinkle in my heretofore _best laid plans_: if you configure a dry-system container with a component dir and a default namespace, and some of the component files sit _outside_ that namespace, then they would fail to load. This was a valid use case missing from our test suite, and something I must’ve broke in my major changes last month.

This turned out to be relatively simple for me to hack in a fix, but at the same time I noticed an opportunity for yet another improvement: spread across multiple parts of dry-system was a bunch of (often repeated) string manipulation code working on container identifiers, doing things like removing a leading namespace, or converting a delimited identifier to a file path. It felt like there was a `Dry::System::Identifier` abstraction just waiting to be let out.

And so I did it! [In this omnibus PR](https://github.com/dry-rb/dry-system/pull/158), I introduced `Dry::System::Identifier`, refactored component building once more, and, not to be forgotten, fixed the bug Nikita found.

I’m really happy with both of the refactorings. Let’s start with `Identifier`: now we have just a single place for all the logic dealing with identifier string manipulations, but we also get to provide a new, rich aspect of our component API for users of dry-system. For example, as of my work last month, it’s now possible to configure per-component behaviour around auto-registration, and we can now use the component’s `identifier` like so:

```ruby
config.component_dirs.add "lib" do |dir|
  dir.default_namespace = "my_app"

  dir.auto_register = lambda do |component|
    !component.identifier.start_with?("entities")
  end
end
```

Isn’t that neat? The `Identifier` began life as an internal-only improvement, but here we get to make our user’s life easier too, with namespace-aware methods like `#start_with?` (which will return true only if the `"entities"` is complete leading namespace, like `"entities.user"`, and not `"entities_abc.user"`). I’d like to add a range of similar conveniences to `Identifier` before we release 1.0. Please let me know what you’d like to see!

The other benefit of `Identifier` is that it’s vastly simplified how we load components. Check out how we use it in `ComponentDir#component_for_path`, which is used when the container is finalizing, and the auto-registrar crawls a directory to register a corresponding component for each file (comments added below for the sake of explanation):

```ruby
def component_for_path(path)
  separator = container.config.namespace_separator

  # 1. Convert a path, like "my_app/articles/operations/create.rb"
  #    to an identifier key, "my_app.articles.operations.create"
  key = Pathname(path).relative_path_from(full_path).to_s
    .sub(RB_EXT, EMPTY_STRING)
    .scan(WORD_REGEX)
    .join(separator)

  # 2. Create the Identifier using the key, but without any namespace attached
  identifier = Identifier.new(key, separator: separator)

  # 3. If the identifier is part of the component dir's configured default
  #    namespace, then strip the namespace from the front of the key and
  #    rebuild the identifier with the namespace attached
  if identifier.start_with?(default_namespace)
    identifier = identifier.dequalified(default_namespace, namespace: default_namespace)
  end

  # 4. By this point, the identifier will be appropriate for both default
  #    namespaced components as well as non-namespaced components, so we can go
  #    ahead and use it to build our component!
  build_component(identifier, path)
end
```

Even without the comments, this method is concise and easy to follow thanks to the high-level `Identifier` API. What you’re also witnessing above is the very fix for the bug Nikita found! Getting to this point was a perfect example of [Kent Beck’s](https://twitter.com/KentBeck/status/250733358307500032) “for each desired change, make the change easy (warning: this may be hard), then make the easy change” process. And you bet, it felt good!

In this change I actually introduced a pair of methods on `ComponentDir`: `#component_for_path` (as we saw above), which is used when finalizing a container, as well as `#component_for_identifier`, which is used when lazy-loading components on a non-finalized container. Previously, these two methods were both class-level ”factory” methods on `Component` itself. By moving them to `ComponentDir`, not only are they much closer to the details that are important for building the component, they provide a nice symmatry which will help ensure we don’t miss either case when making changes to component loading in future. `Component` winds up being a much simpler class, too, which is nice.

After all of this, Nikita gave me a happy thumbs up and we were good to merge this PR and resume preparation for a major dry-system release!

But not so fast, I also:

- Spent a full evening adding API docs to the code I introduced/changed in this PR
- [Got the thing merged](https://github.com/dry-rb/dry-system/pull/158), then [swept through the user docs](https://github.com/dry-rb/dry-system/pull/160) to make sure they reflected the recent changes
- And [started working on a mammoth CHANGELOG entry](https://github.com/dry-rb/dry-system/pull/161) upcoming release

It was in writing the CHANGELOG entry that I realised I needed to make _one last change_ before I can really consider this release done: I want to create a way to configure default values for all component dirs. This will be helpful for when we eventually add a one-liner `use :zeitwerk` plugin to dry-system, which will need to ensure that `dir.loader = Dry::Systen::Loader::Autoloading` and `dir.add_to_load_path = false` are set for all subsequent user-configured component dirs. Given the amount of breaking changes we’ll be making with this release, I’d hate to see yet any unnecessary extra churn arise from this work. So that’s my first task for the month of March.

In the meantime, [I have Hanami ready and waiting](https://github.com/hanami/hanami/pull/1093) for this new dry-system release! As soon as our ducks are finally in a row, I’ll be able to merge this and begin the long-anticipated work on configuring Zeitwerk within Hanami.

Looking back on this month, I spent most of it feeling frustrated that I was _still_ working on dry-system after all this time, when I just wanted to get back and make that very last change in Hanami before we could ship the next alpha release. This was exacerbated by a series of late nights that I pulled trying to get that bugfix and related `Identifier` changes working in a way I was happy with. I finished the month feeling pretty drained and the slightest bit cranky.

I’m indeed happy with the outcome and glad I put in the work. And yes, I got to the point where I could laugh about it. From the PR description:

> As part of this work, I also continued my dry-system refactoring journey, because this is more or less my life now 😆.

What I’m taking away from this experience is a reminder that I need to be patient. When working on nights-and-weekends open source, things will only happen when they can happen, and the best we can do is the best we can do. I’ll keep on pushing hard, but February has reminded me to make sure I take care of my (physical and mental) health too.

We’re already a good week into March by the time I’m writing this, and later this month I expect to be moving apartments (yay!), so March may be a slightly less full month from me on the OSS front. If I can squeeze in that last dry-system fix and get myself in a position to begin some early experiments of Zeitwerk in Hanami, I’ll be happy. That’ll put us in a good place to ship the next Hanami alpha early in April.

## Thank you to my sponsors ❤️

If you want to give me a boost in all of these efforts, I’d love for you to [sponsor me on GitHub](https://github.com/sponsors/timriley). Thank you to my sponsors for your ongoing support!

See you next month!

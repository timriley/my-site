---
title: Open source status update, September 2021
permalink: 2021/10/11/open-source-status-update-september-2021
published_at: 2021-10-11 11:45:00 +1100
---

After the last few months of seemingly slow progress (and some corresponding malaise), September was a real watershed for my OSS work! It featured seven gem releases and one giant PR being made ready for merge. Let’s take a look.

## dry-configurable 0.13.0 is out, at last!

I started the month resolved to finish the work on dry-configurable 0.13.0 that I [detailed in the last episode](/writing/2021/09/06/open-source-status-update-july-august-2021/).

I started my updating and merging any of the pending changes across dry-configurable’s dependent dry-rb gems: [dry-container](https://github.com/dry-rb/dry-container/pull/80), [dry-monitor](https://github.com/dry-rb/dry-monitor/pull/45), [dry-schema](https://github.com/dry-rb/dry-schema/pull/373), and [dry-validation](https://github.com/dry-rb/dry-validation/pull/691). Fortunately, thanks to the [extra compatibility work](https://github.com/dry-rb/dry-configurable/pull/121) I’d done in dry-configurable, all of these changes were straightforward.

By this time, there was nothing left to do but release! So on the evening of the 12th of September, I decided I get this _done._ At 9:55pm, I [shipped dry-configurable 0.13.0](https://github.com/dry-rb/dry-configurable/releases/tag/v0.13.0), at long last!

And then I shipped the following:

- [dry-container 0.9.0](https://github.com/dry-rb/dry-container/releases/tag/v0.9.0)
- [dry-system 0.20.0](https://github.com/dry-rb/dry-system/releases/tag/v0.20.0)
- [dry-monitor 0.50](https://github.com/dry-rb/dry-monitor/releases/tag/v0.5.0)
- [dry-schema 1.8.0](https://github.com/dry-rb/dry-schema/releases/tag/v1.8.0)
- [dry-validation 1.7.0](https://github.com/dry-rb/dry-validation/releases/tag/v1.7.0)
- And for good measure, even though it turned out not to need dry-configurable compatibility changes, [dry-effects 0.2.0](https://github.com/dry-rb/dry-effects/releases/tag/v0.2.0)

By 11:30pm, this was all done and I happily [sent out the announcement tweet](https://twitter.com/dry_rb/status/1437045303962595331).

In the time since, we haven’t seen or heard of any issues with the changes, so I think I can consider this change a success!

Despite it taking as long as it did, I’m glad we made this change to move dry-configurable to a clearer API. A lesson I’m taking away from this is to think again before mixing optional positional parameters with keyword args splats in Ruby methods; though this is largely a non-issue for Ruby 3.0, moving away from this while retaining backwards compatibility did cause some grief for Ruby 2.7, and on top of that, I value the extra clarity that keyword arguments bring for anything but an immediately-obvious and required singular positional argument.

## Testing compact slice lib paths in Hanami

With the dry-configurable taken care of, it was time to do the same for the saga of [dry-system namespaces](https://github.com/dry-rb/dry-system/pull/181).

Before I committed to polishing off the implementation in dry-system, I wanted to double check that it’d do the job we needed in Hanami: to elide the redundant lib directory in e.g. `slices/main/lib/main/`, turning it into `slices/main/lib/` only, with all the classes defined therein still retaining their `Main` Ruby constant namespace. As hoped, [it did exactly that!](https://github.com/hanami/hanami/pull/1123) As I shared with the other Hanami contributors:

> Like all of my favourite PRs, it was 3 months of dry-system work, followed by a 3-line change in Hanami 😄

A fun quip, but I think this is an important aspect of the work we’re doing in Hanami 2. We’re not putting in this amount of effort just to arrive at a toughly coupled framework that can deliver only for a small subset of users. Rather, we’re trying to establish powerful, flexible, well-factored building blocks that deliver not only the default Hanami experience, but also serve as useful tools unto themselves. The idea with this approach is that it should allow an Hanami user to “eject” themselves from any particular aspect of the framework’s defaults whenever their needs require it: they can dive deeper and use/configure constituent parts directly, while still using the rest of the framework for the value it provides.

# dry-system component dir namespaces are done, at last!

Confident about the use case in Hanami, I used the rest of the month (and a little bit of October, _shh!_) to finish off the dry-system namespaces. Here’s how they look:

```ruby
class AdminContainer < Dry::System::Container
  configure do |config|
    config.root = __dir__

    config.component_dirs.add "lib" do |dir|
      dir.namespaces.add "admin", key: nil
    end
  end
end
```

This example configures a single namespace for `lib/admin/` that ensures the components have top-level identifiers (e.g. `"foo.bar"` rather than `"admin.foo.bar"`).

Namespaces take care of more than just container keys. If you wanted to mimic what we’re doing in Hanami and expect all classes in `lib/` to use the `Admin` const namespace, you could do the following:

```ruby
config.component_dirs.add "lib" do |dir|
  dir.namespaces.root const: "admin"
end
```

You’re not limited to just a single namespace, either:

```ruby
config.component_dirs.add "lib" do |dir|
  dir.namespaces.add "admin/system_adapters", key: nil, const: nil
  dir.namespaces.add "admin", key: nil
  dir.namespaces.add "elsewhere", key: "stuff.and.things"
end
```

If you want to learn more, [go read the overview in the PR](https://github.com/dry-rb/dry-system/pull/181): there’s around 3,000 words explaining the history, rationale, and full details of feature, as well as a whole bunch of implementation notes.

Getting this ready to merge took around three weeks of really concerted work (almost every night!), but I’m super glad to finally have it done. Component dir namespaces represent another huge leap for dry-system. **With namespaces, dry-system can load and manage code in almost any conceivable structure.** With this change giving us support for “friendlier” source directory structures like the one we’ll use in Hanami, I hope it means that dry-system will also become as _approachable_ as it already is powerful.

## Figured out a strategy for upcoming Hanami alpha releases

A final highlight of the month was getting together for another in-person chat with Luca! (Can you believe we’ve only done this four or five times at most?) Among other things, we figured out a strategy for the next and subsequent Hanami 2.0.0.alpha releases.

Here’s the plan:

- As soon as the dry-system namespaces are released and the new slice lib paths configured in Hanami, we’ll ship alpha3. A code loading change is a big change and we want to get it into people’s hands for testing ASAP.
- Our focus will continue to be on stripping as much boilerplate as possible away from the generated application code, and now that I’m done with all the big efforts from the last month, my contributions here should be a lot more iterative
- Going forward, we’ll ship a new alpha release every month, collecting up all the changes from that month

So this means you should here about a new Hanami release by the time I’m writing my next set of notes here!

## Thank you to my sponsors ❤️

My work in Ruby OSS is kindly supported by my [GitHub sponsors](https://github.com/sponsors/timriley).

Thank you in particular to [Jason Charnes](https://github.com/jasoncharnes) for your unwavering support as my sole level 3 sponsor (it was great to chat to you this month as well!). Thanks also to [Sebastian Wilgosz](https://github.com/swilgosz) of [HanamiMastery](https://hanamimastery.com) for upgrading his sponsorship!

If you’d like to support my work in bringing Hanami 2 to life, [I’d love for you to join my sponsors too](https://github.com/sponsors/timriley).

See you all next month!

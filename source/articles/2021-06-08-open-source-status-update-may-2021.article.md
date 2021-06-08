---
title: Open source status update, May 2021
permalink: 2021/06/08/open-source-status-update-may-2021
published_at: 2021-06-08 23:55:00 +1000
---

Well didn't May go by quickly! Here’s what I got up to in OSS over the month.

For starters, do you remember the big [Hanami 2.0.0.alpha2 I mentioned last month](/writing/2021/05/10/open-source-status-update-march-april-2021/)? Yep, that happened. And it was a little cheeky of me to sneak it into my March/April update, because it happened into the first week of May!

So after a short while recuperating from that big push, there wasn't a whole lotta time left in the month! And apart from this, it was kind of a funny month, because it brought a different kind of work to the sort I’d been doing for a while.

## Welcoming Marc Busqué to the team!

The real highlight of the month was [Marc Busqué](https://github.com/waiting-for-dev) getting on board with Hanami development! Marc’s brought a huge amount of fresh energy to the team and got right into productive development work. It’s great be to working with you, Marc!

## Preparing dry-configurable’s API for 1.0

One of the first things Marc did was make some adjustments to dry-configurable’s `setting` API, to make it more consistent as one of the final steps before we can release 1.0 of that gem.

`setting` will now take only a single positional argument, for the name of the setting. Everything else must be provided via keyword arguments for improved consistency and clarity, plus easier wrapping by other gems. This means:

- The default value for the setting must be supplied as `default:` rather than a second positional argument
- A setting’s constructor (or ”processor”) can no longer be supplied as a block, instead it should be a proc object passed to `constructor:`

We merged these in [these](https://github.com/dry-rb/dry-configurable/pull/111) [PRs](https://github.com/dry-rb/dry-configurable/pull/112), which include a deprecation pathway, so the previous usage will (largely) continue to work. While we were in dry-configurable, I also [made a fix](https://github.com/dry-rb/dry-configurable/pull/113) for it to work with preexisting `#initialize` methods accepting keyword args when its module is included, as well as [removing implicit hash conversion](https://github.com/dry-rb/dry-configurable/pull/114) which can result in unexpected destructuring when passing a configurable object to a method accepting a keyword args splat.

These dry-configurable changes haven’t yet been released, but hopefully we can make it happen sometime in June. The reason is that they were in service of a couple of larger efforts, both of which are still in flight (read on below for more detail!).

In the meantime, after these API changes, I did a sweep of the dry-rb ecosystem to bring things up to date, which led to PRs in [dry-system](https://github.com/dry-rb/dry-system/pull/179), [dry-container](https://github.com/dry-rb/dry-container/pull/77), [dry-effects](https://github.com/dry-rb/dry-effects/pull/83), [dry-monitor](https://github.com/dry-rb/dry-monitor/pull/43), [dry-rails](https://github.com/dry-rb/dry-rails/pull/44), [dry-schema](https://github.com/dry-rb/dry-schema/pull/356), [dry-validation](https://github.com/dry-rb/dry-validation/pull/686), and [hanami-view](https://github.com/hanami/view/pull/190). Phew! It just goes to show how load-bearing this little gem is for our overall ecosystem (and how wide-ranging the impact of API changes can be). I haven’t merged these yet either, but will hope to do so in the next week or so, once we’ve ensured we have compatibility with both current and future dry-configurable APIs for the range of dry-rb gems that are past their respective 1.0 releases.

## Porting Hanami::Configuration to dry-configurable

One thing that led to a couple of those dry-configurable fixes was my work in [updating `Hanami::Configuration` to use dry-configurable](https://github.com/hanami/hanami/pull/1107). This class had gotten pretty sprawling with its manual handling of reading/writing a wide range setting values, which is squarely in dry-configurable’s wheelhouse, and the result is much tidier (and now consistent with how we’re handling configuration in both hanami-controller and hanami-view). This one again isn't quite ready to merge (are you sensing a theme?), but it’s probably just an hour away from being done. I’ll look forward to having this one ticked off!

## Updating Hanami’s application settings to use dry-configurable (and more)

Hanami’s application settings (the ones you define for yourself in `config/settings.rb`) have been very dry-configurable-_like_ since their inception, but backed by custom code instead. It’s been on my to-do list [for a long time](https://trello.com/c/cJEcVuU0/62-build-application-settings-on-top-of-dry-configurable) to switch this over to dry-configurable, but with Marc joining the team, we’ve finally got some traction here! You can [the original PR](https://github.com/hanami/hanami/pull/1105) and an [current, in-progress PR](https://github.com/hanami/hanami/pull/1110) as well.

This one was a lot of collaborative fun. Marc made the broad initial steps, I jumped in to poke around and explore the design possibilities, and then he took my direction and ran with it, adding some other nice improvements along the way, like introducing a ”settings store” abstraction, which in our default implementation will continue to rely on dotenv.

This one is _also_ close to being done. Watch this space (and all the other spaces I’ve mentioned so far, if you’re keen).

## Providing a default types module to application settings (or not), and probably turning the whole thing into a regular class

Marc pivoted quickly from the above work to another long-standing to-do of ours: [making a types module automatically available to the application settings](https://github.com/hanami/hanami/pull/1111). Having type-safe settings is one of the nicest features of the way we’re handling them, and I’d like this to be as smooth as possible for our users!

This turned out to be a bit of a rabbit hole, as evidenced by this [sprawling PR discussion](https://github.com/hanami/hanami/pull/1111#discussion_r639472752), but I think it’s led us to a good place.

Currently, the application settings must be defined in a block provided to the `Hanami::Application.settings`:

```ruby
Hanami.application.settings do
  setting :sentry_dsn
end
```

Due to the combination of Ruby’s use of the lexical scope for constant lookups within blocks and dry-types’ standard reliance upon types collections as modules, with custom types defined as constants, it was nigh on impossible to auto-generate and provide an ergonomic, idiomatic types module for use within a block like that (see the linked PR discussion for details).

So this led us to the decision to move the application settings definition to a good ol’ ordinary Ruby class:

```ruby
module MyApp
  class Settings < Hanami::Application::Settings
    setting :sentry_dsn
  end
end
```

This will still be looked up and loaded by the framework automatically, but because we’re using a regular class, we can rely on all the regular Ruby techniques for referring to a types module. This means we could choose to access a types module that the user has already created for themselves, e.g. `MyApp::Types`:

```ruby
require "my_app/types"

module MyApp
  class Settings < Hanami::Application::Settings
    setting :sentry_dsn, MyApp::Types::String
  end
end
```

Or even create our own localised types module right within the class:

```ruby
require "dry/types"

module MyApp
  Types = Dry.Types

  class Settings < Hanami::Application::Settings
    setting :sentry_dsn, Types::String
  end
end
```

This is much simpler and less likely to confuse! Better still, because we have a regular class at our disposal, users can now add their own custom behavior to their settings:

```ruby
require "dry/types"

module MyApp
  Types = Dry.Types

  class Settings < Hanami::Application::Settings
    setting :sentry_dsn, Types::String.optional

    def sentry_enabled?
      !sentry_dsn.nil?
    end
  end
end
```

So I think this is a positive direction to be heading in. Plus, it reinforces the Hanami philosophy of ”a place for everything and everything in it’s place,” with this settings class being a great exemplar of a single-responsibility class, even for something that’s a special part of the framework boot process.

## Plans for June

Well, I think that about brings you all up to speed for now. My plan for the rest of June is to make sure I can help merge all of those PRs! And then I’ll be getting back into Zeitwerk-land hand looking for ways to simplify the Ruby source file structures that we have inside our application and slice directories.

## Thank you to my sponsors (including NEW SPONSORS!!) ❤️

May turned out to be hugely encouraging month for my GitHub sponsorships!

Thank you to [Jason Charnes](https://github.com/jasoncharnes) for upgrading your sponsorship! And thank you to [Janko Marohnić](https://github.com/janko) and [Aldis Berjoza](https://github.com/graudeejs) for beginning new sponsorships! 🥰 Thanks also to [Sebastian Wilgosz](https://github.com/swilgosz) who began a periodic sponsorship based on a portion of his [Hanami Mastery](https://hanamimastery.com) project sponsorships.

Little things like this this really do mean a lot, so folks, thanks again! 🙏🏼

If you’d like to support my ongoing OSS work, I’d love it if you could [join my cadre of intelligent and very good looking sponsors on GitHub](https://github.com/sponsors/timriley). And as ever, thank you to my existing sponsors for your ongoing support!

See you next month!

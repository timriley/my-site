---
title: Open source status update, March and April 2021
permalink: 2021/05/10/open-source-status-update-march-april-2021
published_at: 2021-05-10 22:45:00 +1000
---

Hello again, open source friends. It’s been a little while, so today you get a double update for March and April, and what a couple of months they were!

For most of March I had a break from OSS, because we moved apartments! The move itself was a culmination of a multi-year purchase and saving process, so I definitely enjoyed the opportunity to savour the moment. We’re well settled now, and in matters relating to this here blog, I now have a dedicated room with a nice big desk (and new display!) from which to do all my computering, so I suppose you can all expect some more _expansive_ thoughts in the future.

As for April, it was momentous for several other reasons. Let’s run through them...

## Added system-wide defaults for dry-system component_dirs

Wrapping up [this pull request](https://github.com/dry-rb/dry-system/pull/162) was the first thing I did to get back into swing of things. I had taken care of most of it before the house move, but I needed to polish it a little before it was ready to merge.

With this now in place, it’s possible to configure settings in a dry-system container that apply to all of its subsequently added component dirs:

```ruby
class MyContainer < Dry::System::Container
  configure do |config|
    # ...

    # These can be configured within each component_dir, but you can now
    # provide defaults for all dirs here
    config.component_dirs.loader = MyCustomLoader
    config.component_dirs.default_namespace = "my_app"

    # These added component_dirs will have the above settings as defaults
    config.component_dirs.add "lib"

    config.component_dirs.add "another_dir" do |dir|
      # You can still override the defaults within any given dir
      dir.loader = AnotherLoader
    end
  end
end
```

Apart from wanting this just to ensure the new dry-system component_dirs feature felt fully rounded, I also felt it was important for dry-system’s autoloader support to be ergonomic, allowing it to become just a one or two-liner.

```ruby
# Configure autoloader support in one place, instead of once for every
# added component_dir
config.component_dirs.loader = Dry::System::Loader::Autoloading
config.component_dirs.add_to_load_path = false
```

The review for this PR raised an interesting nugget. The change resulted in two places with the exact same collection of settings defined:

- The top-level `config.component_dirs` (`Dry::System::Config::ComponentDirs`)
- The individual component dir configuration object yielded to each call of `config.component_dirs.add` (`Dry::System::Config::ComponentDir`)

To keep these in sync, I wanted to have the settings defined in one place, and copied over into the other. My initial implementation used some deep knowledge of dry-configurable internals:

```ruby
module Dry
  module System
    module Config
      class ComponentDirs
        # ...

        # Settings from ComponentDir can be configured here to apply all added dirs as
        # defaults
        @_settings = ComponentDir._settings.dup
```

In the review, [Piotr aked why I was using this ivar](https://github.com/dry-rb/dry-system/pull/162#discussion_r597007361), which led to a helpful discussion. I had used the ivar because it offered a one-liner to import a copy of the settings all at once, but in talking it through, I realised I’d been relying on private aspects of dry-configurable that I wouldn’t recommend to others. Despite both of these gems inhabiting the same dry-rb ecosystem, we should really be using public APIs like any other gem user. So this is really an opportunity for a public API to emerge and provide this same outcome, something like this:

```ruby
_settings.replace(ComponentDir._settings.dup)
```

Until then (see [this issue](https://github.com/dry-rb/dry-configurable/issues/109) if you want to help!), I’ve avoided the direct access of the ivar through this slightly wordier but just as effective approach:

```ruby
# Settings from ComponentDir are configured here as defaults for all added dirs
ComponentDir._settings.each do |setting|
  _settings << setting.dup
end
```

## Released dry-system 0.19.0

With that last PR merged, and the changelog prepared ([so big it needed its own PR!](https://github.com/dry-rb/dry-system/pull/161)), we were ready to release dry-system 0.19.0! This release was big enough that it merited [its own announcement post](https://dry-rb.org/news/2021/04/22/dry-system-0-19-released-with-zeitwerk-support-and-more-leading-the-way-for-hanami-2-0/). Check it out for the headline features that this release brings. For all the juicy details, you always [the](https://timriley.info/writing/2020/12/07/open-source-status-update-november-2020) [previous](https://timriley.info/writing/2021/01/06/open-source-status-update-december-2020) [four](https://timriley.info/writing/2021/02/01/open-source-status-update-january-2021) [months](https://timriley.info/writing/2021/03/09/open-source-status-update-february-2021/) of my open source status updates.

As part of preparing for the release, I also teed up a [dry-system 1.0 issues milestone](https://github.com/dry-rb/dry-system/milestone/1) on GitHub. Please check them out if you’d like to pitch in! Most of the issues are much more targeted than the sweeping refactors I did over the last while, so they should be approachable.

(Sidenote: I also prepared a [similar 1.0 issues milestone for dry-configurable](https://github.com/dry-rb/dry-configurable/milestone/1), the other key gem we’d like to bring to 1.0 sometime this year)

## Finished Hanami Zeitwerk integration

With the dry-system release done, I turned my attention back to Hanami, and quite promptly [finished the Zeitwerk integration](https://github.com/hanami/hanami/pull/1100). This turned out to be a breeze after all the foundational work on dry-system. Zeitwerk author and all around mensch Xavier ”fxn” Noria also took a look, and [this comment of his](https://github.com/hanami/hanami/pull/1100#issuecomment-819607632) left me chuffed:

> That is all? Man, I do not know the details but this patch tells me the work behind this integration is really good 💯.

Thank you for the encouragement, fxn 😊

As for how the integration works, there’s nothing really particular to dive into (unusual for me, I know!). It all... just works. There’s a new `config.autloader` setting on the Hanami application class that you can use to configure the Zeitwerk instance directly, or set to false or nil if you want to disable autloading. In most cases, though, you shouldn’t have to worry, everything will just work.

As part of testing this out, I ported one of my work’s Hanami 2.0 applications to the new Zeitwerk support, and in the process was able to remove more than 150 individual `require` lines from the app. This is going to make building Hanami apps a much nicer experience!

## Released Hanami 2.0.0.alpha2!

Finally, all of the ducks were in a row to cut the long-awaited next alpha release of Hanami 2.0.0. The team banded together to get all the final pieces sorted over a furious few days of activity, leading to the release and my [official announcement](https://hanamirb.org/blog/2021/05/04/announcing-hanami-200alpha2/) on 4th May (pushed at about 1am here in Canberra!).

Please go check out the announcement, I think it’s a great summary of everything we’ve been working towards for these last two years, and it will hopefully get you excited for what Hanami can offer the next generation of Ruby apps (apps of all kinds, too, because [as of this last-moment PR](https://github.com/hanami/hanami/pull/1102), we’re explicitly no longer a web-only framework).

As for my feelings about all of this, I think my tweet at the time says it all:

> Hanami 2.0.0.alpha2!
>
> I’m incredibly proud of what we’ve assembled so far, and can’t wait to take this vision to full fruition.
>
> In the meantime, what a milestone! I’m so happy 😭
>
> Thanks to @jodosha, @_solnic_ and the whole Hanami team for such a meaningful couple years of work.

If you’d like to kick the tyres on this new alpha release, go check out [the application template](https://github.com/hanami/hanami-2-application-template) that we’ve brought up to date and moved into the Hanami GitHub org.

## What’s next?

Our goal for the next alpha is to reduce the boilerplate from the app template as much as possible. Hop onto [this discussion thread](https://discourse.hanamirb.org/t/hanami-v2-0-0-alpha2-app-template-feedback/606/24) if you’d like to share your thoughts!

There’s a lot of further work to the framework internals I’d like to do (i.e. much of what’s on [the Trello board](https://trello.com/b/lFifnBti/hanami-20)), but having a spick and span template is a great crystalising goal for the next release, getting us as quickly as possible to our desired generated application, leaving time to work on the internals afterwards.

## Thank you to my sponsors ❤️

It’s been a huge effort to get to where we are today, and I certainly enjoyed reaching the milestone, but there’s still plenty left to do. I’d love it if you could [sponsor me on GitHub](https://github.com/sponsors/timriley) to help sustain my efforts over all the Hanami releases to come. And as ever, thank you to my existing sponsors for your ongoing support!

See you next month!

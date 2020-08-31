---
title: Open source status update, August 2020
permalink: 2020/08/31/open-source-status-update-august-2020
published_at: 2020-08-31 22:25:00 +1000
---

Oh, hello there, has it been another month already? After my [bumper month](https://timriley.info/writing/2020/08/03/open-source-status-update-july-2020) in July, August was a little more subdued (I had to devote more energy towards a work project), but I still managed to get a few nice things done.

## Hanami session configuration back in action

In a nice little surprise, I realised that all the building blocks had fallen into place for Hanami’s standard session configuration to begin working again.

So with a [couple of lines of config uncommented](https://github.com/jodosha/soundeck/pull/12), Luca’s “soundeck” demo app has working cookie sessions again. Anyone pulling from my [Hanami 2 application template](https://github.com/timriley/hanami-2-application-template) will see the same config enabled after [this commit](https://github.com/timriley/hanami-2-application-template/commit/65f51083ae74a961f89a718c4bbc7f1d540e02e9), too.

## Container auto-registration respects application inflector

Another small config-related changed I made was to [pass the Hanami 2 application inflector]((https://github.com/hanami/hanami/pull/1069) through to to the dry-system container handling component auto-registration.

With this in place, if you configure a custom inflection for your app, e.g.

```ruby
module MyApp
  class Application < Hanami::Application
    config.inflector do |inflections|
      inflections.acronym "NBA"
    end
  end
end
```

Then it will be respected when your components are auto-registerd, so you can use your custom inflections as part of your module namespacing.

With the setup above, if I had a file called `lib/my_app/nba_jam/cheat_codes.rb`, the container would rightly expect it to define `MyApp::NBAJam::CheatCodes`.

I’m delighed to see this in place. Having to deal with awkward namespaces (e.g. `SomeApi` instead of `SomeAPI`) purely because the framework wasn’t up to the task of handling it has long been an annoyance to me (these details _matter!_), and I’m really glad that Hanami 2 will make this a piece of cake.

This outcome is also a testament to the design approach we’ve taken for all the underpinning dry-rb gems. By ensuring important elements like an inflector were represented by a dedicated abstraction - and a configurable one at that - it was so easy for Hanami to provide its own inflector and see it used wherever necessary.

## Customisable standard application components

Every Hanami 2 application will come with a few standard components, like a logger, inflector, and your settings. These are made available as registrations in your application container, e.g. `Hanami.application["logger"]`, to make them easy to auto-inject into your other application components as required.

While it was my intention for these standard components to be replaceable by your own custom versions, what we learnt this month is that this was practically impossible! There was just no way to register your own replacements early enough for them to be seen during the application boot process.

After spending a morning trying to get this to work, I decided that this situation was in fact pointing to a missing feature in dry-system. So I went ahead and added [support for multiple boot file directories](https://github.com/dry-rb/dry-system/pull/151) in dry-system. Now you can configure an array of directories on this new `bootable_dirs` setting:

```ruby
class MyContainer < Dry::System::Container
  config.bootable_dirs = [
    "config/boot/custom_components",
    "config/boot/standard_components"
  ]
end
```

When the container locates a bootable component, it will work with these `bootable_dirs` just like you’d expect your shell to work with its `$PATH`: it will search the directories, in order, and the first found instance of your component will be used.

With this in place, I [updated Hanami to to configure its own bootable_dirs](https://github.com/hanami/hanami/pull/1070) and use its own directory for defining its standard components. The default directory is secondary to the directory specified for the application’s own bootable components, so this means if you want to replace Hanami’s standard `logger`, you can just create a `config/boot/logger.rb` and you’ll be golden!

## Started rationalising flash

Last month when I was digging into some session-related details of the framework, I realised that the `flash` we inherited from Hanami 1 was pretty hard to work with. It didn’t seem to behave in the same way we expect a flash to work, e.g. to automatically preserve added messages and make them available to the next request. The code was also too complex. This is a solved problem, so I looked around and started [rationalising the Hanami 2 flash system](https://github.com/hanami/controller/pull/326) based on code from Roda’s flash plugin. I haven’t had the chance to finish this yet, but it’ll be first cab off the rank in September.

## Plans for September

With a concerted effort, I think I could make September the month I knock off all my remaining tasks for a 2.0.0.alpha2 release. It’s been tantalisingly close for a while, but I think it could really happen!

Time to get stuck into it.

## 🙌🏼 Thanks to my sponsors!

Lastly, my continued thanks to my little posse of GitHub sponsors for your continued support, especially [Benjamin Klotz](https://github.com/tak1n).

I’d really love for you to join the gang. If you care about a healthy, diverse future for Ruby application developers, please consider [sponsoring my open source work](https://github.com/sponsors/timriley)!

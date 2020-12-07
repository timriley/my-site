---
title: Open source status update, November 2020
permalink: 2020/12/07/open-source-status-update-november-2020
published_at: 2020-12-07 21:50:00 +1100
---

Hello again, dear OSS enthusiasts. November was quite a fun month for me. Not only did I merge all the PRs I outlined in [October’s status update](/2020/11/03/open-source-status-update-october-2020), I also got to begin work on an area I’d been dreaming about for months: integrating Hanami/dry-system with Zeitwerk!

## Added an autoloading loader to dry-system

[Zeitwerk](http://github.com/fxn/zeitwerk) is a configurable autoloader for Ruby applications and gems. The “auto” in autoloader means that, once configured, you should never have to manually `require` before referring to the classes defined in the directories managed by Zeitwerk.

dry-system, on the other hand, was requiring literally every file it encountered, by design! The challenge here was to allow it to work with or without an auto-loader, making either mode a configurable option, ideally without major disruption to the library.

Fortunately, many of the core `Dry::System::Container` behaviours are already separate into individually configurable components, and in the end, all we needed was a new `Loader` subclass implementing a 2-line method:

```ruby
module Dry
  module System
    class Loader
      # Component loader for autoloading-enabled applications
      #
      # This behaves like the default loader, except instead of requiring the given path,
      # it loads the respective constant, allowing the autoloader to load the
      # corresponding file per its own configuration.
      #
      # @see Loader
      # @api public
      class Autoloading < Loader
        def require!
          constant
          self
        end
      end
    end
  end
end
```

This can be enabled for your container like so:

```ruby
require "dry/system/loader/autoloading"

class MyContainer < Dry::System::Container
  configure do |config|
    config.loader = Dry::System::Loader::Autoloading
    # ...
  end
end
```

Truth is, it did take a fair bit of doing to arrive at this simple outcome. [Check out the pull request](https://github.com/dry-rb/dry-system/pull/153) for more detail. The biggest underlying change was moving the responsibility for requiring files out of `Container` itself and into the `Loader` (which is called via each `Component` in the container). While I was in there, I took the chance to tweak a few other things too:

- Clarified the `Container.load_paths!` method by renaming it to `add_to_load_path!` (since it is modifying Ruby’s `$LOAD_PATH`)
- Stopped automatically adding the `system_dir` to the load path, since with Zeitwerk support, it’s now reasonable to run dry-system without _any_ of its managed directories being on the load path
- Added a new `component_dirs` setting, defaulting to `["lib"]`, which is used to verify whether a given component is ”local” to the container. This check was previously done using the directories previously passed to `load_paths!`, which we can’t rely upon now that we’re supporting autoloaders
- Added a new `add_component_dirs_to_load_path` setting, defaulting to true, which will automatically add the configured `component_dirs` to the load path in an after-configure hook. This will help ease the transition from the previous behaviour, and make dry-system still work nicely when not using an autoloader

With all of this in place, a full working example with Zeitwerk looks like this. First, the container:

```ruby
require "dry/system/container"
require "dry/system/loader/autoloading"

module Test
  class Container < Dry::System::Container
    config.root = Pathname(__dir__).join("..").realpath
    config.add_component_dirs_to_load_path = false
    config.loader = Dry::System::Loader::Autoloading
    config.default_namespace = "test"
  end
end
```

Then Zeitwerk setup:

```ruby
loader = Zeitwerk::Loader.new
loader.push_dir Test::Container.config.root.join("lib").realpath
loader.setup
```

Then, given a component "foo_builder", at lib/test/foo_builder.rb:

```ruby
module Test
  class FooBuilder
    def call
      # We can now referencing this constant without a require!
      Entities::Foo.new
    end
  end
end
```

With tihs in place, we can resolve `Test::Container["foo_builder"]`, receive an instance of `Test::FooBuilder` as expected, then `.call` it to receive our instance `Test::Foo`. Tada!

I’m very happy with how all this came together.

## Next steps with dry-system

Apart from cracking the Zeitwerk nut, this project also gave me the chance to dive into the guts of dry-system after quite a while. There’s quite a bit of tidying up I’d still like to do, which is my plan for the next month or so. I plan to:

- Make it possible to configure all aspects of each component_dir via a single block passed to the container’s `config`
- Remove the `default_namespace` top-level container setting (since this will now be configured per-component_dir)
- Remove the `.auto_register!` method, since our component-loading behaviour requires component dirs to be configured, and this method bypasses that step (until now, it’s only really worked by happenstance)
- Make Zeitwork usable without additional config by providing a plugin that can be activated by a simple `use :zeitwerk`

Once these are done, I’ll hop up into the Hanami framework layer and get to work on passing the necessary configuration through to its own dry-system container so that it can also work with Zeitwerk out of the box.

## Hanami core team meeting

This month I also had the (rare!) pleasure of catching up with Luca and Piotr in person to discuss our next steps for Hanami 2 development. [Read my notes](https://discourse.hanamirb.org/t/hanami-2-0-core-team-discussion-25-26-november-2020/580) to learn more. If you’re at all interested in Hanami development (and if you’ve reached this point in my 9th straight monthly update, I assume you are), then this is well worth a read!

Of particular relevance to the topics above, we’ve decided to defer the next Hanami 2 alpha release until the Zeitwerk integration is in place. This will ensure we have a smooth transition across releases in terms of code loading behaviour (if we released sooner, we’d need to document a particular set of rules for alpha2 but then half of those out the window for alpha3, which is just too disruptive).

## Thank you to my sponsors!

After all this time, I’m still so appreciative of my tiny band of GitHub sponsors. This stuff is hard work, so [I’d really appreciate your support](https://github.com/sponsors/timriley).

See you all again next month, by which point we’ll all have a Ruby 3.0 release!

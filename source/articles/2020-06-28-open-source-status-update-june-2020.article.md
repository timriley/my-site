---
title: Open source status update, June 2020
permalink: 2020/06/28/open-source-status-update-june-2020
published_at: 2020-06-28 21:05:00 +1000
---

After [last month’s](https://timriley.info/writing/2020/06/01/open-source-status-update-may-2020/) breakthroughs with the Hanami view rendering, I was looking forward to “rolling downhill... and collecting a bunch of quick wins.” I was unfortunately a little over-optimistic there, but in June I did manage to get a few nice things done. Let’s take a look.

## Hanami application actions with deeper class hierarchies

To start off the month, I upgraded one of my work applications to use last month’s `Hanami::Action` improvements. And it turns out, this revealed a shortcoming! In this application, we have multiple tiers of “base actions”, with one for the whole application, and then one for each slice:

```ruby
module MyApp
  # Application base action
  class Action < Hanami::Action
  end
end

module Main
  # Slice base action, inheriting from application base
  class Action < MyApp::Action
  end
end
```

My first pass at the “application action” work didn’t account for this, and it resulted in the slice’s base action (`Main::Action` in the example above) not receiving the proper application-specific behaviour.

This is a great example of how important it is to “dogfood” in-development frameworks and libraries like this, and it’s why I made a conscious decision to be both a ”super user” _and_ core developer of all the tools we’ve been developing in dry-rb, rom-rb, and now Hanami. The feedback you get from _really_ using them is invaluable, and the ensuring feedback cycle means that we can fold in related improvements really quickly.

In this case, I needed to make [this adjustment to hanami-controller](https://github.com/hanami/controller/pull/316) and [this one over here to hanami](https://github.com/hanami/hanami/pull/1058). And with that, this application can now continue to run on the cutting edge :)

## Class-configurable Hanami actions

With those changes done, I turned my attention to my major focus for the month. I adjusted `Hanami::Action` so that it [is now class-configurable](https://github.com/hanami/controller/pull/318), just like `Hanami::View`.

Here’s how you can now configure an action:

```ruby
class MyAction < Hanami::Action
  config.default_response_format = :json
end
```

With this in place, when you instantiate the action, the configuration from its class will automatically apply:

```ruby
action = MyAction.new
action.(rack_env) # Default response format will be JSON
```

What’s useful about this approach is that the configuration is inherited, which creates the opportunity for a base action to hold common configuration for all its subclasses:

```ruby
class BaseAction < Hanami::Action
  config.default_response_format = :json
end

class AnotherAction < BaseAction
end

action = AnotherAction.new
action.(rack_env) # Default response format will be JSON
```

If [you’ve been following along](https://timriley.info/writing/2020/06/01/open-source-status-update-may-2020/) with my recent updates, you’ll see where this is going. With this inheritable class-based configuration in place, we’ll be able to leverage the "Application Action" behavior that is seamlessly added to `Hanami::Action` subclasses when they’re defined within a full Hanami application, and in this case, apply all the necessary action configuration from the framework.

That’s the plan for July. We’ll see how far we can go. There’s still a few things to work out, like how we can allow any `Hanami::Action` setting to be configured for the whole application, without having to duplicate every setting into the application-level `Hanami::Configuration` and the related classes.

The [pull request for this work](https://github.com/hanami/controller/pull/318) is now done and should hopefully merge soon. One thing I was quite happy with was how I managed to make the switch from configuration being applied as an externally injected object to the class-based configuration without having to upend the entire test suite. I made this possible by keeping the injected configuration object, and making the class-based configuration its default parameter:

```ruby
module Hanami
  class Action
    module StandaloneAction
      def new(configuration: self.configuration.dup, **args)
        allocate.tap do |obj|
          obj.instance_variable_set(:@configuration, configuration.finalize!)

          # Other details snipped out... let me know if you'd like to hear the
          # story behind ths whole new/allocate dance :)
        end
      end
    end
  end
end
```

Not only did this allow me to sidestep an overhaul of the test suite, but it also retained a wonderful flexibility: if for any reason you need a particular action _instance_ to behave differently from its class’ default configuration, you can still pass in your own configuration object. I call that a win!

## An aside on component ”fit” within dry-system and Hanami 2

A big theme of my work so far with Hanami 2 has been making Hanami’s own components fit just right with dry-system, which manages the application and slice containers. With dry-system as it currently stands, this means:

**Each source file should be entirely self-contained.** A single `require` for that file should bring in enough of the outside world for the class defined therein to be fully functional.

**Each class should work with a simple `.new`.** Instead of requiring the container’s coponent loader to somehow satisfy a whole range of various initializers, each class should provide sensible defaults, such that a simple `.new` is enough to get a working instance. This means a couple of things:

Firstly, all injected dependencies should have working defaults. This is how [dry-auto_inject](http://dry-rb.org/gems/dry-auto_inject/0.6/how-does-it-work/) (i.e. the `include Deps["some_dep"]` we’ll see inside Hanami application components) works: the specified dependencies are resolved from the container and effectively become the default arguments for the class’ `#initialize` parameters.

Next, any standard configuration should be already in place, without any additional argument passing. This is exactly why we moved the `Hanami::Action` config onto the class, so that `SomeAction.new` can already have the configuration it needs.

If you’re already working with dry-system, or designing components to fit well with dry-system or eventually Hanami 2, these characteristics would be good to keep in mind.

## dry-configurable settings eagerly evaluate their value

To preserve the behavior of various Hanami action settings, I needed to make a [small change to dry-configurable](https://github.com/dry-rb/dry-configurable/pull/95).

It’s been a few months now since Piotr [entirely rewrote dry-configurable](https://github.com/dry-rb/dry-configurable/pull/78), and in my view, the effort has been a smashing success: I think the code is far easier to understand and work with. Thanks Piotr!

Since the rewrite, we’ve had to make a few little adjustments as we’ve discovered additional use cases out in the wild, and this was one of them. We needed to make it a setting’s constructor would run immediately when provided a value, ensure we could provide immediate feedback in the case of an invalid value.

So given this setting:

```ruby
setting :default_response_format do |format|
  Utils::Kernel.Symbol(format) unless format.nil?
end
```

We can now expect an error to be raised if the provided value cannot be symbolized:

```ruby
# Will raise an exception!
config.default_response_format = 123
```

Thanks to the well-factored code of the rewrite, the [required change](https://github.com/dry-rb/dry-configurable/pull/95) was very small, and now we have the best of both worlds when it comes to dry-configurable evaluating its settings: when a value is provided, the value will run through the setting’s constructor immediately, which provides the early feedback we want in situations like the above. When a value is not yet provided, the constructor doesn’t run, waiting until a value is later provided or until the whole configuration is finalized, which is useful behavior for when a configuration object takes some time to be fully prepared.

## Thanks to my sponsors 🙌🏼

As of this week, I now have five GitHub sponsors! Thank you, sponsors: I’m ever grateful for all your support.

If you’d like to pitch in and support my open source work, you can [sponsor me here](https://github.com/sponsors/timriley).

Thanks especially to [Benjamin Klotz](https://github.com/tak1n) for your continued support.

## Thanks for reading!

The winter solstice has now passed here in Australia, so while the nights are getting shorter, I’ll still be pushing hard through the evenings to try and reach this critical ”minimum viable actions/views” milestone for Hanami 2. See you all at the end of July! 👋🏼

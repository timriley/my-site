---
title: Open source status update, January 2021
permalink: 2021/02/01/open-source-status-update-january-2021
published_at: 2021-02-01 22:50:00 +1100
---

I had a very satisfying January in Ruby OSS work! This month was all about overhauling the dry-system internals. That I’ve written about this in both [November](https://timriley.info/writing/2020/12/07/open-source-status-update-november-2020/) and [December](https://timriley.info/writing/2021/01/06/open-source-status-update-december-2020/) just goes to show (a) how long things actually take when you’re doing this on the side (and I’m not lazing about, I spend at least 3 nights a week working on OSS), and (b) just how much there was going on inside of dry-system.

So to set the scene, here’s the circuitous path I took in adding [rich component directory configuration](https://github.com/dry-rb/dry-system/pull/155) to dry-system. This is the commit history before I tidied it:

```text
2020-11-24 Add some early WIP
2020-11-25 Accept pre-configured component dirs
2020-11-25 Configure with block as part of initialize
2020-11-25 Provide path when initializing ComponentDir
2020-12-01 Add Rubocop rule
2020-12-01 Allow ComponentDirs to be cloned
2020-12-01 Clarify names
2020-12-01 Fix wording of spec
2020-12-01 Fixup naming
2020-12-01 Start getting component_dirs in place
2020-12-01 Update auto-registrar to use component_dirs
2020-12-01 Update specs for component_dirs
2020-12-03 Total messy WIP
2020-12-23 Get some WIP laid down on Booter#find_component
2020-12-23 Remove some WIP comments
2020-12-23 Tidy
2020-12-23 Update file_exists? behavior
2021-01-04 Add error
2021-01-04 Get things closer
2021-01-04 Provide custom dry-configurable cloneable value
2021-01-04 Remove unused settings
2021-01-04 Use a Concurrent::Map
2021-01-05 Add FIXME about avoiding config.default_namespace
2021-01-05 Introduce ComponentDir with behaviour separate to config
2021-01-05 Remove note, now that Loader#call is doing a require!, we’re fine
2021-01-05 Remove top-level default_namespace config
2021-01-05 Tidy Component
2021-01-05 Update FIXME
2021-01-11 Add docs
2021-01-11 Add docs for file exists
2021-01-11 Document Booter#boot_files method as public
2021-01-11 Don’t preserve file_path when namespacing component
2021-01-11 Expand docs
2021-01-11 Fix
2021-01-11 Flesh out ComponentDir
2021-01-11 Remove TODO
2021-01-11 Remove unused method
2021-01-11 Rip out the Component cache
2021-01-11 Stop setting file attribute on Component
2021-01-11 Tidy up Component file_path attr
2021-01-11 Tweak names
2021-01-11 Use a faster way of building namespaces path
2021-01-12 Use cloneable option for component_dirs setting
2021-01-14 Do not load components with auto_register: false
2021-01-14 Initialize components directly from AutoRegistrar
2021-01-14 Remove stale comment
2021-01-14 Remove unneeded requiring of component
2021-01-14 Scan file for magic comment options when locating
2021-01-14 Use dry-configurable master
2021-01-15 Add spec (and adjust approach) for skipping lazy loading of auto-register-disabled components
2021-01-15 Add unit tests for ComponentDir
2021-01-15 Tidy AutoRegistrar
2021-01-16 Add extra attributes to component equalizer
2021-01-16 Add unit tests for Component.locate
2021-01-16 Make load_component easier to understand
2021-01-18 Use base Dry::Container missing component error
```

Yep. 56 commits and just under two calendar months of work, with the break in early December being my sting doing Advent of Code. Luckily, that "Total messy WIP" left me with a passing test suite after some heavy refactoring, but it did take a day or two to figure out just what I was doing again! Note to self: leave more notes to self.

## Rich, independent component directory configuration for dry-system

The (tidied) [pull request for this change](https://github.com/dry-rb/dry-system/pull/155) has a lengthy description, focused on implementation. If you’re interested in the details, please have a read!

Here’s the long and the short of it, though: previously, dry-system would let you configure a top-level `auto_register` setting, which would contain an array of string paths within the container root, which the system would use to populate the container. This would often be used alongside another top-level setting, `default_namespace`, which would strip away a common namespace prefix from the container identifiers, and a call to `.load_paths!` for each directory being auto-registered, to ensure the sources files within those directories could be properly required:

```ruby
class MyApp::Container < Dry::System::Container
  configure do |config|
    config.root = __dir__
    config.auto_register = ["lib"]
    config.default_namespace = "my_app"
  end

  load_paths! "lib"
end
```

Those are three different things you would need to know how to use _just right_ in order to set up a properly working dry-system container. Luckily, most users could copy a working example and then tweak from there. Also, users would typically only set up a single directory for auto-registration, so those three elements would only need to apply to that one directory only. If you ever tried to do more (for example, now that we have an autoloading loader, configure one directory to use the autoloder and another not to), things would fall apart.

Things brings us to the rich component directory configuration, and indeed the introduction of a ”Component Directory” as a first-class concept within dry-system. Here’s how a container setup would look now:

```ruby
class MyApp::Container < Dry::System::Container
  configure do |config|
    config.root = __dir__

    config.component_dirs.add "lib" do |dir|
      dir.auto_register = proc do |component|
        !component.path.match?(%r{/entities/})
      end
      dir.add_to_load_path = false
      dir.loader = Dry::System::Loader::Autoloading
      dir.default_namespace = "my_app"

      # Also available, `dir.memoize`, accepting a boolean or proc
    end
  end
end
```

Now the behavior for handling a given component directory can be configured on that directory and that directory alone. In the above example, another component diretory could be added with diametrically opposed settings to the first, and everything will still be dandy!

As you can also see, the degree of configurability has also increased greatly over the released versions of dry-system. Now you can opt into or out of auto-registration for _specific_ components by passing a proc to the `auto_register` setting. Memoization of registered components can also be enabled, disabled, or configured specifically with the `memoize` setting.

(While you’re here, also check out the dry-configurable change I made to allow [cloneable setting values](https://github.com/dry-rb/dry-configurable/pull/102), without which we couldn’t have provided this rich nested API for configuring particular directories)

## Consistent component loading behavior, including magic comments!

With the changes above in place, I could remove the `.auto_register!` container class method ([done in this pull request](https://github.com/dry-rb/dry-system/pull/157), also with its own lengthy description), which leaves the `component_dirs` setting as the _only_ way to tell dry-system how to load components from source files.

Not only does this make for an easier to configure container, it also supports a more consistent component loading experience! Now, every configurable aspect of component loading is respected in the container’s two methods of auto-registering components: either via finalizing the container (which loads everything up front and freezes the container) or via lazy-loading (which loads components just in time, and is useful for keeping container load time down when running unit tests or using an interactive console, among other things).

It also means that magic comments within source files are respected in all cases, where previously, only a subset of comments were considered, and only when finalizing a container, not during lazy-loading.

This means you can now have a source file like this:

```ruby
# auto_register: false

class MyEntity
end
```

And `MyEntity` will _never_ find its way into your container.

Or you can have a source file like this:

```ruby
# memoize: true

class MySpecialComponent
end
```

And when the component is registered, it will be memoized automatically.

Magic comments for dry-system are great, I use them all the time, and now they’re even more powerful!

## More consistent, easier to understand dry-system internals

I’ve worked in the dry-system codebase quite regularly over the last few years, and certain parts have always felt a little too complicated, often leaving me confused, or at least afraid to change them. This is no discredit everyone who worked on dry-system previously! Its an amazing innovation, and its features just grew organically over the years to make it the capable, powerful system it is today!

However, given I was going to be deep in the code again to implement the changes I wanted, I took the chance to refactor as much as I could. And I’m just delighted in the outcome! For example, check out how [`.load_component`](https://github.com/dry-rb/dry-system/blob/4c9c28c07f4369061dd6fc3d7f3263a67d7a8ae4/lib/dry/system/container.rb#L623-L643) and [`.load_local_component`](https://github.com/dry-rb/dry-system/blob/4c9c28c07f4369061dd6fc3d7f3263a67d7a8ae4/lib/dry/system/container.rb#L673-L689) (which are used for lazy-loading components) used to look:

```ruby
def load_component(key, &block)
  return self if registered?(key)

  component(key).tap do |component|
    if component.bootable?
      booter.start(component)
    else
      root_key = component.root_key

      if (root_bootable = component(root_key)).bootable?
        booter.start(root_bootable)
      elsif importer.key?(root_key)
        load_imported_component(component.namespaced(root_key))
      end

      load_local_component(component, &block) unless registered?(key)
    end
  end

  self
end

def load_local_component(component, default_namespace_fallback = false, &block)
  if booter.bootable?(component) || component.file_exists?(component_paths)
    booter.boot_dependency(component) unless finalized?

    require_component(component) do
      register(component.identifier) { component.instance }
    end
  elsif !default_namespace_fallback
    load_local_component(component.prepend(config.default_namespace), true, &block)
  elsif manual_registrar.file_exists?(component)
    manual_registrar.(component)
  elsif block_given?
    yield
  else
    raise ComponentLoadError, component
  end
end
```

And here’s [how they look now](https://github.com/dry-rb/dry-system/pull/155/commits/c72545ab37c1915aaa98764b7c90a7c27530b69a):

```ruby
def load_component(key)
  return self if registered?(key)

  component = component(key)

  if component.bootable?
    booter.start(component)
    return self
  end

  booter.boot_dependency(component)
  return self if registered?(key)

  if component.file_exists?
    load_local_component(component)
  elsif manual_registrar.file_exists?(component)
    manual_registrar.(component)
  elsif importer.key?(component.root_key)
    load_imported_component(component.namespaced(component.root_key))
  end

  self
end

def load_local_component(component)
  if component.auto_register?
    register(component.identifier, memoize: component.memoize?) { component.instance }
  end
end
```

Just look at that improvement! We went from a pair of methods that _always_ confused me (with their mixed responsibilities, multiple conditionals and levels of nesting) to a simple top-to-bottom flow in `.load_component`, and `.load_local_component` reduced to a simple 3-liner with just a single job.

Weeks later, I’m still marvelling at this. I think it’s one of the best refactorings I’ve ever done.

These improvements didn’t come on their own. As you might notice there, `component` is carrying a lot more of its own weight. This includes a new set of methods for finding and loading components from within component directories (namely `Dry::System::Component.locate` and `.new_from_component_dir`), and indeed the new `Dry::System::ComponentDir` abstraction itself, which together provide the consistent component loading behavior I described above.

## Dry::System::Loader converted to a class interface

One thing I noticed during the work on component loading is that a new `Dry::System::Loader` would be instantiated for every component, even through it carried no other state apart from the component itself, so I [turned it into a stateless, class-level interface](https://github.com/dry-rb/dry-system/pull/157/commits/85a2d9e39bc32b60ba4d1f6c931578b972c4f02f), and hey presto, we save an object allocation for every component we load.

This is a breaking change, but hey, so is everything else I’ve described so far! I figure this is the right time to sort these things out before we look to a dry-system 1.0 release sometime in the next few months (which is seeming much more attractive after this round of work!).

## I appreciated being appreciated 🥺

Given how significant my plans were for all these changes, I made sure to keep [Piotr](https://solnic.codes) and the other maintainers in the loop over those couple of months of work.

Then, when Piotr reviewed my first finished pull request for this work, he left me [the most amazing comment](https://github.com/dry-rb/dry-system/pull/155#pullrequestreview-573005098). I want to repeat it here in full (that is, to take it [straight in the pool room](https://youtu.be/J5KbMolsUPA?t=34)):

> @timriley thanks for this very detailed description, it made much more sense for me to carefully read it and understand the changes rather than to examine the diff. Since what you did here, conceptually, makes perfect sense to me, AND it resulted in simplified implementation which at the same time makes the library much more powerful, I have nothing to complain about 😆 FWIW - I’ve read the diff and nothing stands out as potentially problematic. I reckon seeing it work in real-world apps will be a much better verification process, it’s a huge change after all.
>
> This is clearly a huge milestone and I honestly didn’t expect that the lib will be so greatly improved prior 1.0.0, so thank you for this huge effort, really ❤️
>
> One thing I’ll probably experiment with would be a backward-compatibility shim so that previous methods (that you removed) could still work. This should make it simpler to upgrade, but please tell me if this is a stupid idea.
>
> I will also upgrade dry-rails!
>
> Tim, seriously, again, this is an epic refactoring, I’m so happy. You’re taking dry-system to the next level. Thank you! 🚀 🎉 🙇🏻

After a full year of labouring away at this stuff, often to uncertain or, frankly, even unknowable ends, a comment like this has just given me the fuel to go another year more. Thank you, Piotr ♥️

**If there’s someone out there in OSS land whose work you appreciate, please take the time to tell them! It might mean more than you think.**

## Next steps with dry-system, Hanami, and Zeitwerk, and the alpha2 release

Now that the bulk of the dry-system work is done, here’s what I’m looking to get done next:

- Run some final tests using the dry-system branches within a real application
- Work with Piotr to coordinate related changes to dry-rails (which configures dry-system auto-registration)
- Updating Hanami to configure `component_dirs` within its own dry-system containers
- Then work out how to enable Zeitwork within Hanami and use the autoloading loader for its component directories by default, while still providing a clean way for application authors to opt out if they’d rather use traditional `require`-based code loading

I expect this will take most of February. Once this is done, we’ll finally be in the clear for a 2.0.0.alpha2 release of Hanami. Focusing on Zeitwerk and dry-system has pushed it back a couple of months, but I hope everyone will agree it was worth the wait!

## Thank you to my sponsors! 🙌🏼

Thanks to my GitHub sponsorts for your continuing support! If you’re reading this and would like to support my work in making Hanami 2.0 a reality, [I’d really appreciate your support](https://github.com/sponsors/timriley).

See you all next month!

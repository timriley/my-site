---
title: Open source status update, June 2021
permalink: 2021/07/11/open-source-status-update-june-2021
published_at: 2021-07-11 23:00:00 +1000
---

June felt like a little bit of a down month for me in OSS. For various reasons, I struggled to find decent blocks of time to make headway into all the loops I opened [back in May](/writing/2021/06/08/open-source-status-update-may-2021/). But in the end, I found a way to nudge some other important things forward!

## Beginning work on first-class namespace support for dry-system

Rather than push against the grain at a low ebb, I used what time I had in June to do some more nourishing ”fun” work, to get back into dry-system again and prepare the way for Hanami to have a flatter Ruby source file directory structure.

What we want is instead of `Main::HelloWorld` being defined in this file:

```
slices/main/lib/main/hello_world.rb
```

We want too remove that second redundant `main/` and have the file like so:

```
slices/main/lib/hello_world.rb
```

The idea here is to make the deeper hierarchies imposed by each namespaced Hanami slice a little less ”in your face,” and in doing so, make this whole framework just that much more approachable to a wider range of users.

[Zeitwerk](https://github.com/fxn/zeitwerk) already supports part of what we’d like to do here, through its support for [custom root namespaces](https://github.com/fxn/zeitwerk#custom-root-namespaces). Using this, we’d set up that elided source directory from above like this:

```ruby
loader = Zeitwerk::Loader.new
loader.push_dir "slices/main/lib", namespace: Main
```

However, for Hanami to use both Zeitwerk and dry-system together, more work is required. This is also made more challenging by the fact that dry-system needs to map names in two directions, from identifier to source file/constant (when lazy loading a single registration) and from source file to constant/identifier (when finalizing a container and crawling its managed directories for all source files), whereas Zeitwerk only needs to go in one direction, from constant to source file.

Until now, the only support dry-system has had for namespacing was its `default_namespace` setting on its component dirs. This worked very simplistically. Given a setting like the following:

```ruby
config.component_dirs.add "lib" do |dir|
  dir.default_namespace = "main"
end
```

If dry-system encountered a file like `main/hello_world.rb` inside that component dir, then it would strip off the leading `"main"` when forming its identifier, leaving it as `"hello_world"`. And when the container is lazy loading, it would first try prepending the `default_namespace` to find a file for a given identifier, before falling back to searching without the namespace.

This has worked fine for most use cases, but it won’t cut it for our Hanami plans.

So to address this, **I’m adding namespaces as a first-class concept to dry-system component dirs**. A replacement for the `default_namespace` config above would look like this:

```ruby
config.component_dirs.add "lib" do |dir|
  dir.namespaces.add "main"
end
```

To add a namespace, we specify the path within the component dir, along with an `identifier` and/or `const` to use within that path.

The example above is actually shorthand for the following:

```ruby
config.component_dirs.add "lib" do |dir|
  dir.namespaces.add "main", identifier: nil, const: "main"
end
```

Playing this out, this means: ”within the `main/` subdirectory of this component dir, don’t add anything to the beginning of the component’s identifiers, but expect them all to be within the `Main` object namespace.”

Following on from this, we should be able to configure some wildly divergent component loading rules. For example:

```ruby
dir.namespaces.add "main", identifier: "bits_and_bobs", const: "stuff_and_things"
```

With this config, we’d expect files in `main/` to define classes inside the `StuffAndThings` namespace, and have their identifiers all prefixed by `"bits_and_bobs"`.

As you might’ve noticed, the `namespaces.add` method means we can configure multiple namespaces:

```ruby
dir.namespaces.add "main"
dir.namespaces.root # special method for component dir root
dir.namespaces.add "admin"
```

Namespaces will be referenced in order when resolving components or loading files into the container, too, which improves what was otherwise a poorly defined part of dry-system’s behaviour. So with the configuration above, if you had a `main/component.rb` _and_ an `admin/component.rb`, the file inside `main/` would be favoured in all cases and would always appear in the container as the `"component"` registration, because its namespace was added first.

So, after all of this, we now have the necessary tools to support our elided directory structure from the top, which would look something like this:

```ruby
config.component_dirs.add "lib" do |dir|
  dir.namespaces.root const: "main"
end
```

I have a [messy work in progress PR](https://github.com/dry-rb/dry-system/pull/181) underway to support all of this, so feel free to check it out if you’d like to see the code equivalent of the under construction gif. This will end up being _yet another_ fairly big overhaul of dry-system internals, so I think it’ll probably take me the better part of July to get it finished. Iterating over the namespaces as part of component loading will also have some performance implications, so I’ll want to do some benchmarking of that process too.

That said, I’m really excited to find another opportunity to make dry-system more powerful and better structured than before! And of course, to then employ that to create a nicer experience for future Hanami users :)

## Thank you to my sponsors (new and old!) ❤️

A huge thank you to [Bohdan V.](https://github.com/g3d) for joining my GitHub sponsors during June!

Thanks also to [Jason Charnes](https://github.com/jasoncharnes) and the rest of my sponsors for your continued support! If you’d like to join them in supporting my work, you too can [sponsor me on GitHub](https://github.com/sponsors/timriley).

See you all next month, folks!

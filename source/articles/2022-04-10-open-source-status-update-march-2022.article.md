---
title: Open source status update, March 2022
permalink: 2022/04/10/open-source-status-update-march-2022
published_at: 2022-04-10 22:30 +1000
---

My OSS work in March was a bit of a grind, but I made progress nonetheless. I worked mostly on relocating and refactoring the Hanami action and view integration code.

For some context, it was [back in May 2020](/writing/2020/06/01/open-source-status-update-may-2020/) that I first write the action/view integration code for Hanami 2.0. Back then, there were a couple of key motivators:

- Reduce boilerplate to an absolute minimum, to the extent that simply inheriting from `Hanami::View` within a slice would give you a view class fully integrated with the Hanami application.
- Locate the integration code in the non-core gems themselves (i.e. in the hanami-controller and hanami-view gems, rather than hanami), to help set an example for how alternative implementations may also integrate with the framework.

Since then, we’ve learnt a few things:

- As we’ve gone about refining the core framework, we’ve wound up having to synchronize changes from time to time across the hanami, hanami-controller, and hanami-view gems all at once.
- Other Hanami contributors have noted that the original integration approach was a little too “magical,” and didn’t allow users any path to opt out of the integration code.

Once I finished my work on the concrete slice classes [last month](/writing/2022/03/19/open-source-status-update-february-2022/), I decided that now was the time to address these concerns, to bring the action and view class integrations back into the hanami gem, and to take a different approach to activating the integration code.

The [work in progress is over in this PR](https://github.com/hanami/hanami/pull/1156), and thankfully, it’s nearly done!

The impact within Hanami 2 applications will be fairly minimal: the biggest change is that your base action and view classes will now inherit from _application_ variants:

```ruby
# slices/main/lib/action/base.rb

require "hanami/application/action"

module Main
  module Action
    class Base < Hanami::Application::Action
      # Previously, this inherited from Hanami::Action
    end
  end
end
```

By using this explicit application superclass for actions and views, we hopefully make it easier for our users to understand and distinguish between the integrated and standalone variants of these classes. This distinct superclass should also provide us a clear place to hang extra API documentation relating to the integrated behavior of actions and views.

More importantly for the overall experience, `Hanami::Application::Action` and `Hanami::Application::View` are both now kept within the core hanami gem. While the framework heads into this final stretch of work before 2.0 final, this will allow us to keep together the aspects of the integration that tend to change together, giving us our best chance at providing a tested, reliable, streamlined actions and views experience.

This is a pragmatic move above all else — we’re a team with little time, so the more we can do to give ourselves confidence in this integrated experience working properly, like having all the code and tests together in one place, the quicker we should be able to get to the 2.0 release. Longer term, we’ll want to provide a first-class integration story for third party components, and I believe we can lead the way in how we deliver that via our actions and views, but that’s now firmly a post-2.0 concern in my mind.

In the meantime, I did take this opportunity to rethink and provide some better hooks for classes like `Hanami::Application::View` to integrate with the rest of the framework, chiefly via a new `Hanami::SliceConfigurable` module. You can see how it works by checking out the code for `Hanami::Application::View` itself:

```ruby
# frozen_string_literal: true

require "hanami/view"
require_relative "../slice_configurable"
require_relative "view/slice_configured_view"

module Hanami
  class Application
    class View < Hanami::View
      extend Hanami::SliceConfigurable

      def self.configure_for_slice(slice)
        extend SliceConfiguredView.new(slice)
      end
    end
  end
end
```

Any class that extends `Hanami::SliceConfigurable` will have its own `.configure_for_slice(slice)` method called whenever it is sublcassed within a module namespace that happens to match the namespace managed by an Hanami slice. Using the `slice` object passed to that hook, that class can then read any slice- or application-level config to set itself up to integrate with the application.

In the example above, we extend a slice-specific instance of `SliceConfiguredView`, which will copy across application level view configs, as well configure the view’s part namespaces to match the slice’s namespace. The reason we build a  module instance here (this module builder pattern is [a whole technique](https://dejimata.com/2017/5/20/the-ruby-module-builder-pattern) that I’ll gladly go into one day, but it’s a little out of scope for these monthly updates) is so that we don’t have to keep any trace of the `slice` as state on the class after we’re done using it for configuration, making it so the resulting class is as standalone as possible, and not offering any way for its users to inadvertently couple themselves to the whole slice instance.

Overall, this change is feeling quite settled now. All the code has been moved in and refactored, and all that’s left  is a final polishing pass before merge, which I hope I can get done this week! A huge thank you to [Sean Collins](https://github.com/cllns) for his [original work](https://github.com/hanami/controller/pull/365) in proposing an adjustment to our action integration code. It was Sean’s feedback and exploratory work here that got me off the fence here, and made it so easy to get started with these changes!

That’s it for me for now. See you all again next month, hopefully with some more continued core framework polishing.

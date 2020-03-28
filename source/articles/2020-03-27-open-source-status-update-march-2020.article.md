---
title: Open source status update, March 2020
permalink: 2020/03/27/open-source-status-update-march-2020
published_at: 2020-03-27 22:48:00 +1100
---

Inspired by Piotr’s [open source status update][piotr], I thought I’d begin a similar practice (and get back into the swing of blogging, since this year’s effectively a write-off for in-person meetings).

I hope to do this monthly, but since this is the first one, let me recap the whole of the last year or so! Here are the highlights:

[piotr]: https://solnic.codes/2020/03/02/open-source-status-update/

**dry-view 0.6**

In late 2018 and early 2019 I [built and released dry-view 0.6.0][dry-view-0.6], which contained all the abstractions I thought it needed for 1.0. Then I [gave a talk][dry-view-talk] about it and my philsophy on view layer design in general.

Not much happened after that. I needed a bit of time to recover from my usual intense talk preparation and the blur of conference-driven-development that preceded it. Still, for the rest of the year I was a very satisfied user of dry-view 0.6 within my Icelab applications.

[dry-view-0.6]: https://dry-rb.org/news/2019/02/12/dry-view-0-6-0-an-introductory-talk-and-plans-for-1-0/
[dry-view-talk]: https://www.icelab.com.au/notes/tim-talks-views-from-the-top

**Hanami core application/slices structure**

Later in 2019 I spent a while refining _Snowflakes_, the ersatz framework we developed at Icelab for our own dry-rb/rom-rb/roda-based applications. Most of my work was about enshrining an application/sub-application structure and reducing the amount of boilerplate required for dry-system to provide this.

This turned out to be a prescient effort, because I was able to pivot this approach into the [application and slices structure][hanami-application-pr] that will form the core of the Hanami framework for its upcoming 2.0 release.

Working on this was a supremely rewarding experience, because it represented a true meeting of the minds between Luca, me, and the other dry-rb team members. We each brought our own experiences to bear on this problem, and through a good amount of back and forth and give and take, we found a way to make what I think will both be a convenient, low-ceremony framework structure that at the same time remains extremely powerful, flexible, and cleanly structured.

We’re still working on it, and time will tell, but I’m feeling good about it!

[hanami-application-pr]: https://github.com/hanami/hanami/pull/1019

**Hanami application settings**

Andrew Croome and I got together at Rails Camp Kyneton in November last year and plotted how to add first-class support for application settings to Hanami. Andrew made the broad strokes that weekend, and then I followed up with some adjustments, and I [merged our co-authored PR][hanami-settings-pr] a couple of weeks ago.

Around that same time, solnic released an amazingly simplified [complete rewrite of dry-configurable][dry-configurable-rewrite-pr], and we realised it would serve as a useful underpinning for the Hanami application settings and could also open up some new possibilities like nested settings. I’ve been working since then to prepare the way for this, roughing the changes into Hanami and fixing a [couple][dry-configurable-pr-1] of [things][dry-configurable-pr-2] with dry-configurable along the way. There’s a few more things to do here, and we’re expecting these last changes to culminate with a release of dry-configurable 1.0.

[hanami-settings-pr]: https://github.com/hanami/hanami/pull/1029
[dry-configurable-rewrite-pr]: https://github.com/dry-rb/dry-configurable/pull/78
[dry-configurable-pr-1]: https://github.com/dry-rb/dry-configurable/pull/85
[dry-configurable-pr-2]: https://github.com/dry-rb/dry-configurable/pull/87

**{dry,hanami}-view renaming and application integration**

I’ve temporarily put these dry-configurable adjustments on the backburner, however, so I can focus on some other things we more pressingly need for the next Hanami alpha release: integration of views and actions with the larger framework.

For 2.0, we’ve always intended that dry-view would serve as the view layer for Hanami. The big news here is that we’re now _renaming_ dry-view to hanami-view! Yes, just as hanami-cli became dry-cli to improve the coherence of the gems that make up our two organisations, dry-view will be moving up into the Hanami org to sit alongside hanami-router and hanami-controller as the three main tentpoles of the web application stack.

These renaming decisions have been very easily made, which I think goes to show just how aligned we all are on building an understandable and complementary ecosystem of next-gen Ruby OSS tools :)

I’ve done the renaming and the new code is up in the [master branch of hanami/view][hanami-view-master], with the default branch for the project being renamed to “1.x-master” until we’re done with the 2.0 development.

Now I’m working on making it so that views can sit within an Hanami application with zero boilerplace. This is my [current work-in-progress effort][hanami-view-pr]. The goal is to have it so that your view can be as simple as this:

```ruby
module Main
  module Views
    class MyView < Main::View
    end
  end
end
```

And work out of the box with all appropriate conventions and any required configurations pulled from its slice and the broader Hanami application.

And like any well-behaved component within a dry-system application, it works with dry-system’s auto-registration, which means the view will be fully functional and behave consistently when resolved directly from the container:

```ruby
Main::Slice["views.my_view"]
```

Or auto-injected into an action:

```ruby
module Main
  module Actions
    class MyAction < Main::Action
      include Deps["views.my_view"]
    end
  end
end
```

Or even instantiated directly, like you might do in a test:

```ruby
RSpec.describe Main::Views::MyView do
  subject(:my_view) { described_class.new }
end
```

[As you can see from the PR][hanami-view-pr], there’s not actually all that much required to get the views integrated nicely. What’s left for me a this point is to tidy it up, consider what view configuration might need to exist at the application-level, and then make sure we’re doing everything we can to ensure hanami-view isn’t inextricably tied to the framework: I want to make sure that hanami-view could be switched out for some other view renderer and have the experience feel just as smooth.

Once this is done, the approach for action integration will be very similar, so I hope I can roll through that one relatively quickly!

[hanami-view-master]: https://github.com/hanami/view/tree/master
[hanami-view-pr]: https://github.com/hanami/view/pull/172/files

**See you next month 👋🏼**

Well, I think this has been a pretty good first effort at a monthly update! I hope it’s helpful for anyone wanting to know a little more about what’s going on in my little corner of the Ruby OSS world.

I’m very excited by where things are going, and after a topsy turvy last 6 months for me personally (closing Icelab, staring a new job, etc.), I’m feeling well situated to resume regular work in the OSS sphere, so I’m hoping I’ll have a good few things to report on next month, too.

See you then!

---
title: Open source status update, October 2022–July 2023
permalink: 2023/07/23/open-source-status-update-october-2022-july-2023
published_at: 2023-07-23 17:45 +1000
---

It’s been a hot minute since my [last](/writing/2022/10/20/open-source-status-update-september-2022/) open source status update! Let’s get caught up, and hopefully we can resume the monthly cadence from here.

## Released Hanami 2.0

In Novemver we [released Hanami 2.0.0](https://hanamirb.org/blog/2022/11/22/announcing-hanami-200/)! This was a huge milestone! Both for the Hanami project and the Ruby communuity, but also for us as a development team: we’d spent a _long_ time in the wilderness.

All of this took some doing. It was a mad scramble to get here. The team and I worked non-stop over the preceding couple of months to get this release ready (including me during the mornings of a family trip to Perth).

Anyway, if you’ve followed me here for a while, most of the Hanami 2 features should hopefully feel familiar to you, but if you’d like a refresher, check out the [Highlights of Hanami 2.0](https://discourse.hanamirb.org/t/highlights-of-hanami-2-0/728) that I wrote to accompany the release announcement.

## Spoke at RubyConf Thailand

Just two weeks after the 2.0 release, I spoke at [RubyConf Thailand 2022](https://rubyconfth.com/past/2022/)!

Given I was 100% focused on Hanami dev work until the release, this is probably the least amount of time I’ve had for conference talk preparation, but I was happy with the result. I found a good hook (“new framework, new you”, given the new year approaching) and put together a streamlined introduction to Hanami that fit within the ~20 minutes alotted to the talks (in this case, it was a boon that we hadn’t yet released our view or persistence layers 😆).

Check it out here:

<iframe width="560" height="315" src="https://www.youtube.com/embed/jxJ4-iadvIk?si=rwmn8RO8lzZSVP7x" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

## Overhauled hanami-view internals and improved performance

With the 2.0 release done, we decided to release our view and persistence layers progressively, as 2.1 and 2.2 respectively. This would allow us to keep our focus on one thing at a time and improve the timeliness of the upcoming releases.

So over the Christmas break (including several nights on a family trip to the coast), I started work on the first big blocker for our view layer: hanami-view performance. We were slower than Rails, and that just doesn’t cut the mustard for a framework that advertises itself as fast and light.

Finding the right approach here took several goes, and it was [finally ready for this pull request at the end of February](https://github.com/hanami/view/pull/223). I managed to find a >2x performance boost while simplifying our internals, improving the ergonomics of `Hanami::View::Context` and our part and scope builders, and still retaining all existing features.

## Spoke at RubyConf Australia

Also in February, I spoke at [RubyConf Australia 2023](https://rubyconf.org.au/2023)! After a 3 year hiatus, this was a wonderful reunion for the Ruby community across Australia and New Zealand. It looked like we lost no appetite for these events, so I’m encouraged for next year and beyond.

To fit the homecoming theme, I brought a strong tinge of _Australiana_ to my talk, and expanded it to include a preview of the upcoming view and persistence layers. Check it out:

<iframe width="560" height="315" src="https://www.youtube.com/embed/-B9AbFsQOKo?si=IdY561NsKLMDsvMe" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

## Created Hanami::View::ERB, a new ERB engine

After performance, the next big issue for hanami-view was having our particular needs met by our template rendering engines, as well as making auto-escaping the default for our “first party supported” engines (ERB, Haml, Slim) that output HTML.

ERB support was an interesting combination of all these issues. For hanami-view, we don’t expect any rendering engine to require explicit capturing of block content. This is what allows methods on parts and scopes simply to `yield` and have the returned value match content provided to the block from within the template.

To support this with ERB, we previously had to require our users install and use the [erbse](https://github.com/apotonick/erbse) gem, a little-used and incomplete ERB implementation that provided this implicit block capturing behaviour by default (but did not support auto-escaping of HTML-unsafe values). For a long while we also had to require users use [hamlit-block](https://github.com/hamlit/hamlit-block) for the same reasons, and as such we had to build a compatibility check between ourselves and [Tilt](https://github.com/jeremyevans/tilt) to ensure the right engines were available. This arrangement was awkward and untenable for the kind of developer experience we want for Hanami 2.

So to fix all of this, I [wrote our own ERB engine](https://github.com/hanami/view/pull/226)! This provides _everything_ we need from ERB (implicit block capture as well as auto-escaping) and also allows for hanami-view to be used out of the box without requiring manual installation of other gems.

Meanwhile, in the years since my formative work on hanami-view (aka dry-view), Haml and Slim evolved to both use [Temple](https://github.com/judofyr/temple) and provide configuration hooks for all the behaviour we require, so this allowed me to drop our template engine compatibility checks and instead just automatically configure Haml or Slim to match our needs if they’re installed.

To support our auto-escaping of HTML-unsafe values, we’ve adopted the `Object` and `String` `#html_safe?` patches that are prevalent across relevant libraries in the Ruby ecosystem. This gives us the broadest possible compatibility, as well as a streamlined and unsurprising user experience. While you might see folks decry monkey patches in general, this is one example where it makes sense for Hanami to take a pragmatic approach, and I’m very pleased with the outcome.

## Implemented helpers for hanami-view

After performance and rendering/HTML safety, the last remaining pre-release item for hanami-view was support for helpers. This needed a bit of thinking to sort out, since the new hanami-view provides a significantly different set of view abstractions compared to the 1.x edition.

Here’s how I managed to sort it out:

- In hanami-view, [add configurable part_class and scope_class settings](https://github.com/hanami/view/pull/227) to hanami-view
- In hanami, [configure slice-specific part and scope classes](https://github.com/hanami/hanami/pull/1303)
- In hanami, [include first-party helper modules into these classes](https://github.com/hanami/hanami/pull/1304)
- By this point, all the wiring is in place for first-party helpers
- So in hanami-view, [port all relevant helpers from the 1.x hanami-helpers gem](https://github.com/hanami/view/pull/229), including a new, simpler `TagHelper` for generating HTML tags.
- And over in hanami, [introduce a FormHelper](https://github.com/hanami/hanami/pull/1305) that integrates with the full app, including pulling params from the request
- Then [seamlessly provide all first-party as well as user-defined helpers](https://github.com/hanami/hanami/pull/1307) to view scopes and classes

After this, all helpers should appear whereer you need them in your views, whether in templates, part classes or scope classes. Each slice will also generate a `Views::Helpers` module to serve as the starting point for your own collection of helpers, too.

With hanami-view providing parts and scopes, the idea is that you can and should use available-everywhere helpers less than before, but they can still be valuable from time to time, and with their introduction, now you have every possible option available for building your views.

## Added friendly error pages

While focused on views, I also took the chance to make our error views friendly too. Now we:

- [Render nice error pages in production mode](https://github.com/hanami/hanami/pull/1309) (this is also configurable so you can add custom handling of specific error types)
- [Render detailed error pages in development mode](https://github.com/hanami/hanami/pull/1311), including full stack trace and interactive console, courtesy of [better_errors](https://github.com/BetterErrors/better_errors)

## Worked on integrating hanami-assets

Alongside all of this, Luca has been working hard on our support for front end assets via an [esbuild plugin](https://github.com/hanami/assets-js) and its [integration with the framework](https://github.com/hanami/assets/pull/120). This has been nothing short of heroic: he’s been beset by numerous roadblocks but overcome each one, and now we’re getting really close.

Back in June, Luca and I had our first ever pairing session on this work! We got a long way in just a couple of hours. I’m looking forward to pitching in with this as my next focus.

## Prepared the Hanami 2.1.0.beta1 release

With all the views work largely squared away, I figured it was time to make a beta release and get this stuff out there for people to test, so we [released it as 2.1.0.beta1](https://hanamirb.org/blog/2023/06/29/hanami-210beta1/) at the end of June.

## Spoke at Brighton Ruby!

Also at the end of June I spoke at [Brighton Ruby](https://brightonruby.com)! I’ve wanted to attend this event for the longest time, and it did not disappoint. I had a wonderful day at the conference and enjoyed meeting a bunch of new Ruby friends.

For my talk I further evolved the content from the previous iterations, and this time included a look at how we might grow a Hanami app into a more real thing, as well as reflections on what Hanami 2’s release might mean for the Ruby community. I also experimented with a fun new theme and narrative device, which you shall be able to see once the video is out 😜

Thank you so much to [Andy](https://andycroll.com) for the invitation and the support. ❤️

## Took a holiday

After all of that, I took a break! You might’ve noticed my mentions of all the Hanami work I was doing while ostensibly on family trips. Well, after Brighton Ruby, I was all the way in _Europe_ with the family, and made sure to have a good proper 4 weeks of (bonus summer) holiday. It was fanastic, and I didn’t look at Ruby code one bit.

## What’s next

Now that I’m back, I’ll focus on doing whatever is necessary to complete our front end assets integration and get that out as a 2.1 beta2 release. Our new assets stuff is the completely new, so some time for testing and bug fixing will be useful.

Over the rest of the beta period I hope to complete a few smaller general framework improvements and fixes, and from there we can head towards 2.1.0 final.

I suspect it will take at least one more OSS status updates before that all happens, so I can check in with you about it all then!

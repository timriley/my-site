---
title: Open source status update, September 2022
permalink: 2022/10/20/open-source-status-update-september-2022
published_at: 2022-10-10 23:10 +1000
---

Hello there, friends! This is going to be a short update from me because I’m deep in the throes of Hanami 2.0 release preparation right now. Even still, I didn’t want to let September pass without an update, so let’s take a look.

## A story about Hanami::Action memory usage

Septebmer started and ended with me looking at the [r10k](https://github.com/jeremyevans/r10k) memory usage charts for hanami-controller versus Rails. The results were surprising!

![Initial memory usage for Hanami::Action vs Rails](https://user-images.githubusercontent.com/3134/197044951-8e5742ae-8437-43b2-aba7-11352b5b306d.png)

We’d been running some of these checks as part of our 2.0 release prep, the idea being that it’d help us shake out any obvious performance improvements we’d need to make. And it certainly did in this case! Hanami (just like its dry-rb underpinnings) is meant to be the smaller and lighter framework; why were we being outperformced by Rails?

To address this I wrote a simple memory profile script for `Hanami::Action` inheritance (now [checked in here](https://github.com/hanami/controller/blob/e47fe2484e3d07811e5e817abff17c9a0b027595/benchmarks/memory_profile_action.rb)) and started digging.

[Here were there initial results](https://gist.github.com/timriley/6c512c100c179070c673afc578618386):

```
Total allocated: 184912288 bytes (1360036 objects)
Total retained:  104910880 bytes (780031 objects)

allocated memory by gem
-----------------------------------
  56242240  concurrent-ruby-1.1.10
  53282480  dry-configurable-0.15.0
  34120000  utils-8585be837309
  30547488  other
  10720080  controller/lib
```

That’s 185MB allocated for 10k subclasses, with concurrent-ruby, dry-configurable and hanami-utils being the top three gems allocating memory.

This led me straight to dry-configurable, and after a couple of weeks of work, I [arrived at this PR](https://github.com/dry-rb/dry-configurable/pull/138), separating our storage of setting definitions from their configured values, among other things. This change allows us to copy less data at the moment of class inheritance, and in the case of a dry-configurable-focused memory profile, cut the allocated memory by more than half.

From there, I moved back into hanami-controller and updated it to [use dry-configurable for all of its inheritable attributes](https://github.com/hanami/controller/pull/392) (some were handled separately), also taking advantage the support for [custom config classes](https://github.com/dry-rb/dry-configurable/pull/136) that Piotr added so we could preserve Hanami::Action’s existing configuration API.

This [considerably improved our benchmark](https://gist.github.com/timriley/417595e404e58efb92a5290a4942ef1a)! Behold:

```
Total allocated: 32766232 bytes (90004 objects)
Total retained:  32766232 bytes (90004 objects)

allocated memory by gem
-----------------------------------
  21486072  other
  10880120  dry-configurable-0.16.1
    400040  3.1.2/lib
```

Yes, we brought 185MB allocated memory down to 33MB! This also brought us on par with Rails in the extreme end of the r10k memory usage benchmark:

![Updated memory usage for Hanami::Action vs Rails](https://user-images.githubusercontent.com/3134/196795166-d60b6db8-a75a-44ed-a201-44cd7a054f27.png)

Here’s a thing though: the way r10k generates actions for its Rails benchmark is to create a _single controller class_ with a method per action. So for the point on the far right of that chart, that’s a single class with 10k methods. Hardly realistic.

So I made a quick tweak to see how things would look if the r10k Rails benchmark generated a class per endpoint like we do with Hanami::Action:

![Hanami::Action vs Rails with a separate controller class per action](https://user-images.githubusercontent.com/3134/196795365-4e7111b6-62a6-4dff-adc2-29201375f3d9.png)

That’s more like it. This is another extreme, however: more realistically, we’d see Rails apps with somewhere between 5-10 actions per controller class, which would lower its dot a little in that graph. In my opinion this would be a useful thing to upstream into r10k. It’s already a contrived benchmark, yes, but it’d be more useful if it at least mimicked realistic application structures.

Either way, we finished the month much more confident that we’ll be delivering on our promise of Hanami as the lighter, faster framework alternative. A good outcome!

Along the way, however, things did feel bleak at times. I wasn’t confident that I’d be able to make things right, and it didn’t feel great to think we might’ve spent years putting somethign together that wasn’t going to be able to deliver on some of those core promises. Luckily, I found all the wins we needed, and learnt a few things along the way.

## Hanami 2.0, here we come

What else happened in September? Possibly the biggst thing is that we organised ourselves for the runway towards the final Hanami 2.0.0 release.

We want to do everything possible to make sure the release happens this year, so I spent some time organising the remaining tasks on [our Trello board](https://trello.com/b/lFifnBti/hanami-20) into date-based lists, aiming for a release towards the end of November. It looked achievable! The three of us in the core team re-committed ourselves to doing everything we could to complete these tasks in our estimated timeframes.

So far, things have gone very well!

![Hanami 2.0.0 release progress on Trello](https://user-images.githubusercontent.com/3134/196941690-6a871cbe-3b57-470e-8b32-6887ccab2e22.png)

We’ve all been working tremendously hard, and so far, this has let us keep everything to the schedule. I’ll have a lot to share about our work across October, but that’s all for next month’s update. So in the meantime, I have to put my head back down and get back to shipping a framework. See you all again soon!

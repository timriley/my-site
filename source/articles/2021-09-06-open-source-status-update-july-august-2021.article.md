---
title: Open source status update, July and August 2021
permalink: 2021/09/06/open-source-status-update-july-august-2021
published_at: 2021-09-06 23:00:00 +1000
---

Hello again, open source fans! After two months, we’re overdue for an update! July and August were rather quiet months for me on the OSS front, but I’ve been steadily beavering away at two fairly large things.

## Preparing for the dry-configurable 0.13.0 release

Back in May (_May!_) [I shared details](/writing/2021/06/08/open-source-status-update-may-2021/) of a couple of major changes we wanted to make to dry-configurable’s API before 1.0:

- The default value for the setting must be supplied as `default:` rather than a second positional argument
- A setting’s constructor (or ”processor”) can no longer be supplied as a block, instead it should be a proc object passed to `constructor:`

Those changes have long since merged, but the release didn’t immediately follow, for a couple of reasons:

1. Since dry-configurable is so widely used across the dry-rb and related ecosystems, we needed to double check that every dependent gem would continue to work undisturbed
2. In some early checks for this, we found some small incompatibilities that would need to be addressed

Do you ever have a chore on your to-do list that you just feel... _ugh_ about? Well this was one such thing for me, which is why it didn’t go anywhere for a little while.

But an unglamorous task like this (along with an even stronger aversion to too much open WIP) turned out to be just what I needed to ease myself back into programming in August, after a few weeks of struggling to get anything done.

So, I started by [drawing up an enormous matrix](https://github.com/dry-rb/dry-configurable/issues/120) (seriously, check it, it’s enormous!) of dependent gems to test against both present and future of dry-configurable, and then slowly got to work on it.

To start with, I [cracked the nut](https://github.com/dry-rb/dry-configurable/pull/121) that was likely to give us as-good-as-possible backwards API compatibility. This was one of those fun Ruby 2.7/3.0 keyword argument incompatibilities. Check out the diff from that PR for probably one of the longer comment blocks I’ve written in a while.

Then, I discovered and fixed [a minor issue](https://github.com/dry-rb/dry-system/pull/186) with dry-system’s delegation of keyword arguments to a dry-configurable method. Released that as dry-system 0.18.2 and 0.19.2. That in turns fixed some issues with a few other gems relying on both dry-configurable and dry-system together.

Next, I made [a tiny change](https://github.com/dry-rb/dry-schema/pull/371) to dry-schema to ensure compatibility with another aspect of the upcoming dry-configurable. Released that as dry-schema 1.7.1.

Then lastly, I [added some flags](https://github.com/dry-rb/dry-configurable/pull/124) to allow users to manually disable the deprecation notices if they’re not yet able to upgrade their app or their dependent gems to use the latest API.

And after all of that, we’re truly just around the corner from shipping this new dry-configurable! Here’s what’s left:

1. I need to write some good release notes for the changes
2. Then merge each of the still-open API compatibility PRs for each of the dependent gems (there’s about 4 to go)
3. Then release dry-configurable 0.13.0
4. Then release minor version bumps for all of the dependent gems (6 in total)

I’m hoping to get this done in the next ~week or so. It’ll be a relief to have this done!

## Continued work on first-class dry-system namespace support

The other large thing I’ve continued to work on is the expanded support for namespaces in dry-system that I [detailed in my last update](/writing/2021/07/11/open-source-status-update-june-2021/). I turned to this one when I wanted something a bit more “fun” while I was avoiding the dry-configurable work back in July. It’s now at the point where I’m really quite happy with the new abstractions I was able to identify along the way.

Once the dry-configurable work is done, I plan to come back to this one, and before I spend any more time tidying it for release, I want to actually exercise the new feature from Hanami’s side to make sure it can achieve the elided source directory structure that inspired this work in the first place. All things going well, I should be able to show you it in action in next month’s post!

## Thank you to my sponsors (new and old!) ❤️

Thank you to [Thomas Carr](https://github.com/htcarr3) for joining my GitHub sponsors in July!

And of course, a continued thanks to [Jason Charnes](https://github.com/jasoncharnes) and the rest of my sponsors for your ongoing support!

If you too would like to support my work, you can [sponsor me on GitHub](https://github.com/sponsors/timriley).

See you all next month! With these two things close to done, we might just be cresting a hill.

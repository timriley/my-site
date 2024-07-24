---
title: Tim in open source, July 2024
permalink: 2024/07/24/tim-in-open-source-july-2024
published_at: 2024-07-24 10:38 +0800
---

It’s been a hot minute since [my last open source status update](/writing/2023/10/20/open-source-status-update-september-2023). The fact is, I’ve been too busy working on open source to write about my work on open source.

One thing I realise, however, is that work not _proclaimed_ is work not noticed, so let me tell you what I’ve been doing.

In the nine months since September, I:

- Worked on Hanami 2.1
- Presented on Hanami at RubyConf (San Diego) and RubyConf Taiwan
- Took a blessed short summer break
- [Released Hanami 2.1](https://hanamirb.org/blog/2024/02/27/hanami-210/)
- [Accepted the leadership](https://hanamirb.org/blog/2024/04/04/new-leadership-for-hanami/) of the Hanami project
- Organised [a Ruby unconference](https://rubyincommon.org) in Sydney, a companion event to RubyConf AU
- Meticulously planned [Hanami 2.2’s database layer](https://discourse.hanamirb.org/t/integrating-rom-into-hanami-2-2/971)
- Built Hanami 2.2’s database layer
- Released [a beta of Hanami 2.2](https://hanamirb.org/blog/2024/07/16/hanami-220beta1/)
- Prepared to present at RedDotRubyConf in Singapore

That’s a lot! And herein was a pattern, repeated twice:

- Plan to announce a major new release at a conference
- Push hard to get it ready (oh, and prepare the talk too)
- End up not quite making it
- Go do the conference anyway (always fun, at least!)
- Then come home to yet another big push to finally finish everything off

In the first instance, it was Hanami 2.1 and RubyConf. We were _so close_ to release, but discovered a deal-breaking limitation our assets handling. After frantic hours attempting workarounds from California/Rome/Christchurch, we pulled the plug. There was no easy fix. So after a short break, I overhauled that part of assets system (the right decision: it’s now more flexible and better fits Hanami architecture!) and finally [shipped Hanami 2.1](https://hanamirb.org/blog/2024/02/27/hanami-210/) in February.

In the second case, it’s been Hanami 2.2 and RedDotRubyConf (I’m flying to Singapore as I write this!). This time around, we didn’t get so close to a full release, but far enough to [put out a beta](https://hanamirb.org/blog/2024/07/16/hanami-220beta1/). Once I’m back, I expect another month or two of concerted work to get everything finished.

So, a pattern of near misses, but real progress nonetheless! I’m also encouraged by some promising signs in this latter instance.

This time around, we have some new active contributors, without whom we couldn’t have shipped the beta. Thank you [Adam](https://github.com/alassek), [Sean](https://github.com/cllns), and [Marc](https://github.com/waiting-for-dev)! This time around, we went from [release plan](https://discourse.hanamirb.org/t/plans-for-hanami-2-2/972) to a [quite-complete beta](https://hanamirb.org/blog/2024/07/16/hanami-220beta1/) in less than 60 days, instead of the 15 months between the previous major releases. This time around, we’re mere steps away from finishing the full stack vision for Hanami 2, from providing the streamlined experience we envisioned more than five years ago.

Here’s the rub: everything I’ve done with Hanami has been a fully "nights and weekends" deal for me. For the case of Hanami 2.2, it’s meant practically _every_ night and weekend for two straight months. It’s not sustainable. This is why I couldn’t write you those monthly updates. Speaking of patterns: I’ve done this now for too many years, missed too much family time already, and I need to break this cycle.

I’m optimistic, though. Change is coming. The above was the old era. We’re about the enter the new: Hanami 2.2 is on the way! This is something to be excited for! It’s exciting for you, because with just a few commands you’ll have yourself a whole new way of building modular, maintainable, database-backed apps of all shapes in Ruby. It’s also exciting for me, because it means I can at last look up to the horizon and start planning all the great ways we can promote and build upon this new foundation.

It also means I plan to figure out ways to make this whole endeavour sustainable for me. This is the only way we can serve the Hanami and Ruby communities long into the future. Hanami turns 10 this year, and I want it to live for decades more. If you’re experienced with funding OSS, I’d love to chat with you about this.

So there we are, you’re all caught up on a productive few months for Hanami! I’m looking forward to sharing my next update with you, where I hope we can celebrate the release of 2.2 and the beginning of our new era!

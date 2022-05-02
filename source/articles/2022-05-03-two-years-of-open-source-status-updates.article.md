---
title: Two years of open source status updates
permalink: 2022/05/03/two-years-of-open-source-status-updates
published_at: 2022-05-03 00:15 +1000
---

Back in March of 2020, I decided to take up the habit of writing monthly status updates for my open source software development. 22 updates and 25k words later, I’m happy to be celebrating two years of status updates!

As each month ticks around, I can find it hard to break away from cutting code and write my updates, but every time I get to publishing, I’m really happy to have captured my progress and thinking.

After all, these posts now help remind me I managed to do all of the following over the last two years (and these were just the highlights!):

- Renamed dry-view to hanami-view and kicked off view/application integration ([Mar 2020](/writing/2020/03/27/open-source-status-update-march-2020))
- Received my first GitHub sponsor ([Apr 2020](/writing/2020/04/30/open-source-status-update-april-2020)), thank you Benny Klotz (who still sponsors me today!)
- Shared my Hanami 2 application template ([May 2020](/writing/2020/05/07/sharing-my-hanami-2-application-template))
- Achieved seamless view/action/application integration ([May 2020](/writing/2020/06/01/open-source-status-update-may-2020))
- Brought class-level configuration to Hanami::Action ([Jun 2020](/writing/2020/06/28/open-source-status-update-june-2020))
- Introduced application-level configuration for actions and views ([Jul 2020](/writing/2020/08/03/open-source-status-update-july-2020))
- Added automatic inference for an action’s paired view, along with automatic rendering ([Jul 2020](/writing/2020/08/03/open-source-status-update-july-2020))
- Introduced application integration for view context classes ([Jul 2020](/writing/2020/08/03/open-source-status-update-july-2020))
- Supported multiple boot file dirs in dry-system, allowing user-replacement of standard bootable components in Hanami ([Aug 2020](/writing/2020/08/31/open-source-status-update-august-2020))
- Rebuilt the Hanami Flash class ([Aug 2020](/writing/2020/08/31/open-source-status-update-august-2020))
- Resumed restoring hanami-controller features through automatic enabling of CSRF protection ([Sep 2020](/writing/2020/10/06/open-source-status-update-september-2020))
- Added automatic configuration to views (inflector, template, part namespace) ([Oct 2020](/writing/2020/11/03/open-source-status-update-october-2020))
- Released a non-web Hanami application template ([Oct 2020](/writing/2020/11/03/open-source-status-update-october-2020))
- Started the long road to Hanami/Zeitwerk integration with an autoloading loader for dry-system ([Nov 2020](/writing/2020/12/07/open-source-status-update-november-2020))
- Introduced dedicated “component dir” abstraction to dry-system, along with major cleanups and consistency wins ([Dec 2020](/writing/2021/01/06/open-source-status-update-december-2020)/[Jan 2021](/writing/2021/02/01/open-source-status-update-january-2021))
- Added support for dry-system component dirs with mixed namespaces ([Feb](/writing/2021/03/09/open-source-status-update-february-2021)/[Mar/Apr 2021](/writing/2021/05/10/open-source-status-update-march-april-2021))
- Released dry-system with all these changes, along with Hanami with working Zeitwerk integration ([Mar/Apr 2021](/writing/2021/05/10/open-source-status-update-march-april-2021))
- Ported Hanami’s app configuration to dry-configurable ([May 2021](/writing/2021/06/08/open-source-status-update-may-2021)),
- Laid the way for dry-configurable 1.0 with some API changes ([May](/writing/2021/06/08/open-source-status-update-may-2021)/[Jul 2021](/writing/2021/09/06/open-source-status-update-july-august-2021))
- Returned to dry-system and added configurable constant namespaces ([Jun](/writing/2021/07/11/open-source-status-update-june-2021)/[Jul/Aug](/writing/2021/09/06/open-source-status-update-july-august-2021)/[Sep](/writing/2021/10/11/open-source-status-update-september-2021)/[Oct 2021](/writing/2021/11/15/open-source-status-update-october-2021))
- Introduced compact slice source dirs to Hanami, using dry-systems constant namespaces ([Sep](/writing/2021/10/11/open-source-status-update-september-2021)/[Oct 2021](/writing/2021/11/15/open-source-status-update-october-2021))
- Added fully configurable source dirs to Hanami ([Nov](/writing/2021/12/13/open-source-status-update-november-2021)/[Dec 2021](/writing/2022/02/14/open-source-status-update-december-2021-january-2022))
- Shipped a huge amount of dry-system improvements over two weeks of dedicated OSS time in [Jan 2022](/writing/2022/02/14/open-source-status-update-december-2021-january-2022), including the overhaul of bootable components as part of their rename to providers, as well as partial container imports and exports, plus much more
- Introduced concrete slice classes and other slice registration improvements to Hanami ([Feb 2022](/writing/2022/03/19/open-source-status-update-february-2022))
- Refactored and relocated action and view integration into the hanami gem itself, and introduced `Hanami::SliceConfigurable` to make it possible for similar components to integrate ([Mar 2022](/writing/2022/04/10/open-source-status-update-march-2022))

This is a lot! To add some extra colour here, a big difference betwen now and pre-2020 is that I’ve been working on OSS exclusively in my personal time (nights and weekends), and I’ve also been slugging away at a single large goal (Hanami 2.0, if you hadn’t heard!), and the combination of this can make the whole thing feel a little thankless. These monthly updates are timely punctuation and a valuable reminder that I am moving forward.

They also capture a lot of in-the-moment thinking that’d otherwise be lost to the sands of time. What I’ve grown to realise with my OSS wor is that it’s as much about the _process_ as anything else. For community-driven projects like dry-rb and Hanami, the work will be done when it’s done, and there's not particularly much we can do to hurry it. However, what we should never forget is to make that work-in-progress readily accessible to our community, to bring people along for the ride, and to share whatever lessons we discover along the way. The passing of each month is a wonderful opportunity for me to do this 😀

Finally, a huge thank you from me to anyone who reads these updates. Hearing from folks and knowing there are people out there following along is a huge encouragement to me.

So, let’s keep this going. I’m looking forward to another year of updates, and—_checks calendar_–writing April’s post in the next week or so!

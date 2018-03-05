---
title: Decaf Sucks, and a Rails Rumble Redux
permalink: 2009/09/02/decaf-sucks-and-a-rails-rumble-redux
published_at: 2009-09-02 06:35:00 +0000
---

## Decaf Sucks

48 hours. 3 hackers ([Max](http://makenosound.com), [Hugh](http://hughevans.net) and [yours truly](http://openmonkey.com/about)), 1 web application built from scratch. Allow me to introduce you to [**Decaf Sucks**](http://decafsucks.com/), our Rails Rumble entry and a site for helping you find great coffee.

[![Screenshot of Decaf Sucks](squarespace/images/ss/5ac1bd7cfb18.jpg)](http://decafsucks.com/)

We hate bad coffee. We hate the way it tastes, the way it smells, and most of all we hate paying for it. Decaf Sucks is about helping each other to find the good cafés and avoid the bad ones.

So [check it out](http://decafsucks.com/) and [leave a review](http://decafsucks.com/reviews/new). Also be sure to try the site on your iPhone. It uses the GPS to enable you to find the best cafés nearby, and write a review as you bask in the sweet glow of a just finished cup of coffee.

## Lessons Learnt Starting Up Fast

We've been trying to build this app for over a year. We would have spent well in excess of 48 hours together working on our first prototype. The trouble was that we dreamt big and started to build an app that would do everything at once. Finally, it took the [Rails Rumble](http://railsrumble.com/) to get us somewhere. We were forced focus on a core experience and how we could implement it quickly. I'm very pleased with the result, and would like to share the things I have learnt in competing over the last three Rumbles.

**Build something you want to use.** There is no stronger motivation than this.

**Say no,** and do it early. Define the core experience your application will provide and build that well. Save any other ideas for later.

**Have a designer on your team.** This is the single biggest improvement to our previous Rumble entries. It was great to have the talented [Max](http://makenosound.com/) on the team. First impression and overall polish counts for a lot. Allow your app to make the best impression!

**Track your outstanding tasks in meatspace.** Try a whiteboard or a large sheet of butcher's paper. This is an easy technique to keep the group mindful of what is left to do. It's also very satisfying to write a big tick or strike through a completed task.

**Work in the same place.** This is the fun part: hack together, share your meals and enjoy the weekend. This also makes it easy to discuss your app, form consensus quickly, and get back to building.

**Don't plan much for Monday.** When it comes to Sunday afternoon and you realise you still have many hours left of work to do, you don't want anything to get in the way. The last two years we have worked through Sunday night to finish our apps. Each time it has been worth it. If you are an employee and working in any kind of IT role, tell your boss that this is 40 hours of the most intense, practical and relevant training anyone could receive, and hopefully they see reason and give you the time off. _(This only applies if you are in a timezone similar to GMT +10)_

**Have someone focus solely on user experience.** This doesn't necessarily have to be your designer.

**Keep most of your site accessible without a login.** You've worked hard. Minimise the number of hurdles required for people to admire it.

**Outsource your authentication.** When you do need authentication, outsource it. Use [Twitter](http://apiwiki.twitter.com/OAuth-FAQ), [Facebook](http://developers.facebook.com/connect.php), or [OpenID](http://openid.net/). Your choice will depend on the kind of audience you're seeking.

**Use only one or two models.** Key models at least. Any more and the chances are that you will have more pages to build than your weekend will allow.

**Use good plugins.** These will save you so much time! The heroes for us this year were [twitter-auth](http://github.com/mbleigh/twitter-auth/tree/master) and [geokit](http://geokit.rubyforge.org/). Both are well built and well documented, with a great out of the box experience. They offered no unpleasant surprises, meaning we could integrate them easily.

**Refer to [Railscasts](http://railscasts.com)!** This site is an invaluable resource. If you're trying something new with Rails, chances are that there is already a screencast about it.

**Build your server early.** Towards the end of the weekend, you'll be focused on completing your application and deploying often. Don't let an outstanding server build get in the way.

**Build your server fast.** Don't let your server build consume too much time either. Use an automated provision tool like [passenger-stack](http://github.com/benschwarz/passenger-stack). If you predict that you will have an involved setup process, buy a [slice](http://slicehost.com/) for a week or two before the competition, build the server to your specifications, and document your process.

## Something Different

Now for some things that I would try differently next time:

Implement a working [grey box](http://v3.jasonsantamaria.com/archive/2004/05/24/grey_box_method.php) design first. I find it a lot easier to build an application backend if it is at least for a prototypical frontend.

Write Cucumber integration tests for the application's "happy path." As the last long night wore on, we were making plenty of changes that had the potential to break things. It would have been good to have some tests confirm everything still worked as expected. I don't think it's feasible over the weekend to build your app via TDD/BDD, but a small set of integration tests would help without being too burdensome.

Write these Cucumber features ahead of time. I don't think this would break the competition rules and it would be useful to have these from the beginning. This would also help you and your teammates crystallise the application's functionality before the build weekend.

## Context

One of the reasons I like competing in the Rails Rumble is that it provides sweet, glorious _context_. If you're working as a programmer somewhere that requires your attention in many places, frequent context shifts are a fast way to swap happy productivity for overall malaise. The Rails Rumble is a way to rejuvenate yourself. Gustavo Duarte [captures the experience](http://duartes.org/gustavo/blog/post/lucky-to-be-a-programmer) well:

> Few things are better than spending time in a creative haze, consumed by ideas, watching your work come to life, going to bed eager to wake up quickly and go try things out. I am not suggesting that excessive hours are needed or even advisable; a sane schedule is a must except for occasional binges. The point is that programming is an intense creative pleasure, a perfect mixture of puzzles, writing, and craftsmanship.

While it is indeed one of those occasional binges, this year's Rails Rumble was a timely personal reminder of why I play this game: to focus on creating new and helpful things in interesting ways. See you next year.


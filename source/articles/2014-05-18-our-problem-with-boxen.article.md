---
title: Our Problem with Boxen
permalink: 2014/5/18/our-problem-with-boxen
published_at: 2014-05-18 06:05:05 +0000
---

Over a year ago, we started using [Boxen](https://boxen.github.com) at Icelab to manage our team’s development environments. It’s worked as advertised, but not well enough. I’m looking for something else.

Our problem with Boxen is that it contains hundreds of different components, all of which are changing, _all the time._ It needs constant tending. By the time a team is big enough to need something like Boxen, it’s paradoxically _too small_ to look after it properly: to have someone whose job it is to be “Boxenmaster,” someone who knows how these intricate parts all interact and can run the regular clean installs needed to make sure that the experience is smooth for new people (we’ve found it typical for a functional Boxen setup to stay working over repeated updates, while clean installs end up failing). We need a tool that we can set up once for a project and then have it still work reliably 6 months later when we revisit the project for further work.

Boxen can be a trojan horse. If you don’t look after it properly, you risk creating two classes of developers within your team: those who were around to get Boxen working when you first rolled it out, now enjoying their nice functional development environments, and those who get started later, whose first experience in the team is one of frustration, non-productivity and a disheartening, unapproachable web of interconnected packages. And no one is safe: as soon as you want to upgrade that version of PHP, you could slip down there too.

So while Boxen can indeed work as manager of personal development environments, and while Puppet is a serious and capable configuration manager, my recommendation is not to commit to Boxen half-heartedly. In fact, you may not even need something so rigorous and complex if your team is still small. I’m looking into such alternatives right now. I’m not settled on anything yet, but it’ll likely involve virtual machines, and perhaps use Docker as a way to keep it lightweight while working on multiple projects at a time. [Fig](http://orchardup.github.io/fig/) seems like it could be a good fit. I’ll keep you posted.


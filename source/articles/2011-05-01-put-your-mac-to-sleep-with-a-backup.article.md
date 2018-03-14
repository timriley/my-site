---
title: Put Your Mac to Sleep With a Backup
permalink: 2011/05/01/put-your-mac-to-sleep-with-a-backup
published_at: 2011-05-01 06:10:00 +0000
---

One aspect of my backup strategy is a full clone of my MacBook Pro's hard drive using [SuperDuper](http://www.shirt-pocket.com/SuperDuper/). This is very useful, since it means that I have a complete, bootable duplicate of my hard drive that I can use to get back up and running quickly in the event of a hardware failure. The downside of backing up this way, however, is that it can become a "whenever I remember" approach, which is a recipe for quickly falling behind or forgetting altogether.~

This is especially the case if you use a portable computer that isn't always hooked in and running at a particular location (I carry mine to and from [the lab](http://icelab.com.au/) each day).

Here's the solution that has worked for me: configure a SuperDuper backup schedule that commences whenever your external disk is connected, and finishes by putting your Mac to sleep:

 ![SuperDuper](content/images/ss/f1261aa894fb.png)

My MacBook usually gets opened over the course of a normal evening at home. My rule is that the only way I can put it to sleep for the night is by connecting my backup drive and triggering the SuperDuper backup. It's fast and simple; connecting a single cable to the USB port is no bother at all. The backup runs and then my Mac goes to sleep, and it means I can sleep easier too, with my data better protected.

_nb. If you adopt this approach, it's useful to know the control+shift+eject keyboard shortcut, which you can use to turn off your Mac's display once you've attached the backup drive._


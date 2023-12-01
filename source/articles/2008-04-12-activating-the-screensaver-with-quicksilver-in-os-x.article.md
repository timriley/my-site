---
title: Activating the screensaver with Quicksilver in OS X
permalink: 2008/04/12/activating-the-screensaver-with-quicksilver-in-os-x
published_at: 2008-04-11 14:45:00 +0000
---

There are a [few](http://www.rousette.org.uk/blog/archives/quicksilver-activate-screensaver-snippet/) [posts](http://leafraker.com/2007/09/14/start-the-screen-saver-with-quicksilver/) around the net that describe some ways to launch the OS X screensaver using a keyboard shortcut with [Quicksilver](http://www.blacktree.com/). However, common to all of these approaches is using a code snippet that is launched by a trigger.

Quicksilver triggers can only be launched by global keybindings or mouse gestures. That is, you can't access them through the main quicksilver interface. A simple way around this is to use Automator to create a custom screensaver launch application:

 ![Automator workflow for screensaver launch app](cc0da2d4473f.jpg)

Save the workflow as an app called, let's say, "Screensaver", put it in your Applications folder, and you can then use Quicksilver to activate your screensaver like you would launch any ordinary app.


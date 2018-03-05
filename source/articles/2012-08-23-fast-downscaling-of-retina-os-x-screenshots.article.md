---
title: Fast Downscaling of Retina OS X Screenshots
permalink: 2012/08/23/fast-downscaling-of-retina-os-x-screenshots
published_at: 2012-08-22 21:30:00 +0000
---

Screenshots from the retina MacBook Pro look comically large when I share them with my _@1x_ teammates. This kind of fidelity is especially unnecessary when casually sharing annotated snapshots back and forth during the app development process.

Automator makes it easy to build an app that will halve the dimensions of the images. Open Automator, choose to build a new _Application_, then add these steps:

 ![Automator actions for retina image downscaling](squarespace/images/ss/1a67e9a39885.png)

Save it to `/Applications` and you're done. Then, dragging an image onto the app's icon will immediately copy it to your desktop and rescale it. Put it in your Dock for even easy access, or if you use [LaunchBar](http://www.obdev.at/products/launchbar/index.html), you can do it even faster with [InstantSend](http://www.obdev.at/resources/launchbar/help/index.php?chapter=InstantSend).


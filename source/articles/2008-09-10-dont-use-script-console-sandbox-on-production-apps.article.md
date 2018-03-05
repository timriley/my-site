---
title: "Lessons learnt the hard way: Don't use script/console --sandbox on production apps"
permalink: 2008/09/10/dont-use-script-console-sandbox-on-production-apps
published_at: 2008-09-10 02:05:00 +0000
---

Don't use `script/console -s` or `script/console --sandbox` on your live, running Rails application. The built-in transactions that roll back on exit are nifty, but if your database's transactions use any kind of locking, then you will get locks on the tables for any models that you use in the console. This will most likely stop your application from working.

Moral of the story? If you need to use the console on a live application, just be careful. You're smart, you're cautious, you don't need the sandbox. It will only cause more trouble than it is worth.


---
title: Sharing my Hanami 2 application template
permalink: 2020/05/07/sharing-my-hanami-2-application-template
published_at: 2020-05-07 21:40:00 +1000
---

We’ve been hard at work building Hanami 2 for a while now, but the truth is, it’ll be a while still until it’s truly ready.

In the meantime, [I’ve put together an Hanami 2 application template][repo] that reflects how I’m currently using various Hanami 2 components within the applications I develop day-to-day.

It currently consists of:

- The Hanami 2 application core
- Hanami router
- Hanami controller and view manually integrated into the app (along with some helpers for rendering views within actions)
- [rom-rb](https://rom-rb.org) configured to use a Postgres database
- A `bin/run` CLI with some extra commands to help you work with the database (`db create`, `db migrate`, `db create_migration`, etc.)
- A little static assets manager built using Webpack, along with an `assets` helper object for use within views
- A fully configured RSpec setup

If you want to begin exploring the ideas and features of Hanami 2, all while the framework is still under active development, this template is a great way to get started! As the framework improves, I’ll keep this template updated alongside it.

Fair warning: this template comes with no documentation and no support, but hopefully the code can serve as a helpful guide for those willing to dig around.

Please go ahead and [**check out the template**][repo]! I’m excited to share this early look into the Hanami 2 app development experience. Even at this early stage, it’s a framework that gives me great joy to use every day. 🌸

[repo]: https://github.com/timriley/hanami-2-application-template

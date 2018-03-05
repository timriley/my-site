---
title: ActionMailer templates in Rails 2.0
permalink: 2008/01/20/actionmailer-templates-in-rails-20
published_at: 2008-01-10 07:15:00 +0000
---

When upgrading to Rails 2.0, it seems you cannot rename all of our `.rhtml` templates to `.html.erb` - it seems ActionMailer will refuse to find templates with this extension. Make sure you rename them to just `.erb`.


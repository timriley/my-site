---
title: Show Me the Page!
permalink: 2009/08/06/show-me-the-page
published_at: 2009-08-06 00:15:00 +0000
---

Get this in your Cucumber steps.

```
Then /^show me the page$/ do
  save_and_open_page
end
```

Thanks to the magic of [webrat's](http://wiki.github.com/brynary/webrat) lesser known [save\_and\_open\_page](http://github.com/brynary/webrat/blob/273e8c541a82ddacf91f4f68ab6166c16ffdc9c5/lib/webrat/core/save_and_open_page.rb), this will save the current page to a temporary file and open it in your browser. Be sure to `gem install launchy` for it to work.

Here's a sample of _show me the page_ in a scenario:

```
Scenario: Signing in
  When I go to the home page
  And I fill in "username" with "john"
  And I fill in "password" with "john"
  Then show me the page
```

Very useful for debugging.


---
title: Cucumber steps for testing page URLs and redirects
permalink: 2009/03/04/cucumber-steps-for-testing-page-urls-and-redirects
published_at: 2009-03-03 23:35:00 +0000
---

With the new project at [work](http://www.amc.org.au/), we're making sure we follow the best practices we know. This means building the app in weekly iterations according to user stories that we review and schedule with the business owners. It also means being strict about writing tests first, and so far we're doing pretty well.

We're using the shiny new [Cucumber](http://github.com/aslakhellesoy/cucumber) as much as possible for our high-level integration testing. Along with Cucumber's [webrat steps](http://github.com/aslakhellesoy/cucumber/blob/6feabc03c3ffd5e7c8b5d0fa82225d712f48d564/rails_generators/cucumber/templates/webrat_steps.rb), it is easy to write features that, among other things, can request pages, fill in forms, and check for text on the returned pages. When we add in Ian White's [pickle](http://github.com/ianwhite/pickle), we also have [integration](http://github.com/ianwhite/pickle/blob/2c7cd1bc81bf3762f754b602414f907a1c35ea2a/rails_generators/pickle/templates/paths.rb) with Rails' named routes to keep your features readable and steps DRY.

We often use this one webrat step for visiting a page:

```
When /^I go to (.+)$/ do |page_name|
  visit path_to(page_name)
end
```

This is the only step that webrat provides relating to pages and paths. We found that we needed a couple more:

```
Then /^I should be on the (.+?) page$/ do |page_name|
  request.request_uri.should == send("#{page_name.downcase.gsub(' ','_')}_path")
  response.should be_success
end

Then /^I should be redirected to the (.+?) page$/ do |page_name|
  request.headers['HTTP_REFERER'].should_not be_nil
  request.headers['HTTP_REFERER'].should_not == request.request_uri

  Then "I should be on the #{page_name} page"
end
```

With these steps, we can properly check the URL of the page we've been returned, and whether or not we have been redirected during that request cycle. This was important for us to have the fullest coverage possible for our authorization features:

```
Feature: Users cannot access to the system without logging in
  In order to protect the system from unauthorized access
  An anonymous user
  Should not have access to the system

  Scenario: Visiting the login page
    Given an anonymous user
    When I go to the new login page
    Then I should be on the new login page

  Scenario: Redirecting to login page
    Given an anonymous user
    When I go to the home page
    Then I should be redirected to the new login page
```

The first scenario ensures that we don't end up in a redirect loop for an anonymous user directly visiting the login page, and the second scenario ensures that an anonymous user accessing any page in the system is appropriately blocked from access and redirected to the login page.


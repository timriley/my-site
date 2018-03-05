---
title: JavaScript Testing with Cucumber and Capybara
permalink: 2010/04/09/javascript-testing-with-cucumber-and-capybara
published_at: 2010-04-09 04:55:00 +0000
---

[Capybara](http://github.com/jnicklas/capybara) is a Ruby DSL for easily writing integration tests for Rack applications. It is an alternative to Webrat and can easily replace it as a backend for your [Cucumber](http://cukes.info/) features. Its power and utility lies in that it comes bundled with several different browser simulators, equipping you with a flexible toolkit for testing all parts of your application, from the simplest page to the most complex, JavaScript-heavy page.

 [caption id="" align="alignnone" width="500.0"] ![A photo of real capybaras.](squarespace/images/ss/a7d850d3b04c.jpg) A photo of real capybaras.[/caption]

Using Capybara means you can now confidently write your Cucumber features as the first thing to drive the development of your application, regardless of how you plan to implement the feature. Another win for testing!

## Using Capybara

Capybara, much like [Webrat](http://github.com/brynary/webrat) before it, provides a broad set of steps you can use to test your application in Cucumber features:

```
Scenario: Creating an article
  Given I go to the new article page
  And I fill in "Title" with "JavaScript Testing with Cucumber and Capybara"
  And I fill in "Body" with "Here is my article"
  And I press "Create"
  Then I should see "Article created"
```

By default, it uses [rack-test](http://github.com/brynary/rack-test) as the simulator to run your scenarios against your application. rack-test is the fastest of all Capybara's drivers, and should be used whenever possible to keep down the time needed to run your entire suite of scenarios. It should have no trouble handling anything like the above scenario.

You can use the rack-test driver according to one simple rule: no JavaScript, no problems. However, Cucumber does include a helper that allows you to use Capybara with rack-test to test the links with `onclick` JavaScript handlers that Rails uses for deleting records:

```
<%= link_to 'Delete', article_path(@article), :method => :destroy, :confirm => 'Are you sure?' %>

Scenario: Deleting an article
  Given an article exists
  When I go to the article's page
  And I follow "Delete"
  Then I should see "Article deleted"
```

## Testing JavaScript with Different Browser Simulators

Many parts of your application will be simple to test with scenarios like the above, but you will invariably have other parts that depend on complex interactions powered by JavaScript or AJAX requests. While these parts have historically been the hardest to test, their complexity in fact demands the strongest test coverage! Capybara will let you write the tests that these parts of your application deserve.

Capybara comes with built-in drivers for several browser simulators that support JavaScript: [Selenium](http://seleniumhq.org/), [Culerity](http://github.com/langalex/culerity) and [Celerity](http://celerity.rubyforge.org/). While Webrat has always allowed you to use Selenium as a browser simulator, it is an additional dependency that has at times been [difficult](http://twitter.com/schlick/status/10258959861) to configure.

With Capybara, using Selenium is as simple as putting a `@javascript` tag above a scenario:

```
@javascript
Scenario: Endless pagination with AJAX
  Given 10 articles exist
  When I go to the articles page
  Then I should see 5 articles
  When I follow "More articles"
  Then I should see 10 articles
```

This tests the kind of endless pagination that you see on [Twitter](http://twitter.com/timriley). Running the above scenario, you would see Firefox open up and automatically run through your steps on a working copy of your app. The AJAX request will fire and you'll see the extra 5 articles appear on the page. Everything passes. Excellent!

If you'd like to avoid a dependency on a GUI browser for your tests, you can try Celerity as a browser simulator, via the Culerity driver. Celerity is a JRuby wrapper for HtmlUnit, a Java headless browser with JavaScript support. Culerity is a wrapper for Celerity that allows any Rails app to use Celerity for testing, without the app having to run under JRuby. In practice, this is not as convoluted as it sounds. The end result is that Culerity will fire up a separate JRuby process to run tests against your app, while your app executes in its usual Ruby runtime.

All you need to do to is put a `@culerity` tag above your scenario:

```
@culerity
Scenario: Endless pagination with AJAX
  Given 10 articles exist
  When I go to the home page
  Then I should see 5 articles
  When I click "More articles"
  Then I should see 10 articles
```

Running this same scenario through Culerity, you'll see each step pass as before, just without the browser running on-screen. This is useful if you're looking to have your integration tests work nicely on a headless CI box or something similar.

Just like you can use `@culerity` to force a particular driver for a scenario or feature, you can explicitly require selenium by using the `@selenium` tag, and rack-test with `@rack_test`. The `@javascript` tag is reserved for Capybara's default JavaScript-supporting simulator. You can change this by creating a `features/support/capybara.rb` file and including the following:

```
# :culerity or :selenium
Capybara.javascript_driver = :culerity
```

You can also change the default driver for all scenarios:

```
Capybara.default_driver = :selenium
```

## Here's One I Prepared Earlier

I've put together a [Rails app](http://github.com/timriley/capybara-demo) that includes all the examples covered so far, ready for you to try yourself. The only thing you need is a recent version of [bundler 0.9](http://gembundler.com/). To clone the app and and set it up:

```
git clone git://github.com/timriley/capybara-demo.git capybara-demo
cd capybara-demo
bundle install
```

Then you can run the Cucumber features:

```
bundle exec rake cucumber:all
```

And you can also start a server to verify the features manually:

```
./script/server
```

## Installing Cucumber with Capybara

Getting Cucumber and Capybara in your own app is easy.

```
gem install cucumber capybara
```

If you're on the bundler, then just put the following in your `Gemfile` and run `bundle install`.

```
group(:test) do
  gem 'cucumber'
  gem 'cucumber-rails'
  gem 'capybara'
  gem 'culerity'
  gem 'celerity', :require => nil # JRuby only. Make it available but don't require it in any environment.
end
```

Then run the Cucumber generator with the `--capybara` flag:

```
cd /my_app
./script/generate cucumber --capybara
```

Running this generator will create a `web_steps.rb` file in `features/step_definitions`. This file is a mostly-compatible replacement for the `webrat_steps.rb` that you may have had otherwise. It contains largely the same steps, and all of the following will work as you expect:

```
Given I am on the home page
When I go to the home page
When I press "Submit"
When I follow "New article"
When I fill in "Address" with "5 Smith Street" within "fieldset#home-address"
When I select "ACT" from "State" within "fieldset#home-address"
When I check "Remember Me"
When I uncheck "Remember Me"
When I choose "My Radio Button"
Then I should see "Article created" within ".flash"
Then I should not see "Error creating article"
Then the "Title" field should contain "My Title"
Then the "Title" field should not contain "My Title"
Then the "Remember Me" checkbox should be checked
Then the "Remember Me" checkbox should not be checked
Then I should be on the home page
Then show me the page
```

While most of your features should run just fine, you may need to make some small tweaks to correct things, especially if you used some of the date selector steps that were present in `webrat_steps.rb` but not in `web_steps.rb`.

### Installing Culerity Support

While the Selenium driver will work for you out of the box, you need [JRuby](http://jruby.org/) installed in order to use Culerity & Celerity. If you are using [RVM](http://rvm.beginrescueend.com/), this is also easy:

```
rvm install jruby
```

Culerity will look for a `jruby` binary and use it to run Celerity. With RVM, you'll need to make a `jruby` symlink to the versioned binary that it installs:

```
cd ~/.rvm/bin
ln -s jruby-1.4.0 jruby
```

That's it. You'll note in the `Gemfile` example above that we install the celerity gem for culerity to use, but don't require it in any of the app's environments, since your app (is most likely) not running under JRuby.

## Go to it!

Since I've started using Capybara, I've been enjoying writing more integration for more parts of my applications, and it's been a lot of fun. I hope this guide helps you follow the same path!


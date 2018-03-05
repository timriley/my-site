---
title: De-@wip Your Cucumber Stories
permalink: 2009/06/29/de-wip-your-cucumber-stories
published_at: 2009-06-29 06:55:00 +0000
---

We've been really hitting the [Cucumber](http://cukes.info/) hard in the recent few iterations of our current project. Now that we're [ping pong pair programming](http://en.wikipedia.org/wiki/Pair_programming#Ping_pong_pair_programming), the Cucumber story is the first thing we write, and we revisit regularly during the [red-green-refactor](http://jamesshore.com/Blog/Red-Green-Refactor.html) cycle.

To make this easy, we place a `@wip` _work in progress_ [tag](http://wiki.github.com/aslakhellesoy/cucumber/tags) at the top of the current stories:

```
Feature: Make coffee

  # This one is done.
  Scenario: First coffee of the day

  # This is the one we're working on.
  @wip
  Scenario: Afternoon perk up
```

Then we use `cucumber -t wip` to run just the stories in progress. Once the stories are green and we're happy to move on, we often forget to remove the `@wip` tags before committing. I wrote a little sed command in a bash alias to make this easier:

```
# Remove any @wip tags from Cucumber features.
alias dewip="sed -E -i '' -e '/^[[:blank:]]*@wip$/d;s/,[[:blank:]]*@wip//g;s/@wip,[[:blank:]]*//g' features/**/*.feature"
```

Throw it in your `.bash_profile` for ease of access! Here's a [gist](http://gist.github.com/136294) for your forking pleasure.


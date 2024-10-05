---
title: Tim in open source, September 2024
permalink: 2024/10/05/tim-in-open-source-september-2024
published_at: 2024-10-05 11:22 +0900
---

Hello there, friends! It’s been a couple of months since [my last open source update](/writing/2024/07/24/tim-in-open-source-july-2024), so what have I been up to? A bunch of things, all culminating in a new Hanami 2.2 beta!

## RedDotRubyConf returns!

First came [RedDotRubyConf 2024](https://reddotrubyconf.com) in Singapore, back again after seven years! It was great: excellent mix of talks, a small but engaged crowd, and as always, amazing hospitality. Thank you to Ted and all the organisers for bringing it back! I hope it can continue into the future!

RedDotRubyConf is a special event for me: it was my first opportunity to speak at a Ruby conference, as well as my first chance to give a workshop. Before ths one, I’d attended three different editions over the years, dating all the way back to [Andy’s](https://andycroll.com) last event [in 2012]((https://web.archive.org/web/20120602230212/http://reddotrubyconf.com/)). My talk this year was a nice bookend to how I started. All the way back in 2013, I presented my stack of [dry-rb, ROM and Roda](https://www.youtube.com/watch?v=6ecNAjVWqaI) as a vision for a new generation of Ruby apps. This year I presented that vision brought to its complete and streamlined conclusion in Hanami. For those of us cultivating Ruby on the side, some fruit takes time to bear.

Speaking of time: after I returned from Singapore, things were slow for a while. I had made a big push to [release 2.2.0.beta1](https://hanamirb.org/blog/2024/07/16/hanami-220beta1/) before the conference, and that pace was not something I could maintain. This, alongside attending a Buildkite off-site, meant things were pretty quiet for a few weeks.

## Hanami actions, meet validation contracts

It wasn’t long before I found a productive groove again. One of the things that helped here was some work that [Krzysztof Piotrowski](https://github.com/krzykamil) did to explore using full [dry-validation](https://dry-rb.org/gems/dry-validation) contracts as the means of params validation in Hanami actions.

Contracts in actions has been a much-demanded feature! In fact, some work began on it all the way back at the RubyConf hack day in November 2023 (thanks to [Dan Healy](https://github.com/danhealy)). While that effort petered out, Krzysztof progressed things far enough to arrive at a [fully functional implementation](https://github.com/hanami/controller/pull/451), ready for review. He’d also been making some great contributions to Hanami lately, so I didn’t want to keep him waiting.

After reviewing Krzysztof’s work, I managed to put together [another iteration](https://github.com/hanami/controller/pull/453) of the feature that I was happy to see go in. And thanks to [some helpful feedback](https://github.com/hanami/controller/pull/453#discussion_r1736717602) from Adam Lassek, I came back and did [one more thing](https://github.com/hanami/controller/pull/454), making it so that straight-up `Dry::Validation::Contract` classes could be used for the validation, rather than the `Hanami::Params` subclasses that were required in the older, 1.x-era behaviour that we had inherited for this feature.

The result is a useful spectrum of options. You can start with the simplest approach, embedding a contract directly in your action. Now instead of the `params` blocks you could use before (which exposed the [dry-schema](https://dry-rb.org/gems/dry-schema) features only), you can use `contract`:

```ruby
class Create < MyApp::Action
  contract do
    required(:title).filled(:string)
    required(:slug).filled(:string)
  end
end
```

If you have a contract that you want to share across actions, you can also reference its class directly:

```ruby
class Create < MyApp::Action
  contract Posts::Contract
end
```

One of the internal adjustments I made was to defer the initialization of contracts until the time the action is itself initialized. This allows you to take advantage of one of dry-validation’s most powerful features: contracts that can interact with the rest of your app via [external dependencies](https://dry-rb.org/gems/dry-validation/1.10/external-dependencies/). For example:

```ruby
module MyApp
  module Posts
    class Contract < Dry::Validation::Contract
      include Deps["repos.post_repo"]

      params do
        required(:title).filled(:string)
        required(:slug).filled(:string)
      end

      rule(:slug) do
        unless post_repo.unique_slug?(values[:slug])
          key.failure("must be unique")
        end
      end
    end
  end
end
```

With external dependencies, your validation contracts can leverage business logic anywhere in your app, while still allowing for that logic to reside in, well, a _logical_ place. And when you use validation contracts in a Hanami app, our `Deps` mixin makes this as easy as can be.

(Why exactly is deferring initialization of the contract required for this? It’s because the default dependencies you specify with `Deps` are resolved at the time of calling `.new` on the contract. We can’t call that too early, like in the class body of an action, because otherwise we’d run into all sorts of load ordering troubles.)

In fact, there’s one last little dependency-related treat for you in this feature. You saw above how contracts could take their dependencies via `Deps`? Well now you can do exactly the same with actions, with the contract itself as a dep!

```ruby
class Create < MyApp::Action
  include Deps["posts.contract"]
end
```

This is especially nice if you’re sharing your contracts between actions as well as other kinds of classes in your app, because it means you can use `Deps` as a consistent approach for using them across all places:

```ruby
class CreatePost < MyApp::Operation
  # Another class, same Dep!
  include Deps["posts.contract"]
end
```

I started this post with a little Ruby reminiscence, so why not do a little more. Back in its early days, dry-validation was one of the most important gems in spurring dry-rb adoption. Input validation is something that every app needs, and there are few solutions out there as complete and portable as dry-validation (try it in your Rails app, really!). Today, dry-validation is as relevant as ever, and with it now fully integrated into Hanami, it’s also easier to use than ever.

In fact, I think the code snippets above serve as a great example of the kind of vision we’re building towards with Hanami: actions as standalone classes, input validation as an first-class concern itself provided by standalone classes, and a simple and universal dependencies mixin to bring them together where required. Small, focused components, each with its place, and a clear strategy for connecting them. These are not the Ruby apps you’re used to. We’re bringing something new. The little integration you see above is in many ways the the culmination of 10 years of multiple streams of volunteer OSS work.

I think that enabling development approaches like this is vital part of fostering a vibrant and diverse Ruby ecosystem. If this resonates with you, we’d [love your support](https://hanamirb.org/donate/).

What gives me heart is that after all these years, we’re still finding new champions and contributors. If it wasn’t for Krzysztof taking on the challenge to bring contracts to actions, it would not be shipping in 2.2. Thank you, Krzysztof!

## Hello again, MySQL

I really didn’t intend this post to become a treatise on input validation and its meaning for the greater Ruby community, so let’s keep things moving!

Here’s something much more straighforward: when we introduced our new database layer [in beta1](), we included SQLite and Postgres support. There was one major database missing: MySQL. [Now it’s here](https://github.com/hanami/cli/pull/226).

The experience is as you’d expect: `hanami new my_app --database=mysql` will give you everything you need to get started with Hanami and MySQL, and after that, all the `hanami db` commands will work with your MySQL database as required. This was one of the last big outstanding items on our to-do list for 2.2, and now it’s done!

What’s more, we also had another new contributor come in and help make our database layer just that little bit nicer. Thanks to Kyle Plump, now if for any reason your `Gemfile` doesn’t contain the right gem(s) for your configured database(s), we’ll [give you a helpful warning](https://github.com/hanami/hanami/pull/1453). Thank you Kyle! It’s been tremendous to work with you these last couple months.

## New ways to go multi-database

The astute among you will have noticed my use of "gem(s)" for "database(s)" in the last paragraph. There’s reason for this, even putting aside my predilection for syntactical whimsy: in this last month, I introduced a whole new way to work with multiple databases in Hanami!

Since beta1, we’ve supported multiple databases along one axis: while Hanami slices may all share a single database, each may also have its own. This is as easy to configure as prefixing your database URL env var with a slice name: `MY_SLICE__DATABASE_URL`. Hanami takes care of the rest. (Of course, you can also choose to configure slice databases explicitly where you need greater control.)

This arrangement was how I was intending to leave things. Shipping a new fully-featured database layer for Hanami already felt ambitious enough. But friend-of-the-framework [Phil Arndt](https://github.com/parndt) needed something more: to work with multiple databases within a _single_ slice.

Speifically, Phil needed to set up multiple ROM [gateways](https://rom-rb.org/learn/introduction/core-concepts/#gateways). Gateways are ROM’s abstraction for a connection to a specific data source (remember: ROM works with more than just [SQL](https://github.com/rom-rb/rom-sql), it also has adapters for things like [HTTP](https://github.com/rom-rb/rom-http) and [CSV](https://github.com/rom-rb/rom-csv) and [YAML](https://github.com/rom-rb/rom-yaml) and more!).

I hate to disappoint Phil, so I rolled up my sleeves, and now Hanami has native support for [multiple gateways within each slice](https://github.com/hanami/hanami/pull/1452)!

What I love about this is that I was able to maintain the same zero-config approach we’ve had for our database layer so far. So now your ENV vars can take you even further than before. You can start with a single database (let’s use MySQL here, to stick with the theme of this <s>dissertation</s> blog post):

```
DATABASE_URL=mysql2://localhost/my_app
```

Then from there, you can go multi-database within an app by appending a suffix for each gateway:

```
DATABASE_URL=mysql2://localhost/my_app
DATABASE_URL__ARTIFACTS=mysql2://localhost/my_app_artifacts
```

There’s no limit. You can have as many gateways as you like:

```
DATABASE_URL=mysql2://localhost/my_app
DATABASE_URL__ARTIFACTS=mysql2://localhost/my_app_artifacts
DATABASE_URL__WEBHOOKS=mysql2://localhost/my_app_webhooks
```

Slices can come to the party too. Combine _slice prefixes_ with _gateway suffixes_ for the ultimate in code/database granularity:

```
# Configure multiple databases for an `Artifacts` slice
ARTIFACTS__DATABASE_URL=postgres://localhost/my_app_artifacts
ARTIFACTS__DATABASE_URL__LEGACY=postgres://localhost/my_app_artifacts_legacy
```

Zero-config is the start but not the end. Like many of the features in Hanami 2, _progressive disclosure_ is at the core of our design for gateways. If you need more than the basics, there’s another layer waiting for you. So aside from the environment variables, you can also configure gateways directly in your `:db` provider:

```ruby
Hanami.app.configure_provider :db do
  config.gateway :extra do |gw|
    # If not given, this will still be filled from `ENV["DATABASE_URL__EXTRA"]`
    gw.database_url = "..."

    # Specify an adapter to use by name (more on this later)
    gw.adapter :yaml

    # Or configure an adapter explicitly
    gw.adapter :yaml do |a|
      # You can call `a.plugin` here
      # Or also `a.extension` if this is an `:sql` adapter
    end
  end

  # Multiple gateways can be configured
  config.gateway :another do |gw|
    # ...
  end
end
```

If you have a provider with a complex multi-gateway setup, then you can also configure adapters separately, and they’ll be used across all relevant gateways:

```ruby
Hanami.app.configure_provider :db do
  # This adapter config will apply to all sql gateways
  config.adapter :sql do |a|
    a.extension :is_distinct_from
  end

  config.gateway :extra do |gw|
    # ...
  end

  # More gateways here...
end
```

## Did someone say dry-cli?

Yes! Someone did say say dry-cli, and it was [Benoit Tigeot](https://github.com/benoittgt), who a while back proposed a [couple of](https://discourse.dry-rb.org/t/dry-cli-option-to-hide-command/1823) [very nice](https://discourse.dry-rb.org/t/usage-of-did-you-mean-for-command-with-typos-in-dry-cli/1824) enhancements, then went [and implemented](https://github.com/dry-rb/dry-cli/pull/137) [them both](https://github.com/dry-rb/dry-cli/pull/138)!

Thanks to Benoit’s work, you can now hide certain commands from the CLI’s standard usage output:

```ruby
register "completion", Commands::Completion, hidden: true
```

As well as receive useful suggestions if you invoke the CLI with a typo:

```
$ ./my-cli comma
I don't know how to 'comma'. Did you mean: 'command' ?

Commands:
  my-cli command         # This is a command
```

I have to make an apology here. Benoit shipped these PRs a couple of months ago. But since that time I’ve been pretty much single-mindedly working through all the things above. It took a [friendly nudge from Benoit](https://ruby.social/@benoit/113168994252724226) on Mastodon (I love Mastodon — [let’s be friends](https://ruby.social/@timriley)) for these to get back on my radar again. I was frankly a little embarrassed at how I’d let down a smart new contributor by this long delay.

It’s not easy dong Hanami maintenance on nights and weekends. I wrote about needing to find balance [in my last update](/writing/2024/07/24/tim-in-open-source-july-2024). Once Hanami 2.2 is out, I hope will become easier to stay on top of contributions like this, because I won’t have the spectre of large, uncompleted features (like a whole database layer) weighing me down.

Anyway, I’ll be making sure we cut a new dry-cli release soon, with both of these included, as well as [documentable command namespaces](https://github.com/dry-rb/dry-cli/pull/135).

## Just before: a release!

Speaking of releases, the one big goal I had after after all of the above was getting them packaged up and out into people’s hands for testing. I did this last week, [releasing Hanami 2.2.0.beta2](https://hanamirb.org/blog/2024/09/25/hanami-220beta2/). Step by step, we’re getting there.

I’d really love it if you could [check out the announcement](https://hanamirb.org/blog/2024/09/25/hanami-220beta2/), then run a `gem install hanami --pre` and kick the tyres on all the new features. This is how we get things in truly tip top shape.

## Right now: a break!

The release came when it did, because as of this last week, I’m away on a three week holiday with my family.

After all the work on Hanami things (not to mention Buildkite things), I’m hoping to truly disconnect and recharge. If you’re waiting on issue/PR feedback from me, please forgive the brief interruption. I’ll be back again in late October.

## Up next: 2.2 by RubyConf!

I’m looking forward to attending my second [RubyConf](https://rubyconf.org) in Chicago later this year! [Last year](https://web.archive.org/web/20231106123831/https://rubyconf.org/) in sunny San Diego I got to reintroduce Hanami to America through [my talk](https://www.youtube.com/watch?v=L35MPfmtJZM) and at the Hack Day.

In the leadup to RubyConf 2023, we worked very hard to get 2.1 out. Alas, it [didn’t quite work out that way](/writing/2024/01/09/2023-in-review), but that’s no reason not to try again! So this year, we’re working very hard to get 2.2 out.

We have a couple of very good motivators for this:

- [Sean Collins](https://github.com/cllns) is on the programme, giving a [Hanami workshop](https://rubyconf.org/schedule/#sz-tab-45610)!
- I’ll be back again represeting Hanami at the Hack Day, ready to help anyone wanting to contribute.

I _really_ want everyone coming into contact with Hanami over RubyConf to be able to `gem install hanami` and receive in return our full vision for maintainable, layered, database-backed Ruby apps.

We’re _so close_ to getting this done. We’ve been executing against [a well-understood plan](link-to-forum-post) and integrating [mature, production-tested systems](https://rom-rb.org/), so I expect no surprises this time around. As I write this, our [project board](https://github.com/orgs/hanami/projects/6/views/1) only has dozen small issues left.

If we succeed, I’ll look forward to showing and talking Hanami 2.2 to many of you in Chicago! Let’s do this!

## Thank you (again!) to Hanami’s contributors

There’s a certain lovely vibe to this post: I’m not working alone. So many of the improvements above were spurred on by Hanami contributors, new and old. So let me thank all of you one more time:

- Thank you [Krzysztof Piotrowski](https://github.com/krzykamil), for spurring on the work on contracts in actions
- Thank you [Kyle Plump](https://github.com/kyleplump), for taking on all number of small issues and helping us with polish (it didn’t get a mention above, but I love [where we landed with the .keep files]()!)
- Thank you [Phil Arndt](https://github.com/parndt) and [Adam Lassek](https://github.com/alassek), for your feedback on this last month or so of work
- Thank you [Benoit Tigeot](https://github.com/benoittgt), for dry-cli fixes. I really hope we can work together more in the future!
- Thank you [Gustavo Ribeiro](https://github.com/gustavothecoder), for your PR to dry-cli.
- Thank you [Sean Collins](https://github.com/cllns), for everything you’re doing to prepare for the RubyConf workshop!

And I know this isn’t everyone. For example, a few weeks ago [Damian Rossney](https://github.com/dcr8898) and Kyle Plump got together to pair on [a fix](https://github.com/hanami/router/pull/273) to this [gnarly hanami-router issue](https://github.com/hanami/router/issues/255). I love to see this! I already replied in the issue, but reviewing this is my number one thing to do when I get back from my break.

## A cheeky question

Whew! What an update! If you made it this far, thank you for reading!

Since you’re here, you dedicated few, let me ask something of you. I’ve been writing these open source updates [since March 2020](/writing/2020/03/27/open-source-status-update-march-2020). This is my 31st edition! I’m not the fastest writer, so each one takes some hours, typically a whole night of writing, provided I start early enough. So tell me: should I keep writing these updates? What do you take from these? Is there anything you think I could do differently? Or on the flip side, if any of you are regular long-form journallers: how do you keep it up?

---
title: Open source status update, April 2020
permalink: 2020/04/30/open-source-status-update-april-2020
published_at: 2020-04-30 22:50:00 +1000
---

Hello again after another month! I’m excited to turn these monthly updates into a habit, and I’m equally as excited to share my progress with you!

**Hanami basic view integration**

I started off the month by merging the beginnings of my [Hanami 2 view integration work](https://github.com/hanami/hanami/pull/1040).

This makes it possible for views to _configure themselves_ based on the application and slice in which they’re situated, and the result is zero boilerplate view classes:

```ruby
module Main
  class View < Hanami::View[:main]
  end

  module Views
    class Articles
      class Index < Main::View
      end
    end
  end
end
```

In this example, the `Views::Articles::Index` view will have a matching template name configured (`"articles/index"`), as well as the appropriate paths to find that template within the `Main` slice’s directory.

This is a great start, but it’s not the end of the view integration story for Hanami 2!

**View integration with Hanami actions**

The next step in this journey is making it nice to actually go ahead and _render_ these views within Hanami actions, as well as making sure that various request-specific details (like CSRF tokens, flash messages, and even just the request path) are available to views that require them.

This was a tough nut to crack, but I think it also demonstrates just how grateful I am to be collaborating with Luca on all of this.

I started off this effort by [copying over the very light-touch view/action integration](https://github.com/hanami/hanami/pull/1043) that I’d already established within the Hanami 2 apps I’ve built so far. This consisted of a few extra helper methods inside the application’s base action, allowing you to render a view like this:

```ruby
module Main
  module Actions
    module Articles
      class Index < Main::Action
        include Deps[view: "views.articles.index"]

        def handle(req, res)
          render req, res, page: req.params[:page]
        end
      end
    end
  end
end
```

This worked okay, but it felt awkward in a couple of ways. Having to pass the extra `req, res` to every `render` could quickly become laborious. It also didn’t fit well in PUT or POST actions, where you’re typically either redirecting (via `res.redirect_to "..."`) or rendering (in this case via `render`) based on the success of your action. Having to operate on the `res` in one case and then via a helper directly on `self` in the other just didn’t feel _balanced_.

Luca encouraged me to find a better approach. After various circuitious discussions squeezed into our paltry ~1 hour Canberra/Rome daily overlapping time window, we decided it best to sketch out some complete-ish working implementations in code. This helped us land on this:

```ruby
class Create < Main::Action
  include Deps[view: "views.articles.index"]

  def handle(req, res)
    if create_article_somehow(req.params[:article])
      res.redirect_to "/admin/articles"
    else
      res.render view, validation: errors_go_here
    end
  end
end
```

This gives us a much nicer symmetry, with both redirecting and view rendering being a capability of the response (internally, the rendering just boils down to calling the view object and assigning its output to the its `body`), and a little less line-noise, since we also established a way to ensure the `res` object has all the request-specific details that a view may need.

What I also like about this implementation is that action classes still very much retain their ”what you see is what you get” quality. They are very much _coordinators_ of application domain services, existing simply to handle the HTTP-related aspects of the web interface, and passing control to the other services as required. Views become just another element in this mix, handled like any other dependency of an action.

It’s still very early days for this view/action integration, but we’re happy enough with the direction such that I can now begin finessing it and finishing it, hopefully over the month of May.

The work so far (which is messy, be warned!) is spread across PRs in both [hanami/controller](https://github.com/hanami/controller/pull/311) and [hanami/hanami](https://github.com/hanami/hanami/pull/1049). I’ve also made corresponding [adjustments to our soundeck demo app](https://github.com/jodosha/soundeck/pull/8) to show this rendering approach in action, as well as various ways you can test actions that render views.

**Various Hanami things: CLI env handling, dotenv improvements, middleware fix**

Last week I also [made some small fixes and tweaks](https://github.com/hanami/hanami/pull/1045) to the nascent Hanami 2 CLI: I made it so the application boot process triggered via CLI actions was deferred late enough such that the `-e` flag (to set the `HANAMI_ENV`) is properly respected (important if you want to migrate your _actual_ test database!). Related, I expanded the range of files we load via Dotenv for application settings, so you can have your `.env.test` and <del>eat it too</del> have it actually respected when running CLI commands with `-e test`.

I also [stumbled across and fixed](https://github.com/hanami/hanami/pull/1046) a bug that prevented Rack middlewares from being mounted in the Hanami router if their `#initialize` accepted only a single `app` arg. This is why it’s good to have a real everyday app running on in-progress frameworks like this; such things get noticed and fixed much more quickly!

**Bonus OSS: development environment tooling**

One more thing: I was glad to have the opportunity to bring several elements of Icelab’s former shared development environment into our new Culture Amp team:

* Our [shared dotfiles](https://github.com/cultureamp/web-team-dotfiles)
* Our [Homebrew commands tap](https://github.com/cultureamp/homebrew-web-team-devtools), which includes `bootstrap-developer-system` to install the development environment, including the dotfiles, and `bootstrap-asdf`, which takes care of some of the
* And our [scripts to rule them all](https://github.com/cultureamp/web-team-scripts-to-rule-them-all), which implements the normalized script pattern for every one of our apps, making it possible for the app to install

After a decade of trying various shared development environments, and now working with this approach for the last couple of years, I’m still incredibly happy with this combo: it’s very light touch and the components are all very simple, making the whole thing a breeze to maintain. I’m happy it can live on and continue serve our team within a new company!

Did I mention I also gave [my own dotfiles](https://github.com/timriley/dotfiles) a refresh recently too?

**Shout out to my GitHub sponsor!!**

I’ll write about this in more detail soon, but here’s the short story: it dawned on me recently that helping to bring Hanami 2 into fruition will be a long slog, and that I could do with all the encouragement I could get. [So I signed up for GitHub sponsors](https://github.com/sponsors/timriley).

Within a week I already have one sponsor: thank you so much to [Benjamin Klotz](https://github.com/tak1n) for your support! Receiving that first “You have a sponsor” email was truly a joy 😄.

**See you next month 👋🏼**

Well, that’s it for April! I’ll be spending May focused on getting that Hanami view/action integration done. It’s going to take some doing, but once it’s in place it’ll represent a major step forward for the 2.0 effort.

See you back here again next month!

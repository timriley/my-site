---
title: Open source status update, September 2023
permalink: 2023/10/20/open-source-status-update-september-2023
published_at: 2023-10-20 24:01 +1100
---

With the two big PRs introducing our next generation of asset support merged ([here](https://github.com/hanami/assets/pull/120) and [here](https://github.com/hanami/hanami/pull/1319)), September was a month for rapid iteration and working towards getting assets out in a 2.1 beta release.

The pace was lively! Towards the end of the month, Luca and I were trading PRs and code reviews on almost a daily basis. Thanks our opposing timezones, Hanami was being written nearly 24h a day!

## Assorted small things

Most of the work was fairly minor: an [error logging fix](https://github.com/hanami/hanami/pull/1337), some [test updates for the new assets](https://github.com/hanami/hanami/pull/1334), [error handling around asset manifests](https://github.com/hanami/assets/pull/127), and a bit of [zeitwerkin’](https://github.com/hanami/assets/pull/129).

## Making our better errors better

There was one interesting piece though. Earlier in this release cycle (back in June!), I overhauled our user-facing error handling. I added a middleware to [catch errors and render static error pages intended display in production](https://github.com/hanami/hanami/pull/1309). As part of this change, I adjusted our router to raise exceptions for mot found routes: doing this would allow the error to be caught and a proper 404 page displayed. So that was production sorted. For development, we [integrated the venerable better_error gem](https://github.com/hanami/hanami/pull/1311), wrapped by our own hanami-webconsole gem.

It was only some months later that we realised 404s in development were being returned as 500s. This turned out to be because better_errors defaults to a 500 response code at all times. [In its middleware](https://github.com/BetterErrors/better_errors/blob/fde3b7025db17b5cda13fcf8d08dfb3f76e189f6/lib/better_errors/middleware.rb#L109-L129):

```ruby
status_code = 500
# ...
response = Rack::Response.new(content, status_code, headers)
```

Well, maybe not _quite_ at all times. The lines right beneat `status_code = 500`:

```ruby
status_code = 500
if defined?(ActionDispatch::ExceptionWrapper) && exception
  status_code = ActionDispatch::ExceptionWrapper.new(env, exception).status_code
end
```

Looks like Ruby on Rails gets its own little exception carved out here, via some hard-coded constant checks that reach deep inside Rails internals. This will allow better_errors to return a 404 for a not found error in Rails, but not in any other Ruby framework.

This is not a new change. It arrived [over ten years ago](https://github.com/BetterErrors/better_errors/pull/176), and I can hardly blame the authors for wanting a way to make this work nicely with the predominant Ruby application framework of the day.

Today, however, is a different day! We’re here to _change_ the Ruby framework balance. 😎 So we needed a way to make this work for Hanami. What didn’t feel feasiable at this point was a significant change to better_errors: our time was limited and at best we only had the appetite for a minor tactical fix.

[Our resulting fix in webconsole](https://github.com/hanami/webconsole/pull/7) ([along with this counterpart in hanami](https://github.com/hanami/hanami/pull/1330)) does monkey patch better_errors, but I was very pleased with how gently we could do it. The patch is tiny:

```ruby
module BetterErrorsExtension
  # The BetterErrors middleware always returns a 500 status when rescuing an exception
  # (outside of Rails). This is not not always appropriate, such as for a
  # `Hanami::Router::NotFoundError`, which should be a 404.
  #
  # To account for this, gently patch `BetterErrors::Middleware#show_error_page` (which is
  # called only when an exception has been rescued) to pass that rescued exception to a proc
  # we inject into the rack env here in our own middleware. This allows our middleware to know
  # the about exception class and provide the correct status code after BetterErrors is done
  # with its job.
  #
  # @see Webconsole::Middleware#call
  def show_error_page(env, exception = nil)
    if (capture_proc = env[CAPTURE_EXCEPTION_PROC_KEY])
      capture_proc.call(exception)
    end

    super
  end
end
BetterErrors::Middleware.prepend(BetterErrorsExtension)
```

In order to know which response code to use for the page, we need access to the exception that better_error is catching. Right now it provides no hooks to expose that. So instead we prepend some behaviour in front of their `#show_error_page`, which is only called by the time an error is to be rendered. We look for a proc on the rack env, and if one is there, we pass the exception to it, and then let better_errors get on with the rest of its normal work.

Then, in our own webconsole middleware, we set that proc to capture the exception, using Ruby closure semantics to assign that exception directly to a local variable:

```ruby
def call(env)
  rescued_exception = nil
  env[CAPTURE_EXCEPTION_PROC_KEY] = -> ex { rescued_exception = ex }

  # ...
end
```

After that, we call the better_errors middleware, letting it do its own thing:

```ruby
def call(env)
  rescued_exception = nil
  env[CAPTURE_EXCEPTION_PROC_KEY] = -> ex { rescued_exception = ex }

  status, headers, body = @better_errors.call(env)
end
```

And then once that is done, we can use the exception (if we have one) to fetch an appropriate response code from the hanami app config, and then override better_errors’ response code with our one:

```ruby
def call(env)
  rescued_exception = nil
  env[CAPTURE_EXCEPTION_PROC_KEY] = -> ex { rescued_exception = ex }

  status, headers, body = @better_errors.call(env)

  # Replace the BetterErrors status with a properly configured one for the Hanami app
  if rescued_exception
    status = Rack::Utils.status_code(
      @config.render_error_responses[rescued_exception.class.name]
    )
  end

  [status, headers, body]
end
```

That’s it! Given how light touch this is, and how stable better_errors is, I’m confident this will serve our purposes quite well for now.

We don’t want to live with this forever, however. In our future I see a fit for purpose developer errors reporter that is fully integrated with Hanami’s developer experience. Given current timelines, this will probably won’t come for at least 12 months, so if this is something you’re interested in helping with, please reach out!

## Kickstarting dry-operation!

While the work on Hanami continued, I also helped kickstart work on a new dry-rb gem: [dry-operation](https://github.com/dry-rb/dry-operation)! Serving as the successor to [dry-transaction](http://dry-rb.org/gems/dry-transaction), with dry-operation we’ll introduce significant new flexibility to modelling composable business operations, while still keeping a high-level API that presents their key flows in an easy to follow way.

Much of the month was spent ideating on various approaches with [Marc Busqué](http://waiting-for-dev.github.io) and [Brooke Kuhlmann](https://alchemists.io/), and then by the end of the month, Marc was already underway with the development work. [Go check out Marc’s September update](http://waiting-for-dev.github.io/blog/2023/10/10/open_source_status_september_2023) for a little more of the background on this.

I’m excited we’re finally providing a bridge to the future for dry-transaction, and at the same time building one of the final pieces of the puzzle for full stack Hanami apps. This is an interesting one for me personally, too, since I’m acting more as a “product manager” for this effort, with Marc doing most of the direct development work. Marc’s been in the dry-rb/Hanami orbit for a while now, and I’m excited for this opportunity for him to step up his contributions. More on this in the future!

## Releasing Hanami 2.1.0.beta2!

After all of this, we capped the month off with [the release of Hanami 2.1.0.beta2](https://hanamirb.org/blog/2023/10/04/hanami-210beta2/)! This was a big step: our first beta to include _both_ views and assets together. In the time since this release we’ve already learnt a ton and found way to take things to another level... but more on that next month. 😉 See you then!

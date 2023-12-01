---
title: Caching and Expring Stylesheets and Javascripts in Sinatra
permalink: 2009/02/09/caching-and-expring-stylesheets-and-javascripts-in-sinatra
published_at: 2009-02-08 21:30:00 +0000
---

_The code examples in this article were extracted from [Tim Lucas](http://toolmantim.com/)'s [toolmantim.rb](http://github.com/toolmantim/toolmantim/), a weblog app that inspired me to start playing with Sinatra. Thanks to Tim for his good work!_

One of the most rewarding things I've found while playing with [Sinatra](http://www.sinatrarb.com/) so far it encourages me to learn more about the implementation of the underlying mechanics of a modern web application. This is a framework that doesn't coddle you: the things that you get for free in [Rails](http://rubyonrails.com/) and the other larger web frameworks are nowhere to be seen. What's left is lean & mean, and ready to be shaped into whatever form you fancy!

[![Expiry stamp](54b06666e12f.jpg)](http://www.flickr.com/photos/tartanna/52648670/)

So let's talk about stylesheets and javascript files. These are assets that don't change as often as the pages in your web app. Your javascript files are more than likely to be served directly from the filesystem. Your stylesheets may also be static files, but Sinatra also provides excellent support for generating CSS from Sass templates.

If you're using Sass, you'll no doubt have something like this in your Sinatra app:

```
get "/stylesheets/screen.css" do
  content_type 'text/css'
  sass :"stylesheets/screen"
end
```

When someone requests the `/stylesheets/screen.css` file, the above action is run and the generated CSS is sent back. You won't want the very same thing happening for the next page request. You can fix this by setting the 'Expiry' header in the responses you send to stylesheet requests:

```
get "/stylesheets/screen.css" do
  content_type 'text/css'
  response['Expires'] = (Time.now + 60*60*24*356*3).httpdate
  sass :"stylesheets/screen"
end
```

Setting the '[Expires](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.21)' header in the above action will encourage client proxies or browsers to cache your generated stylesheet.

This is all pretty great, but this technique still leaves a couple of gaps. Any static files (like javascripts) are not served through Sinatra, so we can't manually set an Expires header for them. Further, for the stylesheets that Sinatra _does_ generate, we'll need a way to force the clients to refresh them whenever we modify their source Sass files. We can address these gaps with a couple of Sinatra helpers:

```
helpers do
  def versioned_stylesheet(stylesheet)
    "/stylesheets/#{stylesheet}.css?" + File.mtime(File.join(Sinatra::Application.views, "stylesheets", "#{stylesheet}.sass")).to_i.to_s
  end
  def versioned_javascript(js)
    "/javascripts/#{js}.js?" + File.mtime(File.join(Sinatra::Application.public, "javascripts", "#{js}.js")).to_i.to_s
  end
end
```

Use these helpers to load your javascripts and stylesheets in the appropriate places in your layout file:

```
!!! Strict
%html{:xmlns =>'http://www.w3.org/1999/xhtml', 'xml:lang' => 'en', :lang => 'en'}
  %head
    %meta{'http-equiv' => 'Content-Type', :content => 'text/html; charset=utf-8'}/
    %title My Sinatra App

    %link{:href => versioned_stylesheet('screen'), :media => 'screen', :rel => 'stylesheet', :type => 'text/css'}/
    %script{:src => versioned_javascript('application'), :type => 'text/javascript'}/
```

These helpers will generate links with a timestamp appended, like so: `stylesheets/screen.css?1233119990`. This timestamp is derived from the file modification time of the source Sass files for your stylesheets (and in the case of javascripts, the static javascript files themselves), which means that a new timestamp will appear in your page source automatically after you make modifications. This will trigger the clients to request the newest stylesheets, which will in turn stay cached until the next change and minimise the total download for each request to your Sinatra application.


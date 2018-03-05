---
title: Using Compass for CSS in your Sinatra application
permalink: 2009/01/27/using-compass-for-css-in-your-sinatra-application
published_at: 2009-01-27 11:30:00 +0000
---

Stage left: [Sinatra](http://sinatra.github.com/), the hottest new Ruby DSL for expressive, singular web application development. Stage right: [Compass](http://compass-style.org/), the CSS _metaframework_ that takes the ease of use of [Blueprint](http://www.blueprintcss.org/)'s grids and [Sass](http://haml.hamptoncatlin.com/)' syntax, and lets you combine them in a manner semantic & modular, just how you like it.

[![Sinatra graffiti](squarespace/images/ss/44bfc49ebf79.jpg)](http://www.flickr.com/photos/damonabnormal/2228863689/)

Until now, these actors could never meet. With the release of the 0.9 series of Sinatra, however, it has become a _breeze_.

The key change occurred with the restructure of Sinatra's rendering logic. When you call `sass` to render a Sass stylesheet, you can now pass options that go directly to the Sass engine. See this excerpt from `lib/sinatra/base.rb` in the codebase:

```
def sass(template, options={}, &block)
  require 'sass' unless defined? ::Sass
  options[:layout] = false
  render :sass, template, options
end

def render_sass(template, data, options, &block)
  engine = ::Sass::Engine.new(data, options[:sass] || {})
  engine.render
end
```

See that `options[:sass]` hash going to `::Sass::Engine.new`? That's how we'll get Compass to work. All it needs are some extra load paths to be passed to `Sass::Engine`, which you can do when you render your Sass stylesheet. Compass also conveniently provides a configuration singleton to let you do this just once in the `configure` block of your application:

```
gem 'chriseppstein-compass', '~> 0.4'
require 'compass'

configure do
  Compass.configuration do |config|
    config.project_path = File.dirname( __FILE__ )
    config.sass_dir = File.join('views', 'stylesheets')
  end
end

get "/stylesheets/screen.css" do
  content_type 'text/css'

  # Use views/stylesheets & blueprint's stylesheet dirs in the Sass load path
  sass :"stylesheets/screen", :sass => Compass.sass_engine_options
end
```

This stylesheet action at the bottom of this example will parse your views/stylesheets/screen.sass file and your Compass inclusions and mixins will output exactly the CSS that you expect. All done!

**Update (2009-02-15):** The code above was updated for the improved Sass configuration support in Compass 0.4. See [my post on the 0.4 release](http://log.openmonkey.com/post/78482055/cleaner-sinatra-integration-with-compass-0-4) for an explanation of the improvements. Before this release, your stylesheet actions would have looked a lot more ungainly:

```
get "/stylesheets/screen.css" do
  content_type 'text/css'

  # Use views/stylesheets & blueprint's stylesheet dirs in the Sass load path
  sass :"stylesheets/screen", { :sass => { :load_paths => (
    [File.join(File.dirname( __FILE__ ), 'views', 'stylesheets')] +
    Compass::Frameworks::ALL.map { |f| f.stylesheets_directory })
  } }
end
```

Of course, you won't want Sass loading up all the Compass files and re-rendering your CSS with every page request, so you will want to cache this generated CSS file. This is another handy Sinatra trick I've come across, but I'll save that for the next entry.


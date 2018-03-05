---
title: Cleaner Sinatra integration with Compass 0.4
permalink: 2009/02/15/cleaner-sinatra-integration-with-compass-04
published_at: 2009-02-15 12:55:00 +0000
---

[Chris Eppstein](http://acts-as-architect.blogspot.com/) has been working hard on [Compass](http://compass-style.org/) lately to improve its integration with application frameworks. This gives me the pleasure of updating the code from my [earlier post about integrating Sinatra and Compass](http://log.openmonkey.com/post/73462983/using-compass-for-css-in-your-sinatra-application):

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

The above is everything you need for your [Sinatra](http://sinatrarb.com/) app to use Compass 0.4 to render your CSS. The biggest change in 0.4 is that Compass now comes with a configuration singleton. I set it up above in Sinatra's `configure` block and tell it that I keep my Sass stylesheets in `views/stylesheets` inside the application directory. Keeping the Sass configuration separate from the working application code keeps your render calls short and concise, like the rest of your well-crafted Sinatra app.

Thanks to Chris for his hard work and for providing the example code for the Sinatra integration.


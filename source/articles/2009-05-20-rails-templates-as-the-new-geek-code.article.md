---
title: Rails Templates as the New Geek Code
permalink: 2009/05/20/rails-templates-as-the-new-geek-code
published_at: 2009-05-20 02:30:00 +0000
---

Anyone who's been around the Internet long enough should remember [The Geek Code](http://www.geekcode.com/). This meme sought to provide a - however obsbcure - succinct textual distillation of the attributes and interests of any geek.

```
GED/J d-- s:++>: a-- C++(++++) ULU++ P+ L++ E---- W+(-) N+++ o+ K+++ w---
  O- M+ V-- PS++>$ PE++>$ Y++ PGP++ t- 5+++ X++ R+++>$ tv+ b+ DI+++ D+++
  G+++++ e++ h r-- y++**
```

This geek code block represents someone trained in education and law who is tall and dresses casually, knows his way around Linux and Ultrix pretty well, hates emacs, but loves indulging in a little Dilbert. [Look it up](http://www.geekcode.com/geek.html), it's elaborate.

Today, a Rails developer can provide a [template](http://m.onkey.org/2008/12/4/rails-templates) for generating new apps that can uniquely embody all their development tools and preferences in a single place.

```
gem 'haml'
gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
gem 'chriseppstein-compass', :lib => 'compass', :source => 'http://gems.github.com'
gem 'thoughtbot-paperclip', :lib => 'paperclip', :source => 'http://gems.github.com' if yes?('Paperclip gem?')
gem 'authlogic' if yes?('Authlogic gem?')
```

You're a haml guy? Right on. Plus compass for CSS! You must like really things semantic.

```
file '.testgems',
%q{config.gem 'rspec'
config.gem 'rspec-rails'
config.gem 'notahat-machinist', :lib => 'machinist', :source => 'http://gems.github.com'
config.gem 'ianwhite-pickle', :lib => 'pickle', :source => 'http://gems.github.com'
config.gem 'webrat'
config.gem 'cucumber'
}
run 'cat .testgems >> config/environments/test.rb && rm .testgems'
```

RSpec along with Cucumber backed by Machinist and Pickle for test data factories. You must be Australian. But that's cool, that's a pretty helpful combo for tests.

```
git :init
git :add => '.'
git :commit => '-a -m "Initial commit from AMC Rails template"'
```

Building a complete Rails template has been really useful for us at the [AMC](http://www.amc.org.au/). We're often asked to bring up quick, single-purpose apps alongside the many components that we're building in our mostly service-oriented architecture.

Our template is [available on GitHub](http://github.com/timriley/amc-rails-template) for your perusal and reuse. It does everything from setting up plugins and gem dependencies, to generating a deploy script using our custom capistrano extensions, to including a default layout and stylesheet. This is how we roll, captured in a single file.


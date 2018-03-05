---
title: Adaptive script/console Shell Alias for both Rails and Sinatra
permalink: 2009/03/06/adaptive-script-console-shell-alias-for-both-rails-and-sinatra
published_at: 2009-03-06 05:25:00 +0000
---

Like many keystroke-efficient Rails hackers, I've long had a line in my `.bash_profile` file to alias `sc` to `script/console`, along with a [host of other tricks](http://gist.github.com/74761).

This shortcut was more than sufficient until recently, when I started writing Sinatra apps. The minimal framework that it is, Sinatra doesn't provide a console script like Rails, but I found you can easily achieve the same effect by running `irb -r your_sinatra_app.rb`.

Not wanting my fingers to have to deviate from habits long held, I changed my `sc` alias into a full-blown bash function that will drop you into a Rails console, Sinatra console or just a plain irb console based on your location within the filesystem:

```
function sc {
  if [-x script/console]; then
    script/console
  else
    sinatra_rb=`egrep -l "^require.+sinatra.$" *.rb 2>/dev/null`
    if [-e $sinatra_rb]; then
      irb -r $sinatra_rb
    else
      irb
    fi
  fi
}
```

Throw it in your `.bash_profile` and have fun!

